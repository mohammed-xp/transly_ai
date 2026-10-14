import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_palette.dart';

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
          ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
          : null,
    );
  }
}
