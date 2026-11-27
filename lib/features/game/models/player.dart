import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ludo_unbiased/features/game/models/player_color.dart';

part 'player.freezed.dart';
part 'player.g.dart';

/// Stable identifier for a seat's occupant.
typedef PlayerId = String;

/// Who controls a seat.
enum PlayerKind {
  /// A person on this device.
  human,

  /// The computer, run by whichever device owns the engine.
  ai,

  /// A person on another device in an online game.
  remote,
}

/// AI strength.
enum AiLevel {
  /// Picks randomly among the three best moves.
  easy,

  /// Always picks the best move.
  normal,
}

/// Whether a seat's occupant is present.
enum SeatConnection {
  /// Present and playing.
  connected,

  /// Lost connection; within the reconnect grace period.
  disconnected,

  /// Left, or the grace period expired. Never comes back.
  removed,
}

/// Per-player counters shown on the Results screen.
@freezed
abstract class PlayerStats with _$PlayerStats {
  /// Creates stats; all counters start at zero.
  const factory PlayerStats({
    @Default(0) int tokensHome,
    @Default(0) int captures,
    @Default(0) int timesCaptured,
    @Default(0) int sixes,
  }) = _PlayerStats;

  /// Reads stats written by `toJson`.
  factory PlayerStats.fromJson(Map<String, dynamic> json) =>
      _$PlayerStatsFromJson(json);
}

/// One seat in a game.
@freezed
abstract class Player with _$Player {
  /// Creates a player.
  const factory Player({
    required PlayerId id,
    required PlayerColor color,
    required String name,
    required PlayerKind kind,
    AiLevel? aiLevel,
    @Default(SeatConnection.connected) SeatConnection connection,
    int? finishedRank,
    @Default(PlayerStats()) PlayerStats stats,
  }) = _Player;

  const Player._();

  /// Reads a player written by `toJson`.
  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);

  /// True once all four tokens are home.
  bool get isFinished => finishedRank != null;

  /// True after leaving or being removed.
  bool get isRemoved => connection == SeatConnection.removed;

  /// True while the player still takes turns.
  bool get isActive => !isFinished && !isRemoved;
}
