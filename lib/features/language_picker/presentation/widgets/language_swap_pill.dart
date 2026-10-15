import 'package:flutter/material.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/app_svg_icon.dart';
import '../../../../l10n/app_localizations.dart';

class LanguageSwapPill extends StatelessWidget {
  const LanguageSwapPill({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = context.palette;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? AppColors.chipBgDark : AppColors.chipBgLight,
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSvgIcon(AppIcons.swapPicker, size: 12, color: c.textSecondary),
          const SizedBox(width: 5),
          Text(
            AppLocalizations.of(context)!.languagePickerSwap,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: c.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
