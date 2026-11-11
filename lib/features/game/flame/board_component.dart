import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:ludo_unbiased/core/constants/board_constants.dart';
import 'package:ludo_unbiased/features/game/flame/ludo_game.dart';
import 'package:ludo_unbiased/features/game/models/player_color.dart';
import 'package:ludo_unbiased/features/game/rules/safe_cells.dart';

/// The static board: yards, track, home columns, entry arrows and the
/// centre, drawn from the §1.1 geometry with the current mode's sprites.
class BoardComponent extends PositionComponent with HasGameReference<LudoGame> {
  /// Creates the board, filling the 15 × 15 world.
  BoardComponent() : super(size: Vector2.all(BoardConstants.gridSize * 1.0));

  static final Map<int, (PlayerColor, double)> _arrows = {
    for (final c in PlayerColor.values)
      (c.startIndex + BoardConstants.lastTrackRel) % BoardConstants.trackLength:
          (c, c.index * pi / 2),
  };

  @override
  void render(Canvas canvas) {
    final mode = game.mode;
    final s = game.sprites;
    final one = Vector2.all(1);
    s.get('board_bg', mode).render(canvas, size: size);
    for (final c in PlayerColor.values) {
      final o = c.yardOrigin;
      s
          .get('board_yard_${c.name}', mode)
          .render(
            canvas,
            position: Vector2(o.col.toDouble(), o.row.toDouble()),
            size: Vector2.all(6),
          );
    }
    for (final (i, cell) in BoardConstants.track.indexed) {
      final at = Vector2(cell.col.toDouble(), cell.row.toDouble());
      final start = PlayerColor.values.where((c) => c.startIndex == i);
      final arrow = _arrows[i];
      if (start.isNotEmpty) {
        s
            .get('board_cell_start_${start.first.name}', mode)
            .render(canvas, position: at, size: one);
      } else if (SafeCells.isSafe(i)) {
        s
            .get('board_cell_safe_star', mode)
            .render(canvas, position: at, size: one);
      } else if (arrow != null) {
        final (c, angle) = arrow;
        canvas
          ..save()
          ..translate(at.x + 0.5, at.y + 0.5)
          ..rotate(angle);
        s
            .get('board_arrow_${c.name}', mode)
            .render(canvas, position: Vector2.all(-0.5), size: one);
        canvas.restore();
      } else {
        s.get('board_cell', mode).render(canvas, position: at, size: one);
      }
    }
    for (final c in PlayerColor.values) {
      for (final cell in c.homeColumn) {
        s
            .get('board_home_column_${c.name}', mode)
            .render(
              canvas,
              position: Vector2(cell.col.toDouble(), cell.row.toDouble()),
              size: one,
            );
      }
    }
    s
        .get('board_centre_home', mode)
        .render(canvas, position: Vector2.all(6), size: Vector2.all(3));
  }
}
