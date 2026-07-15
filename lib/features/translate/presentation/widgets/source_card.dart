import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';

/// Plain surface card holding the source (input) text with its language label
/// and a speaker button (design `02 · Translate`).
class SourceCard extends StatelessWidget {
  const SourceCard({
    super.key,
    required this.isDark,
    required this.language,
    required this.text,
  });

  final bool isDark;
  final String language;
  final String text;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final labelColor = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final iconColor = isDark ? AppColors.iconLineDark : AppColors.captionMutedLight;
    final inkColor = isDark ? AppColors.textPrimaryDark : AppColors.inkLight;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                language,
                style: textTheme.titleSmall?.copyWith(color: labelColor),
              ),
              Icon(
                Icons.volume_up_outlined,
                size: AppDimens.iconM,
                color: iconColor,
              ),
            ],
          ),
          const SizedBox(height: AppDimens.spaceS + 2),
          Text(
            text,
            style: textTheme.bodyLarge?.copyWith(color: inkColor, height: 1.45),
          ),
        ],
      ),
    );
  }
}
