import 'dart:async';

import 'package:clock/clock.dart' as pkg;

/// The time source and scheduler for every game timer.
///
/// It reads `package:clock` and creates zone timers, so tests drive it with
/// `fake_async` without any special wiring.
class GameClock {
  /// Creates the clock.
  const GameClock();

  /// Milliseconds since the epoch.
  int nowMs() => pkg.clock.now().millisecondsSinceEpoch;

  /// Runs [callback] once after [delay].
  Timer after(Duration delay, void Function() callback) =>
      Timer(delay, callback);

  /// Runs [callback] every [period].
  Timer every(Duration period, void Function(Timer) callback) =>
      Timer.periodic(period, callback);

  /// A future that completes after [delay].
  Future<void> delay(Duration delay) => Future<void>.delayed(delay);
}
