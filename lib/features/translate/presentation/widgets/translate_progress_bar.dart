import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';

/// Thin indeterminate progress line docked to the bottom of the language bar
/// while a translation is in flight (design `02b · Translating`). The design
/// shows a static 42%-filled bar; there is no real progress signal to report,
/// so it sweeps instead of sitting still.
class TranslateProgressBar extends StatefulWidget {
  const TranslateProgressBar({super.key});

  static const double height = 3;

  @override
  State<TranslateProgressBar> createState() => _TranslateProgressBarState();
}

class _TranslateProgressBarState extends State<TranslateProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

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
    final c = context.palette;
    return SizedBox(
      height: TranslateProgressBar.height,
      child: Stack(
        children: [
          Positioned.fill(child: ColoredBox(color: c.progressTrack)),
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final x = -1.0 + 2.0 * _controller.value;
                return Align(
                  alignment: Alignment(x, 0),
                  child: FractionallySizedBox(
                    widthFactor: 0.42,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: AppColors.brandGradient,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: const SizedBox(height: TranslateProgressBar.height),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
