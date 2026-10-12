import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Paints the Transly mark (two interlocking rings) from the design SVG.
///
/// Source viewBox is 100×100; the canvas is scaled to fit whatever size the
/// [CustomPaint] provides. Kept in-code (no `flutter_svg`, no asset) so the mark
/// scales crisply and can be tinted per surface.
///
/// [color] paints the front ring. [secondaryColor] paints the back ring; when
/// omitted it falls back to [color] at half opacity, as on the launcher icon.
class TranslyGlyphPainter extends CustomPainter {
  const TranslyGlyphPainter({this.color = Colors.white, this.secondaryColor});

  final Color color;
  final Color? secondaryColor;

  static const double _viewBox = 100;
  static const Offset _frontCenter = Offset(38, 50);
  static const Offset _backCenter = Offset(62, 50);
  static const double _outerRadius = 28;
  static const double _innerRadius = 16;
  // Each ring breaks where the other crosses over it, leaving a 4-unit gap on
  // either side of the 12-unit band.
  static const double _cutOuterRadius = 32;
  static const double _cutInnerRadius = 12;

  static final Path _frontRing = _wovenRing(
    center: _frontCenter,
    crossing: _backCenter,
    crossingHalf: const Rect.fromLTWH(0, 50, _viewBox, 50),
  );
  static final Path _backRing = _wovenRing(
    center: _backCenter,
    crossing: _frontCenter,
    crossingHalf: const Rect.fromLTWH(0, 0, _viewBox, 50),
  );

  static Path _annulus(Offset center, double outer, double inner) => Path()
    ..fillType = PathFillType.evenOdd
    ..addOval(Rect.fromCircle(center: center, radius: outer))
    ..addOval(Rect.fromCircle(center: center, radius: inner));

  static Path _wovenRing({
    required Offset center,
    required Offset crossing,
    required Rect crossingHalf,
  }) => Path.combine(
    PathOperation.difference,
    _annulus(center, _outerRadius, _innerRadius),
    Path.combine(
      PathOperation.intersect,
      _annulus(crossing, _cutOuterRadius, _cutInnerRadius),
      Path()..addRect(crossingHalf),
    ),
  );

  @override
  void paint(Canvas canvas, Size size) {
    // Uniform scale on the smaller side so a non-square host can't distort it.
    final scale = math.min(size.width, size.height) / _viewBox;
    canvas
      ..save()
      ..scale(scale)
      ..translate(_viewBox / 2, _viewBox / 2)
      ..rotate(-math.pi / 4)
      ..translate(-_viewBox / 2, -_viewBox / 2)
      ..drawPath(_frontRing, Paint()..color = color)
      ..drawPath(
        _backRing,
        Paint()..color = secondaryColor ?? color.withValues(alpha: 0.5),
      )
      ..restore();
  }

  @override
  bool shouldRepaint(TranslyGlyphPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.secondaryColor != secondaryColor;
}
