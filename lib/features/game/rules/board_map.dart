import 'package:ludo_unbiased/core/constants/board_constants.dart';
import 'package:ludo_unbiased/features/game/models/player_color.dart';

/// Converts a colour's relative progress into board positions.
abstract final class BoardMap {
  /// Absolute track index for [rel] (0–50) on [color]'s route:
  /// `(start + rel) % 52`.
  static int absoluteIndex(PlayerColor color, int rel) {
    RangeError.checkValueInInterval(rel, 0, BoardConstants.lastTrackRel);
    return (color.startIndex + rel) % BoardConstants.trackLength;
  }

  /// The cell a token of [color] occupies at [rel] (0–56).
  ///
  /// Main track for 0–50, the colour's home column for 51–55, and the
  /// colour's centre-triangle cell for HOME (56). Base tokens have no cell;
  /// use [yardSlot].
  static BoardCell cellFor(PlayerColor color, int rel) {
    if (rel >= 0 && rel <= BoardConstants.lastTrackRel) {
      return BoardConstants.track[absoluteIndex(color, rel)];
    }
    if (rel >= BoardConstants.firstHomeColumnRel &&
        rel < BoardConstants.homeRel) {
      return color.homeColumn[rel - BoardConstants.firstHomeColumnRel];
    }
    if (rel == BoardConstants.homeRel) return color.homeCell;
    throw RangeError.value(rel, 'rel', 'base tokens have no cell');
  }

  /// Centre of yard slot [tokenId] as (row, col) in cell units.
  ///
  /// Slots sit on cell-corner points (2,2), (2,4), (4,2), (4,4) of the yard.
  static (double, double) yardSlot(PlayerColor color, int tokenId) {
    const offsets = [(2, 2), (2, 4), (4, 2), (4, 4)];
    final o = color.yardOrigin;
    final (dr, dc) = offsets[tokenId];
    return ((o.row + dr).toDouble(), (o.col + dc).toDouble());
  }

  /// Every cell a token passes through moving from [fromRel] to [toRel],
  /// excluding the start and including the destination. Leaving base gives
  /// the single start cell.
  static List<BoardCell> path(PlayerColor color, int fromRel, int toRel) {
    if (fromRel == BoardConstants.baseRel) return [cellFor(color, 0)];
    return [for (var r = fromRel + 1; r <= toRel; r++) cellFor(color, r)];
  }
}
