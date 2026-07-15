import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../l10n/app_localizations.dart';

/// Language switch bar: FROM / swap-button / TO. The centered swap button carries
/// the brand gradient (design `02 · Translate`). Swap is inert until state exists.
class LanguageBar extends StatelessWidget {
  const LanguageBar({
    super.key,
    required this.isDark,
    required this.fromLanguage,
    required this.toLanguage,
  });

  final bool isDark;
  final String fromLanguage;
  final String toLanguage;

  static const double _swapButtonSize = 42;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimens.spaceL),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusDock),
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
        children: [
          Expanded(
            child: _LanguageColumn(
              isDark: isDark,
              label: l10n.translateFrom,
              language: fromLanguage,
            ),
          ),
          _SwapButton(onTap: () {/* TODO(translate): swap languages via cubit */}),
          Expanded(
            child: _LanguageColumn(
              isDark: isDark,
              label: l10n.translateTo,
              language: toLanguage,
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageColumn extends StatelessWidget {
  const _LanguageColumn({
    required this.isDark,
    required this.label,
    required this.language,
  });

  final bool isDark;
  final String label;
  final String language;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final mutedColor = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final inkColor = isDark ? AppColors.textPrimaryDark : AppColors.inkLight;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.spaceS),
      child: Column(
        children: [
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(color: mutedColor),
          ),
          Text(
            language,
            style: textTheme.titleMedium?.copyWith(color: inkColor),
          ),
        ],
      ),
    );
  }
}

class _SwapButton extends StatelessWidget {
  const _SwapButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppDimens.radiusChipL);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: AppColors.deep.withValues(alpha: 0.32),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: const SizedBox(
            width: LanguageBar._swapButtonSize,
            height: LanguageBar._swapButtonSize,
            child: Icon(
              Icons.swap_horiz_rounded,
              size: AppDimens.iconM,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
