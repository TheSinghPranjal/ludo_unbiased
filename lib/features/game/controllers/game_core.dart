import 'dart:async';
import 'dart:math';

import 'package:async/async.dart' show CancelableOperation;
import 'package:flutter/foundation.dart';
import 'package:ludo_unbiased/core/constants/timing.dart';
import 'package:ludo_unbiased/core/utils/clock.dart';
import 'package:ludo_unbiased/core/utils/result.dart';
import 'package:ludo_unbiased/features/ai/ai_player.dart';
import 'package:ludo_unbiased/features/game/engine/game_engine.dart';
import 'package:ludo_unbiased/features/game/engine/rule_error.dart';
import 'package:ludo_unbiased/features/game/engine/timeout_policy.dart';
import 'package:ludo_unbiased/features/game/models/game_event.dart';
import 'package:ludo_unbiased/features/game/models/game_state.dart';
import 'package:ludo_unbiased/features/game/models/player.dart';
import 'package:ludo_unbiased/features/game/services/animation_gate.dart';
import 'package:ludo_unbiased/features/game/services/auto_play.dart';
import 'package:ludo_unbiased/features/game/services/dice_service.dart';
import 'package:ludo_unbiased/features/game/services/turn_timer.dart';

/// The turn logic shared by every device that owns the engine: the local
/// game and the online host (ARCHITECTURE.md §6).
///
/// Every command (a tap, the AI, the auto-move, the timer, a network
/// intent) goes through [roll] or [move], which call the engine. The core
/// then plays the events through [gate], settles the state, and schedules
/// whatever happens next.
///
/// Guarantees:
/// * a single legal move plays itself 1120 ms after the roll commits, and
///   never before the dice animation has completed;
/// * each decision point gets exactly one automatic action, however the
///   timer, the auto-move and the AI race;
/// * nothing fires after game over, pause or dispose.
class GameCore {
  /// Creates a core for [initial]. Call [start] to begin.
  GameCore({
    required GameState initial,
    required this.dice,
    AiPlayer? ai,
    this.clock = const GameClock(),
    Random? random,
    AnimationGate? gate,
  }) : state = ValueNotifier(initial),
       _ai = ai ?? AiPlayer(random: random),
       _random = random ?? Random(),
       gate = gate ?? const TimedAnimationGate() {
    _timer = TurnTimer(onExpire: _onExpire, clock: clock);
  }

  /// The current state. Never set from outside.
  final ValueNotifier<GameState> state;

  /// Source of dice values. Only this device rolls.
  final DiceService dice;

  /// Time source for timers and delays.
  final GameClock clock;

  /// Waits for events to finish animating. Swap it at any time; the board
  /// installs its own, and the app installs a timed one in the background.
  AnimationGate gate;

  /// Called after every settle with the settled state and the turn time
  /// left, for saving and for host timer sync.
  void Function(GameState state, int remainingMs)? onSettled;

  final AiPlayer _ai;
  final Random _random;
  late final TurnTimer _timer;
  final _guard = DecisionGuard();
  final _events = StreamController<List<GameEvent>>.broadcast();
  CancelableOperation<void>? _autoMove;
  Timer? _aiTimer;
  bool _started = false;
  bool _paused = false;
  bool _disposed = false;

  /// Set when the timer expired before the roll; the turn plays itself out.
  bool _timedOutBeforeRoll = false;

  /// Set when the timer expired during an animation.
  bool _expiredWhileAnimating = false;

  /// Each committed batch of events, in order.
  Stream<List<GameEvent>> get events => _events.stream;

  /// Milliseconds left on the turn timer, updated ten times a second.
  ValueListenable<int> get remainingMs => _timer.remainingMs;

  /// True while paused.
  bool get isPaused => _paused;

  /// Starts the timer and any AI turn. [remaining] resumes a saved timer.
  void start({Duration? remaining}) {
    if (_started || _disposed) return;
    _started = true;
    final s = state.value;
    if (s.isOver) return;
    _timer.start(remaining);
    _scheduleNext();
  }

  /// [playerId] rolls. Returns the rule error, or null when committed.
  RuleError? roll(PlayerId playerId) {
    if (_disposed) return RuleError.gameOver;
    final before = state.value;
    final result = GameEngine.roll(before, playerId, dice);
    if (result is Err<Commit, RuleError>) return result.error;
    final (next, events) = result.value;
    _guard.claim(before.turnSeq);
    _cancelPending();
    _publish(next, events);
    final settled = Completer<void>();
    final single = autoSingleMove(next);
    if (single != null) {
      _scheduleAutoMove(next.turnSeq, single.tokenId, settled.future);
    }
    unawaited(_animateThenSettle(events, next.turnSeq, settled));
    return null;
  }

  /// [playerId] moves [tokenId]. Returns the rule error, or null.
  RuleError? move(PlayerId playerId, int tokenId) {
    if (_disposed) return RuleError.gameOver;
    final before = state.value;
    final result = GameEngine.move(before, playerId, tokenId);
    if (result is Err<Commit, RuleError>) return result.error;
    final (next, events) = result.value;
    _guard.claim(before.turnSeq);
    _cancelPending();
    _publish(next, events);
    unawaited(_animateThenSettle(events, next.turnSeq, Completer<void>()));
    return null;
  }

  /// Applies a connection, removal or AI takeover from the engine.
  RuleError? applyCommit(Result<Commit, RuleError> result) {
    if (_disposed) return RuleError.gameOver;
    if (result is Err<Commit, RuleError>) return result.error;
    final before = state.value;
    final (next, events) = result.value;
    _publish(next, events);
    if (next.turnSeq != before.turnSeq) {
      _cancelPending();
      _afterSettle();
    } else if (next.currentPlayer.kind != before.currentPlayer.kind) {
      _scheduleNext();
    }
    return null;
  }

  /// Stops the timer and all pending automatic actions (local games only).
  void pause() {
    if (_paused || _disposed) return;
    _paused = true;
    _timer.pause();
    _cancelPending();
  }

  /// Continues after [pause] and reschedules what was pending.
  void resume() {
    if (!_paused || _disposed) return;
    _paused = false;
    _timer.resume();
    _scheduleNext();
  }

  /// Stops everything. The core cannot be used afterwards.
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _cancelPending();
    _timer.dispose();
    unawaited(_events.close());
    state.dispose();
  }

  void _publish(GameState next, List<GameEvent> events) {
    state.value = next;
    if (events.isNotEmpty) _events.add(events);
  }

  Future<void> _animateThenSettle(
    List<GameEvent> events,
    int turnSeq,
    Completer<void> settled,
  ) async {
    await gate.played(events);
    if (_disposed) return;
    final s = state.value;
    if (s.turnSeq != turnSeq || s.phase != GamePhase.animating) {
      settled.complete();
      return;
    }
    state.value = GameEngine.settle(s);
    settled.complete();
    _afterSettle();
  }

  void _afterSettle() {
    if (_disposed) return;
    final s = state.value;
    if (s.isOver) {
      _timer.cancel();
      _cancelPending();
      onSettled?.call(s, 0);
      return;
    }
    if (s.phase == GamePhase.awaitingRoll) {
      // A new turn or an extra roll: the full 30 seconds again.
      _timedOutBeforeRoll = false;
      _expiredWhileAnimating = false;
      if (_paused) {
        _timer
          ..start()
          ..pause();
      } else {
        _timer.start();
      }
    } else if (s.phase == GamePhase.rolled) {
      if (_expiredWhileAnimating) {
        _expiredWhileAnimating = false;
        _timedOutBeforeRoll = false;
        _playTimeoutMove();
        return;
      }
      if (_timedOutBeforeRoll && autoSingleMove(s) == null) {
        _timedOutBeforeRoll = false;
        _playTimeoutMove();
        return;
      }
    }
    onSettled?.call(s, _timer.remaining);
    _scheduleNext();
  }

  void _onExpire() {
    if (_disposed || _paused) return;
    final s = state.value;
    if (s.isOver) return;
    switch (s.phase) {
      case GamePhase.animating:
        _expiredWhileAnimating = true;
      case GamePhase.awaitingRoll:
        if (!_guard.canClaim(s.turnSeq)) return;
        _timedOutBeforeRoll = true;
        roll(s.currentPlayer.id);
      case GamePhase.rolled:
        _playTimeoutMove();
      case GamePhase.gameOver:
        return;
    }
  }

  void _playTimeoutMove() {
    final s = state.value;
    if (s.phase != GamePhase.rolled || !_guard.canClaim(s.turnSeq)) return;
    final m = timeoutMove(s);
    if (m != null) move(s.currentPlayer.id, m.tokenId);
  }

  void _scheduleAutoMove(int turnSeq, int tokenId, Future<void> settled) {
    final op = CancelableOperation<void>.fromFuture(
      Future.wait([clock.delay(Timing.autoMove), settled]),
    );
    _autoMove = op;
    unawaited(
      op.valueOrCancellation().then((_) {
        if (identical(_autoMove, op)) _autoMove = null;
        if (op.isCanceled || _disposed || _paused) return;
        final s = state.value;
        if (s.isOver ||
            s.turnSeq != turnSeq ||
            s.phase != GamePhase.rolled ||
            !_guard.canClaim(turnSeq)) {
          return;
        }
        move(s.currentPlayer.id, tokenId);
      }),
    );
  }

  /// Schedules whatever acts next at a settled decision point: the auto-move
  /// after a resume, or the AI.
  void _scheduleNext() {
    if (_disposed || _paused) return;
    final s = state.value;
    if (s.isOver || s.phase == GamePhase.animating) return;
    if (s.phase == GamePhase.rolled) {
      final single = autoSingleMove(s);
      if (single != null) {
        if (_autoMove == null) {
          _scheduleAutoMove(s.turnSeq, single.tokenId, Future<void>.value());
        }
        return;
      }
    }
    final p = s.currentPlayer;
    if (p.kind != PlayerKind.ai) return;
    final seq = s.turnSeq;
    final think =
        Timing.aiThinkMin.inMilliseconds +
        _random.nextInt(
          Timing.aiThinkMax.inMilliseconds -
              Timing.aiThinkMin.inMilliseconds +
              1,
        );
    _aiTimer?.cancel();
    _aiTimer = clock.after(Duration(milliseconds: think), () {
      _aiTimer = null;
      final now = state.value;
      if (_disposed || _paused || now.isOver || now.turnSeq != seq) return;
      if (now.phase == GamePhase.awaitingRoll) {
        roll(p.id);
      } else if (now.phase == GamePhase.rolled) {
        final t = _ai.choose(now, p.aiLevel ?? AiLevel.normal);
        if (t != null) move(p.id, t);
      }
    });
  }

  void _cancelPending() {
    unawaited(_autoMove?.cancel());
    _autoMove = null;
    _aiTimer?.cancel();
    _aiTimer = null;
  }
}
