import 'package:flutter/material.dart';

import 'app_svg_icon.dart';

/// An icon that is either one of the design's SVG [AppIcons] or, where the
/// design has none, a Material icon. Lets a widget such as the toast take
/// both.
sealed class AppIconSource {
  const AppIconSource();
}

class SvgIconSource extends AppIconSource {
  const SvgIconSource(this.asset);

  final String asset;
}

class MaterialIconSource extends AppIconSource {
  const MaterialIconSource(this.icon);

  final IconData icon;
}

/// Draws an [AppIconSource] at [size] in [color].
class AppIconView extends StatelessWidget {
  const AppIconView(
    this.source, {
    super.key,
    required this.size,
    required this.color,
  });

  final AppIconSource source;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return switch (source) {
      SvgIconSource(:final asset) => AppSvgIcon(
        asset,
        size: size,
        color: color,
      ),
      MaterialIconSource(:final icon) => Icon(icon, size: size, color: color),
    };
  }
}
