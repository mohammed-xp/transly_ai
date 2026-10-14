import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_palette.dart';

class SheetCloseButton extends StatelessWidget {
  const SheetCloseButton({super.key});

  static const double _size = 34;

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
            child: Icon(
              Icons.close_rounded,
              size: AppDimens.iconS,
              color: context.palette.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
