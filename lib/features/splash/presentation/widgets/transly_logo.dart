import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'transly_glyph_painter.dart';

/// The gradient logo tile with the white translate glyph (design `00 · Splash`).
///
/// Splash-specific sizes (104 tile, 30 radius, 54 glyph) are not in `AppDimens`,
/// so they live here as named constants rather than polluting global tokens.
class TranslyLogo extends StatelessWidget {
  const TranslyLogo({super.key});

  static const double _tileSize = 104;
  static const double _tileRadius = 30;
  static const double _glyphSize = 54;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: _tileSize,
      height: _tileSize,
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(_tileRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.deep.withValues(alpha: isDark ? 0.5 : 0.32),
            blurRadius: isDark ? 54 : 50,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      child: const Center(
        child: SizedBox(
          width: _glyphSize,
          height: _glyphSize,
          child: CustomPaint(painter: TranslyGlyphPainter()),
        ),
      ),
    );
  }
}
