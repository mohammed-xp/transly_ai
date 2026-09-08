import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A faint full track with a brighter leading arc, continuously rotating.
/// House-style loader used by the splash screen and the translate output
/// card's AI badge (CLAUDE.md §A-2: shared across 2+ places lives in `core/`).
class SpinningRing extends StatefulWidget {
  const SpinningRing({
    super.key,
    required this.size,
    required this.stroke,
    required this.trackColor,
    required this.activeColor,
    required this.duration,
  });

  final double size;
  final double stroke;
  final Color trackColor;
  final Color activeColor;
  final Duration duration;

  @override
  State<SpinningRing> createState() => _SpinningRingState();
}

class _SpinningRingState extends State<SpinningRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: RingPainter(
            stroke: widget.stroke,
            trackColor: widget.trackColor,
            activeColor: widget.activeColor,
          ),
        ),
      ),
    );
  }
}

/// Draws a full faint track plus a brighter leading quarter-turn arc starting
/// at the top (−90°). Static by itself — wrap in a [RotationTransition] (see
/// [SpinningRing]) to make the arc sweep.
class RingPainter extends CustomPainter {
  const RingPainter({
    required this.stroke,
    required this.trackColor,
    required this.activeColor,
  });

  final double stroke;
  final Color trackColor;
  final Color activeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final inset = stroke / 2;
    final arcRect = rect.deflate(inset);

    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    // Full faint track.
    canvas.drawArc(arcRect, 0, 2 * math.pi, false, base..color = trackColor);

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
  bool shouldRepaint(RingPainter oldDelegate) =>
      oldDelegate.stroke != stroke ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.activeColor != activeColor;
}
