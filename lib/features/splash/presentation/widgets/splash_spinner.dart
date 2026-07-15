import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The 34×34 loading ring from the design: a faint full track with a brighter
/// leading arc. Static by itself — the parent wraps it in a [RotationTransition]
/// so the arc sweeps around.
class SplashSpinner extends StatelessWidget {
  const SplashSpinner({
    super.key,
    required this.trackColor,
    required this.activeColor,
  });

  final Color trackColor;
  final Color activeColor;

  static const double _size = 34;
  static const double _stroke = 3;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size,
      height: _size,
      child: CustomPaint(
        painter: _RingPainter(trackColor: trackColor, activeColor: activeColor),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.trackColor, required this.activeColor});

  final Color trackColor;
  final Color activeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final inset = SplashSpinner._stroke / 2;
    final arcRect = rect.deflate(inset);

    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = SplashSpinner._stroke
      ..strokeCap = StrokeCap.round;

    // Full faint track.
    canvas.drawArc(
      arcRect,
      0,
      2 * math.pi,
      false,
      base..color = trackColor,
    );

    // Leading quarter-turn arc, starting at the top (−90°).
    canvas.drawArc(
      arcRect,
      -math.pi / 2,
      math.pi / 2,
      false,
      base..color = activeColor,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.trackColor != trackColor ||
      oldDelegate.activeColor != activeColor;
}
