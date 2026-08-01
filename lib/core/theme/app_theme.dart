import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_dimens.dart';
import 'app_palette.dart';
import 'app_typography.dart';

/// App themes built from the design tokens. Source: `Transly-AI-Design-System.md`.
abstract final class AppTheme {
  static ThemeData get light => _build(
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.gradientStart,
        background: AppColors.backgroundLight,
        surface: AppColors.surfaceLight,
        chip: AppColors.chipBgLight,
        border: AppColors.borderLight,
        divider: AppColors.dividerLight,
        textPrimary: AppColors.inkLight,
        textSecondary: AppColors.textSecondaryLight,
        textMuted: AppColors.textMutedLight,
        toggleTrackOff: AppColors.toggleTrackOffLight,
        palette: AppPalette.light,
      );

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        primary: AppColors.accentDark,
        secondary: AppColors.accentDark2,
        background: AppColors.backgroundDark,
        surface: AppColors.surfaceDark,
        chip: AppColors.chipBgDark,
        border: AppColors.borderDark,
        divider: AppColors.borderDark,
        textPrimary: AppColors.textPrimaryDark,
        textSecondary: AppColors.textSecondaryDark,
        textMuted: AppColors.textMutedDark,
        toggleTrackOff: AppColors.toggleTrackOffDark,
        palette: AppPalette.dark,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color primary,
    required Color secondary,
    required Color background,
    required Color surface,
    required Color chip,
    required Color border,
    required Color divider,
    required Color textPrimary,
    required Color textSecondary,
    required Color textMuted,
    required Color toggleTrackOff,
    required AppPalette palette,
  }) {
    final textTheme = AppTypography.textTheme(textPrimary);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      extensions: [palette],
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: Colors.white,
        secondary: secondary,
        onSecondary: Colors.white,
        surface: surface,
        onSurface: textPrimary,
        onSurfaceVariant: textSecondary,
        surfaceContainerHighest: chip,
        outline: border,
        outlineVariant: divider,
        error: AppColors.error,
        onError: Colors.white,
      ),
      dividerTheme: DividerThemeData(color: divider, space: 1, thickness: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineLarge,
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
          side: BorderSide(color: border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: primary.withValues(alpha: 0.4),
          disabledForegroundColor: Colors.white,
          minimumSize: const Size.fromHeight(AppDimens.buttonHeight),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusButton),
          ),
          textStyle: textTheme.titleMedium?.copyWith(color: Colors.white),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimens.spaceL,
          vertical: AppDimens.spaceM,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: textMuted),
        border: _inputBorder(border),
        enabledBorder: _inputBorder(border),
        focusedBorder: _inputBorder(primary),
        errorBorder: _inputBorder(AppColors.error),
        focusedErrorBorder: _inputBorder(AppColors.error),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: primary,
        side: BorderSide(color: border),
        labelStyle: textTheme.titleSmall?.copyWith(color: textSecondary),
        secondaryLabelStyle: textTheme.titleSmall?.copyWith(color: Colors.white),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.spaceL,
          vertical: 9,
        ),
        shape: const StadiumBorder(),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? primary : toggleTrackOff,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusInput),
        borderSide: BorderSide(color: color),
      );
}
