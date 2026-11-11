/// Every game timing from the spec, in one place.
abstract final class Timing {
  /// Time a player has for one decision chain (spec §1.3).
  static const Duration turn = Duration(seconds: 30);

  /// The timer tick sound plays during this final stretch.
  static const Duration turnWarning = Duration(seconds: 5);

  /// The ring also shows a number for this final stretch.
  static const Duration turnCountdownNumber = Duration(seconds: 10);

  /// Fixed dice tumble; never scaled by the animation speed setting.
  static const Duration diceAnimation = Duration(milliseconds: 800);

  /// Delay from roll commit to an automatic single move.
  static const Duration autoMove = Duration(milliseconds: 1120);

  /// One token hop at normal speed.
  static const Duration hop = Duration(milliseconds: 150);

  /// A captured token's flight back to base.
  static const Duration captureReturn = Duration(milliseconds: 600);

  /// A token sliding into HOME.
  static const Duration homeSlide = Duration(milliseconds: 400);

  /// Shortest AI think delay.
  static const Duration aiThinkMin = Duration(milliseconds: 600);

  /// Longest AI think delay.
  static const Duration aiThinkMax = Duration(milliseconds: 900);

  /// How long a toast stays up.
  static const Duration toast = Duration(seconds: 1);

  /// Reconnect grace period before a seat is removed.
  static const Duration reconnectGrace = Duration(seconds: 45);

  /// Heartbeat interval, both directions.
  static const Duration heartbeat = Duration(seconds: 3);

  /// A peer is disconnected after this long without traffic.
  static const Duration heartbeatTimeout = Duration(seconds: 9);
}
