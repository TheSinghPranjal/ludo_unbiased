import 'dart:async';

import 'package:flutter/services.dart';

/// Haptic feedback, gated by the Vibration setting.
class HapticsService {
  /// Creates the service; [enabled] comes from settings.
  const HapticsService({required this.enabled});

  /// False when the player turned vibration off.
  final bool enabled;

  void _run(Future<void> Function() f) {
    if (enabled) unawaited(f());
  }

  /// A button press or a token step: the lightest tick.
  void tick() => _run(HapticFeedback.selectionClick);

  /// The dice landing.
  void diceLand() => _run(HapticFeedback.lightImpact);

  /// An extra roll or a token reaching HOME.
  void reward() => _run(HapticFeedback.mediumImpact);

  /// A capture or a win.
  void heavy() => _run(HapticFeedback.heavyImpact);
}
