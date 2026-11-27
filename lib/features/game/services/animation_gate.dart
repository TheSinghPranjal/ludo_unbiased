import 'package:ludo_unbiased/core/constants/timing.dart';
import 'package:ludo_unbiased/core/utils/clock.dart';
import 'package:ludo_unbiased/features/game/models/game_event.dart';

/// How the game waits for what the player sees.
///
/// The controller commits a command, hands its events to [played] and
/// settles the state only when the future completes.
// One method by design: implementations differ only in how they wait.
// ignore: one_member_abstracts
abstract interface class AnimationGate {
  /// Completes when [events] have finished playing on screen.
  Future<void> played(List<GameEvent> events);
}

/// How long [events] take to animate. The dice is fixed at 800 ms; hops,
/// captures and the HOME slide scale with [speed] (1 = normal).
Duration animationBudget(List<GameEvent> events, {double speed = 1}) {
  var ms = 0.0;
  for (final e in events) {
    ms += switch (e) {
      DiceRolled() => Timing.diceAnimation.inMilliseconds.toDouble(),
      TokenMoved(:final path) =>
        path.length * Timing.hop.inMilliseconds / speed,
      TokenCaptured() => Timing.captureReturn.inMilliseconds / speed,
      TokenHome() => Timing.homeSlide.inMilliseconds / speed,
      _ => 0,
    };
  }
  return Duration(milliseconds: ms.round());
}

/// Waits the fixed [animationBudget] without drawing anything.
///
/// Used when no board is visible (the app is in the background, or a host
/// is headless), so the game never waits on animations that cannot run.
class TimedAnimationGate implements AnimationGate {
  /// Creates a gate that waits at [speed].
  const TimedAnimationGate({this.speed = 1, this.clock = const GameClock()});

  /// Animation speed; 1 is normal.
  final double speed;

  /// Time source.
  final GameClock clock;

  @override
  Future<void> played(List<GameEvent> events) {
    final d = animationBudget(events, speed: speed);
    return d == Duration.zero ? Future<void>.value() : clock.delay(d);
  }
}
