import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/translation_tone.dart';

/// Caption + row of tone pills. Controlled by the parent: [selected] highlights
/// a pill and [onSelected] reports taps. While [enabled] is false (offline, no
/// tone-aware source yet) the chips stay visible but dimmed and inert (design
/// `02 · Translate`).
class ToneSelector extends StatelessWidget {
  const ToneSelector({
    super.key,
    required this.tones,
    required this.selected,
    required this.enabled,
    required this.onSelected,
  });

  final List<TranslationTone> tones;
  final TranslationTone selected;
  final bool enabled;
  final ValueChanged<TranslationTone> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final c = context.palette;

    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 2, 4, AppDimens.spaceS),
            child: Text(
              l10n.translateToneCaption,
              style: textTheme.titleSmall?.copyWith(color: c.textMuted),
            ),
          ),
          Wrap(
            spacing: AppDimens.spaceS,
            runSpacing: AppDimens.spaceS,
            children: [
              for (final tone in tones)
                _ToneChip(
                  label: tone.name,
                  selected: tone == selected,
                  onTap: enabled ? () => onSelected(tone) : null,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ToneChip extends StatelessWidget {
  const _ToneChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;

  /// Null while the selector is disabled — chip renders without ink response.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final c = context.palette;
    final radius = BorderRadius.circular(AppDimens.radiusPill);

    final Color bg;
    final Color fg;
    Border? border;
    if (selected) {
      bg = c.coral;
      fg = Colors.white;
    } else {
      bg = c.surface;
      fg = c.textSecondary;
      border = Border.all(color: c.border);
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
