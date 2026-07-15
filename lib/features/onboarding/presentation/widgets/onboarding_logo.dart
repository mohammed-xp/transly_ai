import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/transly_glyph_painter.dart';

/// The 76px logo tile on the onboarding welcome screen (design `01 · Welcome`).
///
/// Theme-aware, matching the two variants in the design:
/// - **Light:** white tile, two-tone glyph (coral mark + ink "A").
/// - **Dark:** gradient tile, white glyph.
///
/// The tile uses the shared `AppDimens.logoSize` (76); its radius (22) and glyph
/// (40) are onboarding-specific and stay local — same convention as `TranslyLogo`.
class OnboardingLogo extends StatelessWidget {
  const OnboardingLogo({super.key});

  static const double _tileRadius = 22;
  static const double _glyphSize = 40;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: AppDimens.logoSize,
      height: AppDimens.logoSize,
      decoration: BoxDecoration(
        color: isDark ? null : Colors.white,
        gradient: isDark ? AppColors.brandGradient : null,
        borderRadius: BorderRadius.circular(_tileRadius),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppColors.deep.withValues(alpha: 0.45)
                : AppColors.brandShadow.withValues(alpha: 0.32),
            blurRadius: isDark ? 44 : 40,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Center(
        child: SizedBox(
          width: _glyphSize,
          height: _glyphSize,
          child: CustomPaint(
            painter: isDark
                ? const TranslyGlyphPainter(color: Colors.white)
                : const TranslyGlyphPainter(
                    color: AppColors.deep,
                    strokeBColor: AppColors.inkLight,
                  ),
          ),
        ),
      ),
    );
  }
}
