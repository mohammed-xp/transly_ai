import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import 'transly_mark.dart';

/// The gradient logo tile with the white Transly mark.
///
/// The default size is the 104px hero tile (design `00 · Splash`,
/// `13b · Update`); [TranslyLogo.medium] is the 88px tile on the about
/// screen (design `14 · About`) and [TranslyLogo.compact] the 76px tile on
/// the optional-update sheet (design `13 · Update`).
class TranslyLogo extends StatelessWidget {
  const TranslyLogo({super.key})
    : _tileSize = 104,
      _tileRadius = 30,
      _glyphSize = 54,
      _isHero = true,
      _shadowBlur = 50,
      _shadowOffsetY = 24;

  const TranslyLogo.medium({super.key})
    : _tileSize = 88,
      _tileRadius = 26,
      _glyphSize = 46,
      _isHero = false,
      _shadowBlur = 38,
      _shadowOffsetY = 18;

  const TranslyLogo.compact({super.key})
    : _tileSize = AppDimens.logoSize,
      _tileRadius = 22,
      _glyphSize = 40,
      _isHero = false,
      _shadowBlur = 30,
      _shadowOffsetY = 14;

  final double _tileSize;
  final double _tileRadius;
  final double _glyphSize;

  /// Only the hero tile's shadow deepens in dark mode.
  final bool _isHero;
  final double _shadowBlur;
  final double _shadowOffsetY;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: _tileSize,
      height: _tileSize,
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(_tileRadius),
        boxShadow: [
          _isHero
              ? BoxShadow(
                  color: AppColors.deep.withValues(alpha: isDark ? 0.5 : 0.32),
                  blurRadius: isDark ? 54 : _shadowBlur,
                  offset: Offset(0, _shadowOffsetY),
                )
              : BoxShadow(
                  color: AppColors.deep.withValues(alpha: 0.28),
                  blurRadius: _shadowBlur,
                  offset: Offset(0, _shadowOffsetY),
                ),
        ],
      ),
      child: Center(child: TranslyMark.white(size: _glyphSize)),
    );
  }
}
