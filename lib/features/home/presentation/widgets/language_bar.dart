import 'package:flutter/material.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/app_svg_icon.dart';
import '../../../../l10n/app_localizations.dart';

class LanguageBar extends StatelessWidget {
  const LanguageBar({
    super.key,
    required this.fromLanguage,
    required this.toLanguage,
    required this.onSwap,
    required this.onFromTap,
    required this.onToTap,
  });

  final String fromLanguage;
  final String toLanguage;
  final VoidCallback onSwap;
  final VoidCallback onFromTap;
  final VoidCallback onToTap;

  static const double _swapButtonSize = 42;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.palette;
    final radius = BorderRadius.circular(AppDimens.radiusDock);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimens.spaceL),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: radius,
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
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Row(
          children: [
            Expanded(
              child: _LanguageColumn(
                label: l10n.translateFrom,
                language: fromLanguage,
                onTap: onFromTap,
              ),
            ),
            _SwapButton(onTap: onSwap),
            Expanded(
              child: _LanguageColumn(
                label: l10n.translateTo,
                language: toLanguage,
                onTap: onToTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageColumn extends StatelessWidget {
  const _LanguageColumn({
    required this.label,
    required this.language,
    required this.onTap,
  });

  final String label;
  final String language;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final c = context.palette;
    final radius = BorderRadius.circular(AppDimens.radiusChipL);

    return Semantics(
      button: true,
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
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
          ),
        ),
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
            child: Center(
              child: AppSvgIcon(
                AppIcons.swap,
                size: AppDimens.iconM,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
