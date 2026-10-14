import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_palette.dart';

class LanguageLeadingTile extends StatelessWidget {
  const LanguageLeadingTile({
    super.key,
    required this.isSelected,
    required this.child,
  });

  final bool isSelected;
  final Widget child;

  static const double _size = 38;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: _size,
      height: _size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: isSelected ? AppColors.brandGradient : null,
        color: isSelected
            ? null
            : (isDark ? AppColors.chipBgDark : AppColors.chipBgLight),
        borderRadius: BorderRadius.circular(AppDimens.radiusChipL),
      ),
      child: child,
    );
  }
}

class LanguageBadgeTile extends StatelessWidget {
  const LanguageBadgeTile({
    super.key,
    required this.badge,
    required this.isSelected,
  });

  final String badge;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return LanguageLeadingTile(
      isSelected: isSelected,
      child: Text(
        badge,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          // A single letter is drawn larger than a two-letter code.
          fontSize: badge.characters.length == 1 ? 17 : 13,
          fontWeight: FontWeight.w700,
          color: isSelected ? Colors.white : context.palette.textSecondary,
        ),
      ),
    );
  }
}
