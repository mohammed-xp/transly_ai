import 'package:flutter/material.dart';

import '../constants/app_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import 'app_svg_icon.dart';

class SheetCloseButton extends StatelessWidget {
  const SheetCloseButton({super.key});

  static const double _size = 34;
  static const double _iconSize = 14;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      button: true,
      label: MaterialLocalizations.of(context).closeButtonTooltip,
      child: Material(
        color: isDark ? AppColors.chipBgDark : AppColors.chipBgLight,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => Navigator.of(context).pop(),
          child: SizedBox.square(
            dimension: _size,
            child: Center(
              child: AppSvgIcon(
                AppIcons.closeSheet,
                size: _iconSize,
                color: context.palette.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
