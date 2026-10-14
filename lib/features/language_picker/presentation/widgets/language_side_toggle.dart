import 'package:flutter/material.dart';

import '../../../../core/domain/entities/language_entity.dart';
import '../../../../core/domain/entities/language_side.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../l10n/app_localizations.dart';

class LanguageSideToggle extends StatelessWidget {
  const LanguageSideToggle({
    super.key,
    required this.side,
    required this.from,
    required this.to,
    required this.onChanged,
  });

  final LanguageSide side;
  final LanguageEntity from;
  final LanguageEntity to;
  final ValueChanged<LanguageSide> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppDimens.spaceXS),
      decoration: BoxDecoration(
        color: isDark ? AppColors.chipBgDark : AppColors.chipBgLight,
        borderRadius: BorderRadius.circular(AppDimens.radiusInput),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Segment(
              label: l10n.translateFrom,
              language: from.nativeName,
              isSelected: side == LanguageSide.source,
              onTap: () => onChanged(LanguageSide.source),
            ),
          ),
          const SizedBox(width: AppDimens.spaceXS),
          Expanded(
            child: _Segment(
              label: l10n.translateTo,
              language: to.nativeName,
              isSelected: side == LanguageSide.target,
              onTap: () => onChanged(LanguageSide.target),
            ),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String language;
  final bool isSelected;
  final VoidCallback onTap;

  static const double _radius = 11;
  static const Duration _duration = Duration(milliseconds: 180);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final c = context.palette;
    final selectedFill = isDark
        ? AppColors.segmentSelectedDark
        : AppColors.surfaceLight;

    return Semantics(
      button: true,
      selected: isSelected,
      inMutuallyExclusiveGroup: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: _duration,
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isSelected
                ? selectedFill
                : selectedFill.withValues(alpha: 0),
            borderRadius: BorderRadius.circular(_radius),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? (isDark
                          ? AppColors.segmentShadowDark
                          : AppColors.segmentShadowLight)
                    : Colors.transparent,
                offset: const Offset(0, 1),
                blurRadius: 3,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? c.coral : c.textMuted,
                ),
              ),
              Text(
                language,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? c.ink : c.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
