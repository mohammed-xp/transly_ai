import 'package:flutter/material.dart';

/// Three bouncing dots shown next to the "translating" label in the output
/// card's header while a translation is in flight (design `02b · Translating`).
class TranslatingDots extends StatefulWidget {
  const TranslatingDots({super.key, required this.color});

  final Color color;

  @override
  State<TranslatingDots> createState() => _TranslatingDotsState();
}

class _TranslatingDotsState extends State<TranslatingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _delays = [0.0, 0.2 / 1.2, 0.4 / 1.2];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < _delays.length; i++) ...[
              if (i > 0) const SizedBox(width: 3),
              _Dot(bounce: _bounceAt(i), color: widget.color),
            ],
          ],
        );
      },
    );
  }

  // Mirrors the CSS keyframes (0%/60%/100% => rest, 30% => peak) rather than
  // a smooth sine, so the pause at rest matches the design's bounce timing.
  double _bounceAt(int index) {
    final phase = (_controller.value + _delays[index]) % 1.0;
    if (phase <= 0.3) return phase / 0.3;
    if (phase <= 0.6) return 1 - (phase - 0.3) / 0.3;
    return 0;
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.bounce, required this.color});

  final double bounce;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, -5 * bounce),
      child: Opacity(
        opacity: 0.45 + 0.55 * bounce,
        child: Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}
