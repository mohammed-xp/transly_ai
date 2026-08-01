import 'package:flutter/material.dart';

/// Draws the Transly AI brand glyph (translate "A" + accent mark) from the
/// design system's 24x24 outline icon, scaled to fit [size].
class TranslateGlyphPainter extends CustomPainter {
  const TranslateGlyphPainter({required this.color, this.strokeWidth = 2});

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 24, size.height / 24);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final letterA = Path()
      ..moveTo(4, 5)
      ..lineTo(11, 5)
      ..moveTo(7.5, 5)
      ..lineTo(7.5, 7)
      ..cubicTo(7.5, 10.5, 5.5, 13, 3.5, 14.5)
      ..moveTo(5, 9)
      ..cubicTo(5.8, 11.2, 7.6, 12.9, 9.8, 13.8);

    final accentMark = Path()
      ..moveTo(12.5, 20)
      ..lineTo(16.1, 11)
      ..lineTo(19.7, 20)
      ..moveTo(14, 16.4)
      ..lineTo(18.4, 16.4);

    canvas.drawPath(letterA, paint);
    canvas.drawPath(accentMark, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant TranslateGlyphPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}
