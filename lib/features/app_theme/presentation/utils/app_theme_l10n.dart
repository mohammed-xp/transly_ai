import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/app_theme_mode.dart';

ThemeMode materialThemeMode(AppThemeMode mode) => switch (mode) {
  AppThemeMode.light => ThemeMode.light,
  AppThemeMode.dark => ThemeMode.dark,
  AppThemeMode.system => ThemeMode.system,
};

String appThemeModeLabel(BuildContext context, AppThemeMode mode) {
  final l10n = AppLocalizations.of(context)!;
  return switch (mode) {
    AppThemeMode.light => l10n.appThemeLight,
    AppThemeMode.dark => l10n.appThemeDark,
    AppThemeMode.system => l10n.appThemeSystem,
  };
}
