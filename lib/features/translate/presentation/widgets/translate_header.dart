import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../l10n/app_localizations.dart';

/// Translate screen header: kicker + "Transly" title on the leading side, an
/// "AI Pro" plan badge on the trailing side (design `02 · Translate`).
class TranslateHeader extends StatelessWidget {
  const TranslateHeader({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final mutedColor = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final inkColor = isDark ? AppColors.textPrimaryDark : AppColors.inkLight;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.spaceXL,
        6,
        AppDimens.spaceXL,
        AppDimens.spaceM,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.translateKicker,
                  style: textTheme.labelMedium?.copyWith(color: mutedColor),
                ),
                Text(
                  'Transly', // brand name — not localized
                  style: textTheme.headlineLarge?.copyWith(color: inkColor),
                ),
              ],
            ),
          ),
          _AiProBadge(isDark: isDark, label: l10n.translateAiPro),
        ],
      ),
    );
  }
}

class _AiProBadge extends StatelessWidget {
  const _AiProBadge({required this.isDark, required this.label});

  final bool isDark;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final dot = isDark ? AppColors.accentDark : AppColors.primary;
    final labelColor = isDark ? AppColors.textPrimaryDark : AppColors.inkLight;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        border: Border.all(color: border),
        boxShadow: isDark
            ? null
            : const [
                BoxShadow(
                  color: AppColors.cardShadowLight,
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: textTheme.titleSmall?.copyWith(color: labelColor),
          ),
        ],
      ),
    );
  }
}
