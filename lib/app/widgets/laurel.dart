import 'package:flutter/material.dart';

/// A small laurel sprig beside the title.
class Laurel extends StatelessWidget {
  /// Creates the sprig; [mirrored] points it the other way.
  const Laurel({
    required this.color,
    required this.mirrored,
    this.width = 22,
    this.height = 40,
    super.key,
  });

  /// Leaf colour.
  final Color color;

  /// True for the right-hand sprig.
  final bool mirrored;

  /// Size.
  final double width;

  /// Size.
  final double height;

  @override
  Widget build(BuildContext context) => Transform.flip(
    flipX: mirrored,
    child: SizedBox(
      width: width,
      height: height,
      child: CustomPaint(painter: _LaurelPainter(color)),
    ),
  );
}

class _LaurelPainter extends CustomPainter {
  _LaurelPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color;
    final stem = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final w = size.width;
    final h = size.height;
    canvas.drawPath(
      Path()
        ..moveTo(w * .8, h)
        ..quadraticBezierTo(w * .1, h * .6, w * .6, 0),
      stem,
    );
    for (var k = 0; k < 4; k++) {
      final y = h * (.85 - k * .22);
      final x = w * (.42 - (k == 0 || k == 3 ? 0 : .12));
      canvas
        ..save()
        ..translate(x, y)
        ..rotate(-.6)
        ..drawOval(Rect.fromLTWH(-w * .41, -h * .088, w * .55, h * .175), p)
        ..restore();
    }
  }

  @override
  bool shouldRepaint(_LaurelPainter old) => old.color != color;
}
