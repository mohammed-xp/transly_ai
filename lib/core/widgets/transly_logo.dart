import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import 'transly_glyph_painter.dart';

/// The gradient logo tile with the white translate glyph.
///
/// The default size is the 104px hero tile (design `00 · Splash`,
/// `13b · Update`); [TranslyLogo.compact] is the 76px tile on the
/// optional-update sheet (design `13 · Update`).
class TranslyLogo extends StatelessWidget {
  const TranslyLogo({super.key})
    : _tileSize = 104,
      _tileRadius = 30,
      _glyphSize = 54,
      _isCompact = false;

  const TranslyLogo.compact({super.key})
    : _tileSize = AppDimens.logoSize,
      _tileRadius = 22,
      _glyphSize = 40,
      _isCompact = true;

  final double _tileSize;
  final double _tileRadius;
  final double _glyphSize;
  final bool _isCompact;

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
          _isCompact
              ? BoxShadow(
                  color: AppColors.deep.withValues(alpha: 0.28),
                  blurRadius: 30,
                  offset: const Offset(0, 14),
                )
              : BoxShadow(
                  color: AppColors.deep.withValues(alpha: isDark ? 0.5 : 0.32),
                  blurRadius: isDark ? 54 : 50,
                  offset: const Offset(0, 24),
                ),
        ],
      ),
      child: Center(
        child: SizedBox(
          width: _glyphSize,
          height: _glyphSize,
          child: const CustomPaint(painter: TranslyGlyphPainter()),
        ),
      ),
    );
  }
}
