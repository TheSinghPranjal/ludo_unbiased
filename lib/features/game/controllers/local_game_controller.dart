import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:ludo_unbiased/core/utils/clock.dart';
import 'package:ludo_unbiased/features/ai/ai_player.dart';
import 'package:ludo_unbiased/features/game/controllers/game_controller.dart';
import 'package:ludo_unbiased/features/game/controllers/game_core.dart';
import 'package:ludo_unbiased/features/game/data/saved_game_repository.dart';
import 'package:ludo_unbiased/features/game/engine/game_engine.dart';
import 'package:ludo_unbiased/features/game/engine/rule_error.dart';
import 'package:ludo_unbiased/features/game/models/game_event.dart';
import 'package:ludo_unbiased/features/game/models/game_state.dart';
import 'package:ludo_unbiased/features/game/models/player.dart';
import 'package:ludo_unbiased/features/game/models/player_color.dart';
import 'package:ludo_unbiased/features/game/services/animation_gate.dart';
import 'package:ludo_unbiased/features/game/services/dice_service.dart';

/// One seat in the Local Setup screen.
typedef SeatConfig = ({
  PlayerColor color,
  String name,
  PlayerKind kind,
  AiLevel? aiLevel,
});

/// Pass-and-play on one device, with optional AI seats.
///
/// Whoever holds the phone acts for the current human seat. The game is
/// saved after every settle and cleared when it ends.
class LocalGameController implements GameController {
  /// Wraps an existing game core.
  LocalGameController(this._core, {this.saves}) {
    _core.onSettled = _onSettled;
  }

  /// A new game for [seats].
  factory LocalGameController.newGame(
    List<SeatConfig> seats, {
    SavedGameRepository? saves,
    DiceService? dice,
    GameClock clock = const GameClock(),
    Random? random,
    AnimationGate? gate,
  }) {
    final state = GameEngine.newGame(
      gameId: 'local-${clock.nowMs()}',
      players: [
        for (final s in seats)
          Player(
            id: 'local-${s.color.name}',
            color: s.color,
            name: s.name,
            kind: s.kind,
            aiLevel: s.kind == PlayerKind.ai
                ? s.aiLevel ?? AiLevel.normal
                : null,
          ),
      ],
    );
    return LocalGameController(
      GameCore(
        initial: state,
        dice: dice ?? SecureDiceService(),
        clock: clock,
        random: random,
        ai: AiPlayer(random: random),
        gate: gate,
      ),
      saves: saves,
    );
  }

  /// Resumes [saved].
  factory LocalGameController.resume(
    SavedGame saved, {
    SavedGameRepository? saves,
    DiceService? dice,
    GameClock clock = const GameClock(),
    Random? random,
    AnimationGate? gate,
  }) => LocalGameController(
    GameCore(
      initial: saved.state,
      dice: dice ?? SecureDiceService(),
      clock: clock,
      random: random,
      ai: AiPlayer(random: random),
      gate: gate,
    ),
    saves: saves,
  );

  final GameCore _core;

  /// Where the game is saved, if anywhere.
  final SavedGameRepository? saves;

  /// The seat configuration, for Play Again.
  List<SeatConfig> get seats => [
    for (final p in _core.state.value.players)
      (color: p.color, name: p.name, kind: p.kind, aiLevel: p.aiLevel),
  ];

  /// Starts the clock; [remaining] continues a saved turn.
  void start({Duration? remaining}) => _core.start(remaining: remaining);

  @override
  ValueListenable<GameState> get state => _core.state;

  @override
  ValueListenable<int> get remainingMs => _core.remainingMs;

  @override
  Stream<List<GameEvent>> get events => _core.events;

  @override
  Set<PlayerColor> get controlledColors => {
    for (final p in _core.state.value.players)
      if (p.kind == PlayerKind.human) p.color,
  };

  @override
  bool get canPause => true;

  /// True while paused.
  bool get isPaused => _core.isPaused;

  @override
  Future<RuleError?> requestRoll() async {
    final p = _core.state.value.currentPlayer;
    if (p.kind != PlayerKind.human) return RuleError.notYourTurn;
    return _core.roll(p.id);
  }

  @override
  Future<RuleError?> requestMove(int tokenId) async {
    final p = _core.state.value.currentPlayer;
    if (p.kind != PlayerKind.human) return RuleError.notYourTurn;
    return _core.move(p.id, tokenId);
  }

  @override
  void bindAnimationGate(AnimationGate gate) => _core.gate = gate;

  @override
  void pause() => _core.pause();

  @override
  void resume() => _core.resume();

  @override
  Future<void> dispose() async => _core.dispose();

  void _onSettled(GameState state, int remainingMs) {
    final repo = saves;
    if (repo == null) return;
    unawaited(
      state.isOver
          ? repo.clear()
          : repo.save(state, Duration(milliseconds: remainingMs)),
    );
  }
}
