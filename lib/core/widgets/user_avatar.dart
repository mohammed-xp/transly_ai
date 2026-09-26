import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_palette.dart';

/// Brand-gradient circle with the first letter of [name] (designs
/// `02 · Translate` header, 44px, and `12 · Profile`, 84px). The inner ring
/// takes the screen background so the avatar reads as cut out of it, and the
/// outer hairline keeps it visible against the same color.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.name,
    required this.size,
    required this.ringWidth,
    this.glow = true,
  });

  final String? name;
  final double size;
  final double ringWidth;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    final c = context.palette;
    final initial = _initialOf(name);

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.brandGradient,
        border: Border.all(color: c.screenBackground, width: ringWidth),
        boxShadow: [
          if (glow)
            BoxShadow(
              color: AppColors.deep.withValues(alpha: 0.24),
              blurRadius: size * 0.3,
              offset: Offset(0, size * 0.12),
            ),
          BoxShadow(color: c.border, spreadRadius: 1),
        ],
      ),
      child: initial == null
          ? Icon(Icons.person_rounded, size: size * 0.5, color: Colors.white)
          : Text(
              initial,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: size * 0.4,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1,
              ),
            ),
    );
  }

  static String? _initialOf(String? name) {
    final trimmed = name?.trim().characters;
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed.first.toUpperCase();
  }
}
