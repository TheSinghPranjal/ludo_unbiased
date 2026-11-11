// Flame's Component.add returns FutureOr by design; adding a child is
// fire-and-forget here, and the component mounts on the next tick.
// ignore_for_file: discarded_futures

import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:ludo_unbiased/core/constants/timing.dart';
import 'package:ludo_unbiased/features/game/flame/board_layout.dart';
import 'package:ludo_unbiased/features/game/flame/fx/effects_fx.dart';
import 'package:ludo_unbiased/features/game/flame/ludo_game.dart';
import 'package:ludo_unbiased/features/game/flame/token_component.dart';
import 'package:ludo_unbiased/features/game/models/game_event.dart';

/// Plays engine events on the board, one batch after another, in order.
///
/// Each [play] completes when its batch has finished animating. While
/// anything is queued, layout leaves animating tokens alone and highlights
/// stay hidden. [flush] finishes everything at once (used when the app goes
/// to the background, where Flame stops ticking).
class AnimationQueue {
  /// Creates a queue for [game].
  AnimationQueue(this.game);

  /// The board.
  final LudoGame game;

  Future<void> _tail = Future<void>.value();
  int _pending = 0;
  bool _skip = false;
  final Set<Completer<void>> _active = {};

  /// True while a batch is queued or playing.
  bool get isBusy => _pending > 0;

  /// Plays [events] after any batches already queued.
  Future<void> play(List<GameEvent> events) {
    _pending++;
    final done = Completer<void>();
    _tail = _tail.then((_) async {
      try {
        if (!_skip) await _run(events);
      } finally {
        _pending--;
        if (_pending == 0) _skip = false;
        game.onQueueIdle();
        done.complete();
      }
    });
    return done.future;
  }

  /// Finishes every queued and running animation immediately.
  void flush() {
    if (!isBusy) return;
    _skip = true;
    for (final c in _active.toList()) {
      if (!c.isCompleted) c.complete();
    }
    _active.clear();
    for (final t in game.tokens) {
      t
        ..removeAll(t.children.whereType<Effect>())
        ..animating = false
        ..lift = 0
        ..scale = Vector2.all(1);
    }
  }

  double get _speed => game.speed;

  Future<void> _run(List<GameEvent> events) async {
    for (final e in events) {
      if (_skip) return;
      switch (e) {
        case TokenMoved():
          await _move(e);
        case TokenCaptured():
          await _capture(e);
        case TokenHome():
          await _home(e);
        default:
          break;
      }
    }
  }

  Future<void> _move(TokenMoved e) async {
    final t = game.tokenFor(e.color, e.tokenId);
    if (t == null) return;
    t
      ..animating = true
      ..size = Vector2.all(BoardLayout.tokenSize)
      ..priority = 30;
    final hop = Timing.hop.inMicroseconds / 1e6 / _speed;
    if (e.fromRel < 0) {
      t.position = BoardLayout.yardSlot(e.color, e.tokenId);
      if (!game.reduceMotion) {
        t
          ..scale = Vector2.all(0.6)
          ..add(
            ScaleEffect.to(Vector2.all(1), EffectController(duration: hop)),
          );
      }
    }
    for (final cell in e.path) {
      if (_skip) return;
      game.onStep?.call();
      await _effect(
        t,
        (done) => MoveToEffect(
          BoardLayout.centreOf(cell),
          EffectController(duration: hop),
          onComplete: done,
        ),
        hopLift: !game.reduceMotion,
        duration: hop,
      );
    }
    t
      ..lift = 0
      ..priority = 10
      ..animating = false;
  }

  Future<void> _capture(TokenCaptured e) async {
    final victim = game.tokenFor(e.color, e.tokenId);
    if (victim == null) return;
    final from = BoardLayout.centreOf(e.at);
    if (!game.reduceMotion) game.world.add(capturePuff(game.sprites, from));
    victim
      ..animating = true
      ..priority = 25
      ..size = Vector2.all(BoardLayout.tokenSize);
    final to = BoardLayout.yardSlot(e.color, e.tokenId);
    final mid = (from + to) / 2;
    final normal = Vector2(-(to.y - from.y), to.x - from.x)..normalize();
    final control = mid + normal * min(3, from.distanceTo(to) * 0.35);
    final path = Path()
      ..moveTo(from.x, from.y)
      ..quadraticBezierTo(control.x, control.y, to.x, to.y);
    final d = Timing.captureReturn.inMicroseconds / 1e6 / _speed;
    game.onCapture?.call();
    await _effect(
      victim,
      (done) => game.reduceMotion
          ? MoveToEffect(to, EffectController(duration: d), onComplete: done)
          : MoveAlongPathEffect(
              path,
              EffectController(duration: d),
              absolute: true,
              onComplete: done,
            ),
      duration: d,
    );
    victim
      ..priority = 10
      ..animating = false;
  }

  Future<void> _home(TokenHome e) async {
    final t = game.tokenFor(e.color, e.tokenId);
    if (t == null) return;
    if (!game.reduceMotion) {
      game.world.add(homeSparkle(game.sprites, t.position.clone()));
    }
    game.onHome?.call();
    final d = Timing.homeSlide.inMicroseconds / 1e6 / _speed;
    await _wait(d);
  }

  /// Adds the effect built by [build] to [t] and waits for it, or for flush.
  Future<void> _effect(
    TokenComponent t,
    Effect Function(VoidCallback done) build, {
    required double duration,
    bool hopLift = false,
  }) {
    final c = Completer<void>();
    _active.add(c);
    void done() {
      _active.remove(c);
      if (!c.isCompleted) c.complete();
    }

    t.add(build(done));
    if (hopLift) {
      t.add(_LiftEffect(t, duration));
    }
    return c.future;
  }

  Future<void> _wait(double seconds) {
    final c = Completer<void>();
    _active.add(c);
    game.world.add(
      TimerComponent(
        period: seconds,
        removeOnFinish: true,
        onTick: () {
          _active.remove(c);
          if (!c.isCompleted) c.complete();
        },
      ),
    );
    return c.future;
  }
}

/// Raises a token through a small arc over one hop.
class _LiftEffect extends Component {
  _LiftEffect(this.token, this.duration);

  final TokenComponent token;
  final double duration;
  double _t = 0;

  @override
  void update(double dt) {
    _t += dt;
    final p = (_t / duration).clamp(0.0, 1.0);
    token.lift = sin(p * pi);
    if (p >= 1) {
      token.lift = 0;
      removeFromParent();
    }
  }
}
