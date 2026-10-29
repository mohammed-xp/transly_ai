import 'package:flutter/material.dart';

/// Five bars rising and falling while the mic hears speech (design
/// `Conversation v2`, `tlwave`).
class VoiceWave extends StatefulWidget {
  const VoiceWave({super.key, required this.height, required this.color});

  final double height;
  final Color color;

  @override
  State<VoiceWave> createState() => _VoiceWaveState();
}

class _VoiceWaveState extends State<VoiceWave>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const int _bars = 5;
  static const double _barWidth = 3;
  static const double _gap = 3;

  /// Each bar trails the previous by 0.15s of the 0.9s cycle.
  static const double _stagger = 0.15 / 0.9;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 18% of the height at rest, 90% at the half-way peak, eased both ways.
  double _heightAt(int index) {
    final phase = (_controller.value - index * _stagger) % 1.0;
    final rise = phase < 0.5 ? phase / 0.5 : 1 - (phase - 0.5) / 0.5;
    return widget.height * (0.18 + 0.72 * Curves.easeInOut.transform(rise));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < _bars; i++) ...[
              if (i > 0) const SizedBox(width: _gap),
              Container(
                width: _barWidth,
                height: _heightAt(i),
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
