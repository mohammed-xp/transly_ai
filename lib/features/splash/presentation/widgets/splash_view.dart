import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../l10n/app_localizations.dart';
import 'translate_glyph_painter.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appNameColor = Theme.of(context).colorScheme.onSurface;
    final accentColor = isDark ? AppColors.accentDark2 : AppColors.primary;
    final taglineColor =
        isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final spinnerTrackColor =
        isDark ? AppColors.borderDark : AppColors.spinnerTrackLight;
    final spinnerColor = isDark ? AppColors.accentDark : AppColors.primary;
    final poweredByColor =
        isDark ? AppColors.iconLineDark : AppColors.disabledLight;
    final blobColor = isDark ? AppColors.accentDark : AppColors.primary;
    final blobOpacity = isDark ? 0.4 : 0.10;
    final blobOpacity2 = isDark ? 0.22 : 0.08;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -120,
            right: -90,
            child: _GlowBlob(size: 300, color: blobColor, opacity: blobOpacity),
          ),
          Positioned(
            bottom: -110,
            left: -90,
            child: _GlowBlob(
              size: 280,
              color: AppColors.gradientMid,
              opacity: blobOpacity2,
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: AppDimens.splashLogoSize,
                  height: AppDimens.splashLogoSize,
                  decoration: BoxDecoration(
                    gradient: AppColors.brandGradient,
                    borderRadius: BorderRadius.circular(AppDimens.radius4XL),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gradientMid
                            .withValues(alpha: isDark ? 0.5 : 0.32),
                        blurRadius: 50,
                        offset: const Offset(0, 24),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 54,
                      height: 54,
                      child: CustomPaint(
                        painter: TranslateGlyphPainter(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.space2XL),
                Text.rich(
                  TextSpan(
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.34,
                      color: appNameColor,
                    ),
                    children: [
                      const TextSpan(text: 'Transly'),
                      TextSpan(text: ' AI', style: TextStyle(color: accentColor)),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.spaceS),
                Text(
                  l10n.splashTagline,
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 15,
                    color: taglineColor,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 70,
            left: 0,
            right: 0,
            child: Column(
              children: [
                SizedBox(
                  width: AppDimens.spinnerSize,
                  height: AppDimens.spinnerSize,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    backgroundColor: spinnerTrackColor,
                    valueColor: AlwaysStoppedAnimation(spinnerColor),
                  ),
                ),
                const SizedBox(height: AppDimens.spaceL),
                Text(
                  l10n.poweredByAi,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 12,
                    letterSpacing: 0.04,
                    color: poweredByColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.size, required this.color, required this.opacity});

  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: opacity), color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}
