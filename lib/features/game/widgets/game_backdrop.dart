import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ludo_unbiased/app/theme/scene_colors.dart';

/// The painted scene behind the Game screen: sky, clouds (or stars), rolling
/// hills, a lawn and a stone plaza under the Roll button.
class GameBackdrop extends StatelessWidget {
  /// Creates the backdrop.
  const GameBackdrop({required this.colors, super.key});

  /// Scene colours for the current theme.
  final SceneColors colors;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: CustomPaint(
      painter: _BackdropPainter(colors),
      size: Size.infinite,
    ),
  );
}

class _BackdropPainter extends CustomPainter {
  _BackdropPainter(this.c);

  final SceneColors c;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rect = Offset.zero & size;

    // Sky.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [c.skyTop, c.skyBottom],
          stops: const [0, .45],
        ).createShader(rect),
    );

    // Stars (transparent by day).
    if (c.starlight.a > 0) {
      final rnd = Random(7);
      final star = Paint()..color = c.starlight;
      for (var i = 0; i < 60; i++) {
        canvas.drawCircle(
          Offset(rnd.nextDouble() * w, rnd.nextDouble() * h * .4),
          rnd.nextDouble() * 1.4 + .4,
          star,
        );
      }
    }

    // Clouds.
    final cloud = Paint()..color = c.cloud.withValues(alpha: .9);
    void puff(double x, double y, double s) {
      for (final (dx, dy, r) in const [
        (-1.0, .15, .55),
        (-.35, -.2, .75),
        (.35, -.1, .65),
        (.95, .15, .5),
        (0.0, .25, .6),
      ]) {
        canvas.drawCircle(Offset(x + dx * s, y + dy * s), r * s, cloud);
      }
    }

    puff(w * .12, h * .1, w * .07);
    puff(w * .82, h * .06, w * .06);
    puff(w * .62, h * .2, w * .05);
    puff(w * .2, h * .27, w * .05);
    puff(w * .9, h * .3, w * .06);

    // Far hills with round trees.
    final far = Path()..moveTo(0, h * .36);
    for (var x = 0.0; x <= w; x += w / 40) {
      far.lineTo(x, h * .36 - sin(x / w * pi * 3) * h * .018);
    }
    far
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(far, Paint()..color = c.hillFar);
    final tree = Paint()..color = c.hillNear;
    for (var i = 0; i < 14; i++) {
      final x = w * (i + .5) / 14;
      final y = h * .37 - sin(x / w * pi * 3) * h * .018;
      final r = w * (.03 + (i % 3) * .008);
      canvas
        ..drawCircle(Offset(x, y), r, tree)
        ..drawCircle(Offset(x + r * .7, y + r * .3), r * .8, tree);
    }

    // Lawn.
    final lawn = Rect.fromLTRB(0, h * .4, w, h);
    canvas.drawRect(
      lawn,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [c.groundTop, c.groundBottom],
        ).createShader(lawn),
    );

    // Stone plaza under the controls.
    final plaza = Rect.fromCenter(
      center: Offset(w / 2, h * .93),
      width: w * 1.05,
      height: h * .2,
    );
    canvas
      ..drawOval(plaza.inflate(6), Paint()..color = c.plazaEdge)
      ..drawOval(plaza, Paint()..color = c.plaza);
    // Paving stones laid in staggered rows, clipped to the plaza.
    final joint = Paint()
      ..color = c.plazaEdge.withValues(alpha: .7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas
      ..save()
      ..clipPath(Path()..addOval(plaza));
    final rowH = plaza.height / 7;
    for (var r = 0; r < 7; r++) {
      final y = plaza.top + r * rowH;
      canvas.drawLine(Offset(plaza.left, y), Offset(plaza.right, y), joint);
      final stone = w / (6 + r * .6);
      for (
        var x = plaza.left + (r.isOdd ? stone / 2 : 0);
        x < plaza.right;
        x += stone
      ) {
        canvas.drawLine(Offset(x, y), Offset(x, y + rowH), joint);
      }
    }
    canvas.restore();

    // Bushes framing the bottom corners.
    final bush = Paint()..color = c.hillNear;
    for (final side in [0.0, 1.0]) {
      final x = side * w;
      final dir = side == 0 ? 1 : -1;
      for (final (dx, dy, r) in const [
        (0.0, .97, .16),
        (.1, .99, .12),
        (.03, .9, .1),
      ]) {
        canvas.drawCircle(Offset(x + dir * dx * w, h * dy), r * w, bush);
      }
      // Flowers dotted over the bush.
      for (final (dx, dy, k) in const [
        (.04, .86, 0),
        (.12, .9, 1),
        (.02, .94, 2),
        (.17, .96, 0),
        (.08, .99, 1),
      ]) {
        _flower(
          canvas,
          Offset(x + dir * dx * w, h * dy),
          w * .018,
          const [Color(0xFFFFD23F), Color(0xFFFF8FB8), Color(0xFFB9A4FF)][k],
        );
      }
    }

    // Leaves hanging into the top corners.
    for (final side in [0.0, 1.0]) {
      final x = side * w;
      final dir = side == 0 ? 1 : -1;
      for (final (dx, dy, a, r) in const [
        (.02, .0, .9, .09),
        (.08, -.005, .4, .08),
        (-.01, .04, 1.4, .08),
        (.13, .01, .1, .06),
        (.04, .07, 1.1, .06),
      ]) {
        _leaf(
          canvas,
          Offset(x + dir * dx * w, h * dy),
          dir * a,
          r * w,
          c.hillFar,
          c.hillNear,
        );
      }
    }
  }

  void _flower(Canvas canvas, Offset at, double r, Color petal) {
    final p = Paint()
      ..color = c.starlight.a > 0 ? petal.withValues(alpha: .6) : petal;
    for (var k = 0; k < 5; k++) {
      final a = k * 2 * pi / 5;
      canvas.drawCircle(at + Offset(cos(a), sin(a)) * r, r * .75, p);
    }
    canvas.drawCircle(at, r * .6, Paint()..color = const Color(0xFFFFB020));
  }

  void _leaf(
    Canvas canvas,
    Offset at,
    double angle,
    double len,
    Color light,
    Color dark,
  ) {
    final leaf = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(len * .5, -len * .32, len, 0)
      ..quadraticBezierTo(len * .5, len * .32, 0, 0)
      ..close();
    canvas
      ..save()
      ..translate(at.dx, at.dy)
      ..rotate(angle)
      ..drawPath(
        leaf,
        Paint()
          ..shader = LinearGradient(
            colors: [dark, light],
          ).createShader(Rect.fromLTWH(0, -len * .3, len, len * .6)),
      )
      ..drawLine(
        Offset.zero,
        Offset(len * .9, 0),
        Paint()
          ..color = dark
          ..strokeWidth = 1.2,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_BackdropPainter old) => old.c != c;
}
