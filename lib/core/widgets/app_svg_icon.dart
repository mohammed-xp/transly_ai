import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// One of the design's single-colour [AppIcons], painted in [color] so it
/// follows the theme. [matchTextDirection] mirrors a directional icon (back,
/// chevron, arrow) in RTL.
class AppSvgIcon extends StatelessWidget {
  const AppSvgIcon(
    this.asset, {
    super.key,
    required this.size,
    required this.color,
    this.matchTextDirection = false,
  });

  final String asset;
  final double size;
  final Color color;
  final bool matchTextDirection;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      matchTextDirection: matchTextDirection,
      excludeFromSemantics: true,
    );
  }
}
