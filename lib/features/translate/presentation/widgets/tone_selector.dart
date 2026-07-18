import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/translation_tone.dart';

/// Caption + row of tone pills. Controlled by the parent: [selected] highlights
/// a pill and [onSelected] reports taps. While [enabled] is false (offline, no
/// tone-aware source yet) the chips stay visible but dimmed and inert (design
/// `02 · Translate`).
class ToneSelector extends StatelessWidget {
  const ToneSelector({
    super.key,
    required this.isDark,
    required this.selected,
    required this.enabled,
    required this.onSelected,
  });

  final bool isDark;
  final TranslationTone selected;
  final bool enabled;
  final ValueChanged<TranslationTone> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final captionColor =
        isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    const tones = TranslationTone.values;

    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 2, 4, AppDimens.spaceS),
            child: Text(
              l10n.translateToneCaption,
              style: textTheme.titleSmall?.copyWith(color: captionColor),
            ),
          ),
          Row(
            children: [
              for (var i = 0; i < tones.length; i++) ...[
                if (i > 0) const SizedBox(width: AppDimens.spaceS),
                _ToneChip(
                  isDark: isDark,
                  label: _toneLabel(l10n, tones[i]),
                  selected: tones[i] == selected,
                  onTap: enabled ? () => onSelected(tones[i]) : null,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _toneLabel(AppLocalizations l10n, TranslationTone tone) {
    return switch (tone) {
      TranslationTone.formal => l10n.translateToneFormal,
      TranslationTone.casual => l10n.translateToneCasual,
      TranslationTone.concise => l10n.translateToneConcise,
    };
  }
}

class _ToneChip extends StatelessWidget {
  const _ToneChip({
    required this.isDark,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final bool isDark;
  final String label;
  final bool selected;

  /// Null while the selector is disabled — chip renders without ink response.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(AppDimens.radiusPill);

    final Color bg;
    final Color fg;
    Border? border;
    if (selected) {
      bg = isDark ? AppColors.accentDark : AppColors.primary;
      fg = Colors.white;
    } else {
      bg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
      fg = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
      border = Border.all(
        color: isDark ? AppColors.borderDark : AppColors.borderLight,
      );
    }

    return Material(
      color: bg,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.spaceL,
            vertical: 9,
          ),
          decoration: BoxDecoration(borderRadius: radius, border: border),
          child: Text(
            label,
            style: textTheme.titleSmall?.copyWith(
              color: fg,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
