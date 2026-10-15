import 'package:flutter/material.dart';

import '../constants/app_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import 'app_svg_icon.dart';

class SelectionMark extends StatelessWidget {
  const SelectionMark({super.key, required this.isSelected});

  final bool isSelected;

  static const double _size = 24;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = context.palette;

    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? c.coral : null,
        border: isSelected
            ? null
            : Border.all(
                color: isDark
                    ? AppColors.radioRingDark
                    : AppColors.radioRingLight,
                width: 2,
              ),
      ),
      child: isSelected
          ? const Center(
              child: AppSvgIcon(
                AppIcons.checkSelect,
                size: 13,
                color: Colors.white,
              ),
            )
          : null,
    );
  }
}
