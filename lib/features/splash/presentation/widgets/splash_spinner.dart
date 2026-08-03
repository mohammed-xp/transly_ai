import 'package:flutter/material.dart';

import '../../../../core/widgets/spinning_ring.dart';

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
        painter: RingPainter(
          stroke: _stroke,
          trackColor: trackColor,
          activeColor: activeColor,
        ),
      ),
    );
  }
}
