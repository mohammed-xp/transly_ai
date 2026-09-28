import 'package:flutter/material.dart';

/// The design's four-point sparkle (plan card, Pro upgrade, paywall), painted
/// from its 24×24 SVG path. `Icons.auto_awesome` is a three-star cluster, not
/// this glyph.
class SparkleIcon extends StatelessWidget {
  const SparkleIcon({super.key, required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _SparklePainter(color),
    );
  }
}

class _SparklePainter extends CustomPainter {
  const _SparklePainter(this.color);

  final Color color;

  static const double _viewBox = 24;

  // M12 2l2.2 7.8L22 12l-7.8 2.2L12 22l-2.2-7.8L2 12l7.8-2.2z
  static final Path _path = Path()
    ..moveTo(12, 2)
    ..lineTo(14.2, 9.8)
    ..lineTo(22, 12)
    ..lineTo(14.2, 14.2)
    ..lineTo(12, 22)
    ..lineTo(9.8, 14.2)
    ..lineTo(2, 12)
    ..lineTo(9.8, 9.8)
    ..close();

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / _viewBox;
    canvas
      ..save()
      ..scale(scale)
      ..drawPath(_path, Paint()..color = color)
      ..restore();
  }

  @override
  bool shouldRepaint(_SparklePainter oldDelegate) => oldDelegate.color != color;
}
