import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ludo_unbiased/app/theme/app_theme.dart';
import 'package:ludo_unbiased/app/theme/board_palette.dart';
import 'package:ludo_unbiased/core/constants/board_constants.dart';
import 'package:ludo_unbiased/features/game/models/game_state.dart';
import 'package:ludo_unbiased/features/game/models/player_color.dart';
import 'package:ludo_unbiased/features/game/models/token.dart';
import 'package:ludo_unbiased/features/game/rules/board_map.dart';
import 'package:ludo_unbiased/features/game/rules/safe_cells.dart';

/// Centre of [t] in cell units (row, col).
(double, double) tokenCentre(Token t) {
  if (t.isInBase) return BoardMap.yardSlot(t.color, t.id);
  final c = BoardMap.cellFor(t.color, t.rel);
  return (c.row + 0.5, c.col + 0.5);
}

/// A plain board drawn straight from the §1.1 geometry. Tapping a movable
/// token reports its id; legality is decided by the caller's legal moves.
class BasicBoard extends StatelessWidget {
  /// Creates the board.
  const BasicBoard({
    required this.state,
    required this.movable,
    required this.onTokenTap,
    super.key,
  });

  /// The state to draw.
  final GameState state;

  /// Ids of the current player's tokens that can move.
  final Set<int> movable;

  /// Called with a movable token's id when it is tapped.
  final ValueChanged<int> onTokenTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.board;
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, box) {
          final cell = box.maxWidth / BoardConstants.gridSize;
          return GestureDetector(
            onTapUp: (d) => _tap(d.localPosition, cell),
            child: CustomPaint(
              size: Size.square(box.maxWidth),
              painter: _BoardPainter(state, movable, palette),
            ),
          );
        },
      ),
    );
  }

  void _tap(Offset p, double cell) {
    int? best;
    var bestDist = double.infinity;
    for (final t in state.tokensOf(state.currentColor)) {
      if (!movable.contains(t.id)) continue;
      final (r, c) = tokenCentre(t);
      final d = (Offset(c * cell, r * cell) - p).distance;
      if (d < bestDist && d < cell * 0.9) {
        bestDist = d;
        best = t.id;
      }
    }
    if (best != null) onTokenTap(best);
  }
}

class _BoardPainter extends CustomPainter {
  _BoardPainter(this.state, this.movable, this.palette);

  final GameState state;
  final Set<int> movable;
  final BoardPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.width / BoardConstants.gridSize;
    Rect cellRect(int r, int col) =>
        Rect.fromLTWH(col * c, r * c, c, c).deflate(c * 0.02);
    final fill = Paint();
    canvas.drawRect(Offset.zero & size, fill..color = palette.board);

    for (final color in PlayerColor.values) {
      final o = color.yardOrigin;
      final yard = Rect.fromLTWH(o.col * c, o.row * c, 6 * c, 6 * c);
      canvas
        ..drawRect(yard, fill..color = palette.of(color))
        ..drawRRect(
          RRect.fromRectAndRadius(yard.deflate(c), Radius.circular(c * 0.5)),
          fill..color = palette.inner,
        );
      for (var id = 0; id < 4; id++) {
        final (r, col) = BoardMap.yardSlot(color, id);
        canvas.drawCircle(
          Offset(col * c, r * c),
          c * 0.58,
          Paint()
            ..color = palette.of(color)
            ..style = PaintingStyle.stroke
            ..strokeWidth = c * 0.07,
        );
      }
    }
    for (final (i, cell) in BoardConstants.track.indexed) {
      final start = PlayerColor.values.where((p) => p.startIndex == i);
      fill.color = start.isEmpty ? palette.cell : palette.of(start.first);
      final rect = cellRect(cell.row, cell.col);
      canvas.drawRect(rect, fill);
      if (SafeCells.isSafe(i)) {
        _star(
          canvas,
          rect.center,
          c * 0.34,
          start.isEmpty ? palette.star : Colors.white,
        );
      }
    }
    for (final color in PlayerColor.values) {
      for (final cell in color.homeColumn) {
        canvas.drawRect(
          cellRect(cell.row, cell.col),
          fill..color = palette.of(color),
        );
      }
    }
    final mid = Offset(7.5 * c, 7.5 * c);
    Offset pt(double r, double col) => Offset(col * c, r * c);
    final tris = {
      PlayerColor.red: [pt(9, 6), pt(9, 9)],
      PlayerColor.blue: [pt(6, 6), pt(9, 6)],
      PlayerColor.yellow: [pt(6, 6), pt(6, 9)],
      PlayerColor.green: [pt(6, 9), pt(9, 9)],
    };
    for (final MapEntry(key: color, value: e) in tris.entries) {
      final path = Path()
        ..moveTo(e[0].dx, e[0].dy)
        ..lineTo(e[1].dx, e[1].dy)
        ..lineTo(mid.dx, mid.dy)
        ..close();
      canvas.drawPath(path, fill..color = palette.of(color));
    }

    final groups = <(double, double), List<Token>>{};
    for (final t in state.tokens) {
      groups.putIfAbsent(tokenCentre(t), () => []).add(t);
    }
    for (final MapEntry(key: (r, col), value: tokens) in groups.entries) {
      for (final (k, t) in tokens.indexed) {
        final spread = tokens.length == 1 ? 0.0 : 0.18;
        final a = 2 * pi * k / tokens.length;
        final centre = Offset(
          (col + spread * cos(a)) * c,
          (r + spread * sin(a)) * c,
        );
        _token(canvas, centre, c * (tokens.length == 1 ? 0.36 : 0.28), t);
      }
    }
  }

  void _token(Canvas canvas, Offset at, double r, Token t) {
    final isMovable = t.color == state.currentColor && movable.contains(t.id);
    if (isMovable) {
      canvas.drawCircle(
        at,
        r * 1.45,
        Paint()
          ..color = palette.of(t.color)
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.22,
      );
    }
    canvas
      ..drawCircle(at, r, Paint()..color = palette.of(t.color))
      ..drawCircle(
        at,
        r,
        Paint()
          ..color = palette.tokenRim ?? Colors.black26
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.12,
      );
    final tp = TextPainter(
      text: TextSpan(
        text: t.color.symbol,
        style: TextStyle(color: palette.onToken(t.color), fontSize: r * 0.9),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at - Offset(tp.width / 2, tp.height / 2));
  }

  void _star(Canvas canvas, Offset c, double r, Color color) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final a = -pi / 2 + i * pi / 5;
      final rr = i.isEven ? r : r * 0.45;
      final p = c + Offset(rr * cos(a), rr * sin(a));
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.14,
    );
  }

  @override
  bool shouldRepaint(_BoardPainter old) =>
      old.state != state || old.movable != movable || old.palette != palette;
}
