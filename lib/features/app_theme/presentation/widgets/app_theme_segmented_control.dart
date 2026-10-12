import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../domain/entities/app_theme_mode.dart';
import '../utils/app_theme_l10n.dart';

/// Light / dark / automatic picker shown inside the appearance row (design
/// `12 · Profile`).
class AppThemeSegmentedControl extends StatelessWidget {
  const AppThemeSegmentedControl({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final AppThemeMode selected;
  final ValueChanged<AppThemeMode> onChanged;

  static const double _trackRadius = 10;
  static const double _trackPadding = 3;
  static const double _gap = 2;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(_trackPadding),
      decoration: BoxDecoration(
        color: isDark ? AppColors.chipBgDark : AppColors.dividerLight,
        borderRadius: BorderRadius.circular(_trackRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final mode in AppThemeMode.values) ...[
            if (mode != AppThemeMode.values.first) const SizedBox(width: _gap),
            _Segment(
              label: appThemeModeLabel(context, mode),
              isSelected: mode == selected,
              onTap: () => onChanged(mode),
            ),
          ],
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  static const double _height = 30;
  static const double _radius = 8;
  static const Duration _duration = Duration(milliseconds: 180);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = context.palette;
    final selectedFill = isDark
        ? AppColors.segmentSelectedDark
        : AppColors.surfaceLight;

    return Semantics(
      button: true,
      selected: isSelected,
      inMutuallyExclusiveGroup: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: _duration,
          curve: Curves.easeOut,
          height: _height,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? selectedFill
                : selectedFill.withValues(alpha: 0),
            borderRadius: BorderRadius.circular(_radius),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? (isDark
                          ? AppColors.segmentShadowDark
                          : AppColors.segmentShadowLight)
                    : Colors.transparent,
                offset: const Offset(0, 1),
                blurRadius: 3,
              ),
            ],
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? c.ink : c.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
