import 'package:flutter/material.dart';

import '../../../../core/domain/entities/language_entity.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../l10n/app_localizations.dart';

/// Asks before removing [language]'s downloaded model; true once confirmed.
Future<bool> confirmRemoveOfflineModel(
  BuildContext context,
  LanguageEntity language,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      final l10n = AppLocalizations.of(context)!;
      final c = context.palette;

      return AlertDialog(
        backgroundColor: c.surface,
        title: Text(
          l10n.languagePickerRemoveOfflineTitle(language.nativeName),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: c.ink,
          ),
        ),
        content: Text(
          l10n.languagePickerRemoveOfflineBody,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: c.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: c.coral),
            child: Text(l10n.languagePickerRemoveOfflineConfirm),
          ),
        ],
      );
    },
  );
  return confirmed ?? false;
}
