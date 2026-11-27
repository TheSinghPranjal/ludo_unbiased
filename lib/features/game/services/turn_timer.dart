import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:ludo_unbiased/core/constants/timing.dart';
import 'package:ludo_unbiased/core/utils/clock.dart';

/// The 30-second turn timer (spec §1.3).
///
/// It holds one deadline. [start] sets it to the full limit (a new turn or
/// an extra roll); rolling keeps it, so rolling and choosing share the same
/// 30 seconds. [remainingMs] updates ten times a second for the ring.
class TurnTimer {
  /// Creates a timer that calls [onExpire] when the deadline passes.
  TurnTimer({
    required this.onExpire,
    this.clock = const GameClock(),
    this.limit = Timing.turn,
  });

  /// Called once per deadline, when it passes.
  final void Function() onExpire;

  /// Time source.
  final GameClock clock;

  /// The full turn length.
  final Duration limit;

  /// Milliseconds left; 0 when stopped.
  final ValueNotifier<int> remainingMs = ValueNotifier(0);

  Timer? _expiry;
  Timer? _ticker;
  int? _deadline;
  int? _pausedRemaining;

  /// True while counting down.
  bool get isRunning => _deadline != null;

  /// True while paused.
  bool get isPaused => _pausedRemaining != null;

  /// Milliseconds left right now.
  int get remaining =>
      _pausedRemaining ??
      (_deadline == null ? 0 : max(0, _deadline! - clock.nowMs()));

  /// Starts a fresh countdown of [remaining] (the full limit by default).
  void start([Duration? remaining]) {
    cancel();
    _arm((remaining ?? limit).inMilliseconds);
  }

  /// Stops counting and keeps the time left.
  void pause() {
    if (!isRunning) return;
    final left = remaining;
    cancel();
    _pausedRemaining = left;
    remainingMs.value = left;
  }

  /// Continues from where [pause] stopped.
  void resume() {
    final left = _pausedRemaining;
    if (left == null) return;
    _pausedRemaining = null;
    _arm(left);
  }

  /// Stops the timer without firing.
  void cancel() {
    _expiry?.cancel();
    _ticker?.cancel();
    _expiry = null;
    _ticker = null;
    _deadline = null;
    _pausedRemaining = null;
    remainingMs.value = 0;
  }

  /// Stops the timer and releases the notifier.
  void dispose() {
    cancel();
    remainingMs.dispose();
  }

  void _arm(int ms) {
    _deadline = clock.nowMs() + ms;
    remainingMs.value = ms;
    _expiry = clock.after(Duration(milliseconds: ms), () {
      _ticker?.cancel();
      _ticker = null;
      _expiry = null;
      _deadline = null;
      remainingMs.value = 0;
      onExpire();
    });
    _ticker = clock.every(const Duration(milliseconds: 100), (_) {
      remainingMs.value = remaining;
    });
  }
}
