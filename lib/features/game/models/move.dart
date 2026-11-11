import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ludo_unbiased/features/game/models/token.dart';

part 'move.freezed.dart';
part 'move.g.dart';

/// One legal move for the current player's current dice.
@freezed
abstract class Move with _$Move {
  /// Creates a move.
  const factory Move({
    required int tokenId,
    required int fromRel,
    required int toRel,

    /// Opponent tokens sent back to base by this move.
    @Default(<TokenRef>[]) List<TokenRef> captures,

    /// True when the token leaves base onto its start cell.
    @Default(false) bool entersBase,

    /// True when the token lands exactly on HOME.
    @Default(false) bool reachesHome,

    /// True when the destination is a safe cell or the home column.
    @Default(false) bool landsSafe,
  }) = _Move;

  const Move._();

  /// Reads a move written by `toJson`.
  factory Move.fromJson(Map<String, dynamic> json) => _$MoveFromJson(json);

  /// True when the move captures at least one token.
  bool get isCapture => captures.isNotEmpty;
}
