import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../l10n/app_localizations.dart';

/// Language switch bar: FROM / swap-button / TO. The centered swap button carries
/// the brand gradient (design `02 · Translate`). Swap is inert until state exists.
class LanguageBar extends StatelessWidget {
  const LanguageBar({
    super.key,
    required this.fromLanguage,
    required this.toLanguage,
    required this.onSwap,
  });

  final String fromLanguage;
  final String toLanguage;
  final VoidCallback onSwap;

  static const double _swapButtonSize = 42;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.palette;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimens.spaceL),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusDock),
        border: Border.all(color: c.border),
        boxShadow: c.cardShadow == null
            ? null
            : [
                BoxShadow(
                  color: c.cardShadow!,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _LanguageColumn(
              label: l10n.translateFrom,
              language: fromLanguage,
            ),
          ),
          _SwapButton(onTap: onSwap),
          Expanded(
            child: _LanguageColumn(
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
    required this.label,
    required this.language,
  });

  final String label;
  final String language;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final c = context.palette;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.spaceS),
      child: Column(
        children: [
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(color: c.textMuted),
          ),
          Text(
            language,
            style: textTheme.titleMedium?.copyWith(color: c.ink),
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
