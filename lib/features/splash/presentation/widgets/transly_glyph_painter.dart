import 'package:flutter/material.dart';

/// Paints the white Transly translate glyph (two strokes) from the design SVG.
///
/// Source viewBox is 24×24; the canvas is scaled to fit whatever size the
/// [CustomPaint] provides. Kept in-code (no `flutter_svg`, no asset) so the mark
/// scales crisply and stays theme-agnostic — it is always white on the gradient.
class TranslyGlyphPainter extends CustomPainter {
  const TranslyGlyphPainter({this.color = Colors.white});

  final Color color;

  static const double _viewBox = 24;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / _viewBox;
    canvas
      ..save()
      ..scale(scale);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      // Stroke width is expressed in viewBox units (matches the SVG's `2`).
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Stroke A — the CJK-style mark.
    final a = Path()
      // M4 5 h7
      ..moveTo(4, 5)
      ..relativeLineTo(7, 0)
      // M7.5 5 v2 c0 3.5 -2 6 -4 7.5
      ..moveTo(7.5, 5)
      ..relativeLineTo(0, 2)
      ..relativeCubicTo(0, 3.5, -2, 6, -4, 7.5)
      // M5 9 c.8 2.2 2.6 3.9 4.8 4.8
      ..moveTo(5, 9)
      ..relativeCubicTo(0.8, 2.2, 2.6, 3.9, 4.8, 4.8);

    // Stroke B — the "A".
    final b = Path()
      // M12.5 20 l3.6 -9 l3.6 9
      ..moveTo(12.5, 20)
      ..relativeLineTo(3.6, -9)
      ..relativeLineTo(3.6, 9)
      // M14 16.4 h4.4
      ..moveTo(14, 16.4)
      ..relativeLineTo(4.4, 0);

    canvas
      ..drawPath(a, paint)
      ..drawPath(b, paint)
      ..restore();
  }

  @override
  bool shouldRepaint(TranslyGlyphPainter oldDelegate) =>
      oldDelegate.color != color;
}
