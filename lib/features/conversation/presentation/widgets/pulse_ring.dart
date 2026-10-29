import 'package:flutter/material.dart';

/// The disc that swells and fades behind the mic while it listens (design
/// `Conversation v2`, `tlpulse`). Fills its parent.
class PulseRing extends StatefulWidget {
  const PulseRing({super.key, required this.color});

  final Color color;

  @override
  State<PulseRing> createState() => _PulseRingState();
}

class _PulseRingState extends State<PulseRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final phase = _controller.value;
        final out = Curves.easeOut.transform(
          phase < 0.5 ? phase / 0.5 : 1 - (phase - 0.5) / 0.5,
        );
        return Transform.scale(
          scale: 1 + 0.18 * out,
          child: Opacity(opacity: 0.5 * (1 - out), child: child),
        );
      },
      child: DecoratedBox(
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}
