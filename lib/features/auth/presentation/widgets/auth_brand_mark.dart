import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/transly_glyph_painter.dart';

/// The 60px gradient glyph tile above the sign-in headline (design `01b ·
/// Sign In`). Built on the shared [TranslyGlyphPainter] — no new glyph art.
class AuthBrandMark extends StatelessWidget {
  const AuthBrandMark({super.key});

  static const double _tileSize = 60;
  static const double _tileRadius = 18;
  static const double _glyphSize = 32;

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
            color: AppColors.deep.withValues(alpha: isDark ? 0.45 : 0.28),
            blurRadius: isDark ? 32 : 28,
            offset: const Offset(0, 12),
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
