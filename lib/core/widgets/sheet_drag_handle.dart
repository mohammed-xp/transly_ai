import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';

class SheetDragHandle extends StatelessWidget {
  const SheetDragHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 40,
      height: 5,
      decoration: BoxDecoration(
        color: isDark ? AppColors.sheetHandleDark : AppColors.sheetHandleLight,
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      ),
    );
  }
}
