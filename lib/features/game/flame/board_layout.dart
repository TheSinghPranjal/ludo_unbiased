import 'package:flame/components.dart';
import 'package:ludo_unbiased/core/constants/board_constants.dart';
import 'package:ludo_unbiased/features/game/models/player_color.dart';
import 'package:ludo_unbiased/features/game/models/token.dart';
import 'package:ludo_unbiased/features/game/rules/board_map.dart';

/// Pure geometry for the Flame board. The world is 15 × 15 units: one unit
/// per cell, origin at the top-left, x to the right, y down.
abstract final class BoardLayout {
  /// World size in units.
  static const double size = BoardConstants.gridSize * 1.0;

  /// A single token's sprite size; the pawn itself is about 0.76 of a cell.
  static const double tokenSize = 1.16;

  /// Centre of the cell at [row], [col].
  static Vector2 cellCentre(int row, int col) => Vector2(col + 0.5, row + 0.5);

  /// Centre of [cell].
  static Vector2 centreOf(BoardCell cell) => cellCentre(cell.row, cell.col);

  /// Centre of yard slot [tokenId] of [color].
  static Vector2 yardSlot(PlayerColor color, int tokenId) {
    final (r, c) = BoardMap.yardSlot(color, tokenId);
    return Vector2(c, r);
  }

  /// Where [t] rests when it is alone: its yard slot, cell or HOME cell.
  static Vector2 restingPlace(Token t) => t.isInBase
      ? yardSlot(t.color, t.id)
      : centreOf(BoardMap.cellFor(t.color, t.rel));

  /// Offsets for [count] tokens sharing one place, so each stays visible.
  /// One sits centred; two sit diagonally offset; three or four cluster.
  static List<Vector2> stackOffsets(int count) => switch (count) {
    <= 1 => [Vector2.zero()],
    2 => [Vector2(-0.16, -0.12), Vector2(0.16, 0.12)],
    3 => [Vector2(-0.18, 0.1), Vector2(0.18, 0.1), Vector2(0, -0.18)],
    _ => [
      Vector2(-0.17, -0.17),
      Vector2(0.17, -0.17),
      Vector2(-0.17, 0.17),
      Vector2(0.17, 0.17),
    ],
  };

  /// Sprite size for a token in a stack of [count].
  static double stackTokenSize(int count) => switch (count) {
    <= 1 => tokenSize,
    2 => 0.95,
    _ => 0.8,
  };
}
