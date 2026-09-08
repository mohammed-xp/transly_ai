import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Semantic color tokens for the translate + splash screens, resolved once
/// per brightness and read via `context.palette` — replaces threading a
/// `bool isDark` parameter through every widget and re-deriving the same
/// light/dark pairing in each one (CLAUDE.md §A-2: shared derivation lives
/// in one place).
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.surface,
    required this.border,
    required this.ink,
    required this.textSecondary,
    required this.textMuted,
    required this.iconLine,
    required this.hint,
    required this.coral,
    required this.coralAccent,
    required this.coralLabel,
    required this.screenBackground,
    required this.inputFill,
    required this.spinnerTrack,
    required this.progressTrack,
    required this.skeletonBase,
    required this.skeletonHighlight,
    required this.cardShadow,
    required this.dockShadow,
    required this.outputGradient,
    required this.outputBorder,
    required this.actionSurface,
    required this.actionBorder,
  });

  final Color surface;
  final Color border;
  final Color ink;
  final Color textSecondary;
  final Color textMuted;
  final Color iconLine;
  final Color hint;
  final Color coral;
  final Color coralAccent;
  final Color coralLabel;

  /// Full-screen background for screens that aren't tinted by [surface]
  /// (splash, sign-in): white/`backgroundLight` in light, near-black in dark.
  final Color screenBackground;

  /// Fill for input-like surfaces (text fields, back button chip): a step
  /// off [surface] so they read as recessed rather than blending into it.
  final Color inputFill;

  final Color spinnerTrack;
  final Color progressTrack;
  final Color skeletonBase;
  final Color skeletonHighlight;

  /// Null in dark mode — surfaces there carry no drop shadow.
  final Color? cardShadow;
  final Color? dockShadow;

  final Gradient outputGradient;
  final Color outputBorder;
  final Color actionSurface;

  /// Null in light mode — the action button has no border there.
  final Color? actionBorder;

  static const light = AppPalette(
    surface: AppColors.surfaceLight,
    border: AppColors.borderLight,
    ink: AppColors.inkLight,
    textSecondary: AppColors.textSecondaryLight,
    textMuted: AppColors.textMutedLight,
    iconLine: AppColors.captionMutedLight,
    hint: AppColors.captionMutedLight,
    coral: AppColors.primary,
    coralAccent: AppColors.primary,
    coralLabel: AppColors.rtlLabelLight,
    screenBackground: AppColors.surfaceLight,
    inputFill: AppColors.backgroundLight,
    spinnerTrack: AppColors.spinnerTrackLight,
    progressTrack: AppColors.progressTrackLight,
    skeletonBase: Color(0x8CFFD8C9),
    skeletonHighlight: Color(0xE6FFFFFF),
    cardShadow: AppColors.cardShadowLight,
    dockShadow: AppColors.dockShadowLight,
    outputGradient: LinearGradient(
      begin: Alignment(-0.3, -1),
      end: Alignment(0.3, 1),
      colors: [AppColors.outputBgLight, AppColors.outputBgLight2],
    ),
    outputBorder: AppColors.tintBorderLight,
    actionSurface: AppColors.surfaceLight,
    actionBorder: null,
  );

  static final dark = AppPalette(
    surface: AppColors.surfaceDark,
    border: AppColors.borderDark,
    ink: AppColors.textPrimaryDark,
    textSecondary: AppColors.textSecondaryDark,
    textMuted: AppColors.textMutedDark,
    iconLine: AppColors.iconLineDark,
    hint: AppColors.textMutedDark,
    coral: AppColors.accentDark,
    coralAccent: AppColors.accentDark2,
    coralLabel: AppColors.accentDark2,
    screenBackground: AppColors.backgroundDark,
    inputFill: AppColors.surfaceDark,
    spinnerTrack: AppColors.borderDark,
    progressTrack: AppColors.borderDark,
    skeletonBase: Colors.white.withValues(alpha: 0.05),
    skeletonHighlight: AppColors.accentDark2.withValues(alpha: 0.22),
    cardShadow: null,
    dockShadow: null,
    outputGradient: LinearGradient(
      begin: const Alignment(-0.3, -1),
      end: const Alignment(0.3, 1),
      colors: [
        AppColors.accentDark.withValues(alpha: 0.16),
        AppColors.deep.withValues(alpha: 0.08),
      ],
    ),
    outputBorder: AppColors.accentDark.withValues(alpha: 0.32),
    actionSurface: Colors.white.withValues(alpha: 0.06),
    actionBorder: Colors.white.withValues(alpha: 0.08),
  );

  @override
  AppPalette copyWith({
    Color? surface,
    Color? border,
    Color? ink,
    Color? textSecondary,
    Color? textMuted,
    Color? iconLine,
    Color? hint,
    Color? coral,
    Color? coralAccent,
    Color? coralLabel,
    Color? screenBackground,
    Color? inputFill,
    Color? spinnerTrack,
    Color? progressTrack,
    Color? skeletonBase,
    Color? skeletonHighlight,
    Color? cardShadow,
    Color? dockShadow,
    Gradient? outputGradient,
    Color? outputBorder,
    Color? actionSurface,
    Color? actionBorder,
  }) {
    return AppPalette(
      surface: surface ?? this.surface,
      border: border ?? this.border,
      ink: ink ?? this.ink,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      iconLine: iconLine ?? this.iconLine,
      hint: hint ?? this.hint,
      coral: coral ?? this.coral,
      coralAccent: coralAccent ?? this.coralAccent,
      coralLabel: coralLabel ?? this.coralLabel,
      screenBackground: screenBackground ?? this.screenBackground,
      inputFill: inputFill ?? this.inputFill,
      spinnerTrack: spinnerTrack ?? this.spinnerTrack,
      progressTrack: progressTrack ?? this.progressTrack,
      skeletonBase: skeletonBase ?? this.skeletonBase,
      skeletonHighlight: skeletonHighlight ?? this.skeletonHighlight,
      cardShadow: cardShadow ?? this.cardShadow,
      dockShadow: dockShadow ?? this.dockShadow,
      outputGradient: outputGradient ?? this.outputGradient,
      outputBorder: outputBorder ?? this.outputBorder,
      actionSurface: actionSurface ?? this.actionSurface,
      actionBorder: actionBorder ?? this.actionBorder,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      surface: Color.lerp(surface, other.surface, t)!,
      border: Color.lerp(border, other.border, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      iconLine: Color.lerp(iconLine, other.iconLine, t)!,
      hint: Color.lerp(hint, other.hint, t)!,
      coral: Color.lerp(coral, other.coral, t)!,
      coralAccent: Color.lerp(coralAccent, other.coralAccent, t)!,
      coralLabel: Color.lerp(coralLabel, other.coralLabel, t)!,
      screenBackground: Color.lerp(
        screenBackground,
        other.screenBackground,
        t,
      )!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      spinnerTrack: Color.lerp(spinnerTrack, other.spinnerTrack, t)!,
      progressTrack: Color.lerp(progressTrack, other.progressTrack, t)!,
      skeletonBase: Color.lerp(skeletonBase, other.skeletonBase, t)!,
      skeletonHighlight: Color.lerp(
        skeletonHighlight,
        other.skeletonHighlight,
        t,
      )!,
      cardShadow: Color.lerp(cardShadow, other.cardShadow, t),
      dockShadow: Color.lerp(dockShadow, other.dockShadow, t),
      outputGradient: Gradient.lerp(outputGradient, other.outputGradient, t)!,
      outputBorder: Color.lerp(outputBorder, other.outputBorder, t)!,
      actionSurface: Color.lerp(actionSurface, other.actionSurface, t)!,
      actionBorder: Color.lerp(actionBorder, other.actionBorder, t),
    );
  }
}

extension AppPaletteX on BuildContext {
  /// The palette carried by the nearest [Theme].
  ///
  /// Falls back to [AppPalette.light] rather than throwing: a nested
  /// `Theme(data: ThemeData.light())` — or a widget test with a plain
  /// `MaterialApp` — carries no extension, and a bare null-check crash there
  /// would be a far worse failure mode than slightly-off colors. The assert
  /// still surfaces the mistake in debug builds.
  AppPalette get palette {
    final palette = Theme.of(this).extension<AppPalette>();
    assert(
      palette != null,
      'No AppPalette in this Theme — build it via AppTheme.light/AppTheme.dark.',
    );
    return palette ??
        (Theme.of(this).brightness == Brightness.dark
            ? AppPalette.dark
            : AppPalette.light);
  }
}
