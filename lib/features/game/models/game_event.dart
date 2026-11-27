import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ludo_unbiased/core/constants/board_constants.dart';
import 'package:ludo_unbiased/features/game/models/player.dart';
import 'package:ludo_unbiased/features/game/models/player_color.dart';

part 'game_event.freezed.dart';
part 'game_event.g.dart';

/// Why a player earned another roll.
enum ExtraRollReason {
  /// Rolled a 6.
  six,

  /// Captured an opponent.
  capture,

  /// Moved a token to HOME.
  home,
}

/// Why the turn moved to the next player.
enum TurnPassReason {
  /// The move earned no extra roll.
  turnEnded,

  /// The roll left no legal move.
  noMoves,

  /// The third consecutive 6 forfeits the turn.
  threeSixes,

  /// The player's last token reached HOME.
  playerFinished,

  /// The current player was removed.
  playerRemoved,
}

/// Something that happened, in order, for animation, sound and the network.
@Freezed(unionKey: 'type')
sealed class GameEvent with _$GameEvent {
  /// The current player rolled [value].
  const factory GameEvent.diceRolled({
    required PlayerColor color,
    required int value,
  }) = DiceRolled;

  /// A token moved through [path], one absolute cell per step.
  const factory GameEvent.tokenMoved({
    required PlayerColor color,
    required int tokenId,
    required int fromRel,
    required int toRel,
    required List<BoardCell> path,
  }) = TokenMoved;

  /// Token [tokenId] of [color] was captured by [byColor] at [at].
  const factory GameEvent.tokenCaptured({
    required PlayerColor color,
    required int tokenId,
    required PlayerColor byColor,
    required BoardCell at,
  }) = TokenCaptured;

  /// A token reached HOME.
  const factory GameEvent.tokenHome({
    required PlayerColor color,
    required int tokenId,
  }) = TokenHome;

  /// [color] rolls again.
  const factory GameEvent.extraRoll({
    required PlayerColor color,
    required ExtraRollReason reason,
  }) = ExtraRoll;

  /// The turn moved from [from] to [to].
  const factory GameEvent.turnPassed({
    required PlayerColor from,
    required PlayerColor to,
    required TurnPassReason reason,
  }) = TurnPassed;

  /// [color] rolled a third consecutive 6; the roll is not played.
  const factory GameEvent.threeSixesForfeit({required PlayerColor color}) =
      ThreeSixesForfeit;

  /// All of [color]'s tokens are home; it takes [rank].
  const factory GameEvent.playerFinished({
    required PlayerColor color,
    required int rank,
  }) = PlayerFinished;

  /// [color]'s connection changed.
  const factory GameEvent.playerConnection({
    required PlayerColor color,
    required SeatConnection connection,
  }) = PlayerConnection;

  /// [color] left or was removed; its tokens leave the board.
  const factory GameEvent.playerRemoved({required PlayerColor color}) =
      PlayerRemoved;

  /// An AI took over [color]'s seat.
  const factory GameEvent.playerReplacedByAi({
    required PlayerColor color,
    required AiLevel level,
  }) = PlayerReplacedByAi;

  /// The game ended with [ranking], first place first.
  const factory GameEvent.gameOver({required List<PlayerColor> ranking}) =
      GameOver;

  /// Reads an event written by `toJson`.
  factory GameEvent.fromJson(Map<String, dynamic> json) =>
      _$GameEventFromJson(json);
}
