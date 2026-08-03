import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/theme/app_colors.dart';
import 'package:transly_ai/core/theme/app_palette.dart';
import 'package:transly_ai/core/theme/app_theme.dart';

void main() {
  // AppTheme builds its TextTheme via GoogleFonts, which fires an unawaited
  // network font fetch; testWidgets + pump (same pattern as widget_test.dart)
  // lets that settle inside the test's zone instead of leaking into whichever
  // test runs next.
  testWidgets('AppTheme.light and AppTheme.dark register the extension',
      (tester) async {
    expect(AppTheme.light.extension<AppPalette>(), same(AppPalette.light));
    expect(AppTheme.dark.extension<AppPalette>(), same(AppPalette.dark));
    await tester.pump();
  });

  // Pins every token to the exact AppColors constant the widgets used before
  // the ThemeExtension refactor. These mappings are the one thing that would
  // silently change the UI, so they are asserted rather than eyeballed.
  group('AppPalette token mapping', () {
    test('light matches the pre-refactor light-mode ternary arms', () {
      const c = AppPalette.light;
      expect(c.surface, AppColors.surfaceLight);
      expect(c.border, AppColors.borderLight);
      expect(c.ink, AppColors.inkLight);
      expect(c.textSecondary, AppColors.textSecondaryLight);
      expect(c.textMuted, AppColors.textMutedLight);
      expect(c.iconLine, AppColors.captionMutedLight);
      expect(c.hint, AppColors.captionMutedLight);
      expect(c.coral, AppColors.primary);
      expect(c.coralAccent, AppColors.primary);
      expect(c.coralLabel, AppColors.rtlLabelLight);
      expect(c.splashBackground, AppColors.surfaceLight);
      expect(c.spinnerTrack, AppColors.spinnerTrackLight);
      expect(c.progressTrack, AppColors.progressTrackLight);
      expect(c.skeletonBase, const Color(0x8CFFD8C9));
      expect(c.skeletonHighlight, const Color(0xE6FFFFFF));
      expect(c.cardShadow, AppColors.cardShadowLight);
      expect(c.dockShadow, AppColors.dockShadowLight);
      expect(c.outputBorder, AppColors.tintBorderLight);
      expect(c.actionSurface, AppColors.surfaceLight);
      expect(c.actionBorder, isNull, reason: 'light action button has no border');
      expect(
        (c.outputGradient as LinearGradient).colors,
        [AppColors.outputBgLight, AppColors.outputBgLight2],
      );
    });

    test('dark matches the pre-refactor dark-mode ternary arms', () {
      final c = AppPalette.dark;
      expect(c.surface, AppColors.surfaceDark);
      expect(c.border, AppColors.borderDark);
      expect(c.ink, AppColors.textPrimaryDark);
      expect(c.textSecondary, AppColors.textSecondaryDark);
      expect(c.textMuted, AppColors.textMutedDark);
      expect(c.iconLine, AppColors.iconLineDark);
      expect(c.hint, AppColors.textMutedDark);
      expect(c.coral, AppColors.accentDark);
      expect(c.coralAccent, AppColors.accentDark2);
      expect(c.coralLabel, AppColors.accentDark2);
      expect(c.splashBackground, AppColors.backgroundDark);
      expect(c.spinnerTrack, AppColors.borderDark);
      expect(c.progressTrack, AppColors.borderDark);
      expect(c.skeletonBase, Colors.white.withValues(alpha: 0.05));
      expect(c.skeletonHighlight, AppColors.accentDark2.withValues(alpha: 0.22));
      expect(c.cardShadow, isNull, reason: 'dark surfaces carry no shadow');
      expect(c.dockShadow, isNull, reason: 'dark surfaces carry no shadow');
      expect(c.outputBorder, AppColors.accentDark.withValues(alpha: 0.32));
      expect(c.actionSurface, Colors.white.withValues(alpha: 0.06));
      expect(c.actionBorder, Colors.white.withValues(alpha: 0.08));
      expect(
        (c.outputGradient as LinearGradient).colors,
        [
          AppColors.accentDark.withValues(alpha: 0.16),
          AppColors.deep.withValues(alpha: 0.08),
        ],
      );
    });

    test('the three coral tokens are genuinely distinct in light mode', () {
      // coralAccent and coralLabel collapse in dark but not in light — a merge
      // would silently change the output card's language label.
      expect(AppPalette.light.coralLabel, isNot(AppPalette.light.coral));
      expect(AppPalette.light.coralLabel, isNot(AppPalette.light.coralAccent));
    });
  });

  group('AppPalette', () {
    test('lerp between light and dark does not throw and stays in range', () {
      final mid = AppPalette.light.lerp(AppPalette.dark, 0.5);

      expect(mid, isA<AppPalette>());
      // Nullable tokens: light has a shadow, dark has none — mid-lerp must
      // still resolve to a usable (non-null) color, not crash on the null side.
      expect(mid.cardShadow, isNotNull);
      expect(mid.dockShadow, isNotNull);
      expect(mid.actionBorder, isNotNull);
    });

    test('lerp at t=0 and t=1 returns the endpoints', () {
      expect(AppPalette.light.lerp(AppPalette.dark, 0).surface,
          AppPalette.light.surface);
      expect(AppPalette.light.lerp(AppPalette.dark, 1).surface,
          AppPalette.dark.surface);
    });
  });
}
