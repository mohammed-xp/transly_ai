import 'package:flutter/material.dart';

/// A soft radial glow that fades to transparent at its edge, positioned in a
/// [Stack]. Used behind branded screens (splash, onboarding-dark) as a
/// decorative coral wash. Non-interactive.
class DecorativeBlob extends StatelessWidget {
  const DecorativeBlob(
    this.color, {
    super.key,
    required this.opacity,
    required this.diameter,
    this.top,
    this.bottom,
    this.left,
    this.right,
  });

  final Color color;
  final double opacity;
  final double diameter;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: IgnorePointer(
        child: Container(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: opacity),
                color.withValues(alpha: 0),
              ],
              stops: const [0, 0.7],
            ),
          ),
        ),
      ),
    );
  }
}
