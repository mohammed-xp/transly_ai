import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';

/// Three shimmering placeholder lines shown in the output card while a
/// translation is in flight, replacing the stale previous result rather than
/// leaving it on screen next to a spinner (design `02b · Translating`).
class TranslationSkeleton extends StatefulWidget {
  const TranslationSkeleton({super.key, required this.textDirection});

  final TextDirection textDirection;

  @override
  State<TranslationSkeleton> createState() => _TranslationSkeletonState();
}

class _TranslationSkeletonState extends State<TranslationSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _widths = [1.0, 0.88, 0.56];
  static const _delays = [0.0, 0.15 / 1.4, 0.3 / 1.4];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.palette;
    final trailingAlignment = widget.textDirection == TextDirection.rtl
        ? Alignment.centerLeft
        : Alignment.centerRight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < _widths.length; i++) ...[
          if (i > 0) const SizedBox(height: 11),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final phase = (_controller.value + _delays[i]) % 1.0;
              return FractionallySizedBox(
                alignment: trailingAlignment,
                widthFactor: _widths[i],
                child: _ShimmerBar(
                  phase: phase,
                  base: c.skeletonBase,
                  highlight: c.skeletonHighlight,
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}

class _ShimmerBar extends StatelessWidget {
  const _ShimmerBar({
    required this.phase,
    required this.base,
    required this.highlight,
  });

  final double phase;
  final Color base;
  final Color highlight;

  @override
  Widget build(BuildContext context) {
    // Sweeps the highlight band from off-screen-left to off-screen-right,
    // mirroring the CSS `background-position` slide in the design.
    final slidePercent = -1.5 + 3 * phase;
    return Container(
      height: 18,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [base, highlight, base],
          stops: const [0.0, 0.5, 1.0],
          transform: _SlidingGradientTransform(slidePercent: slidePercent),
        ),
      ),
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({required this.slidePercent});

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0, 0);
  }
}
