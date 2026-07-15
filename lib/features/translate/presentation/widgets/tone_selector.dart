import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../l10n/app_localizations.dart';

/// Caption + row of tone pills. The selected pill is coral-filled; selection is
/// local UI state only (design `02 · Translate`).
class ToneSelector extends StatefulWidget {
  const ToneSelector({super.key, required this.isDark});

  final bool isDark;

  @override
  State<ToneSelector> createState() => _ToneSelectorState();
}

class _ToneSelectorState extends State<ToneSelector> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final captionColor =
        widget.isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final tones = [
      l10n.translateToneFormal,
      l10n.translateToneCasual,
      l10n.translateToneConcise,
    ];

    return Column(
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
                isDark: widget.isDark,
                label: tones[i],
                selected: i == _selected,
                onTap: () => setState(() => _selected = i),
              ),
            ],
          ],
        ),
      ],
    );
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
  final VoidCallback onTap;

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
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.spaceL, vertical: 9),
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
