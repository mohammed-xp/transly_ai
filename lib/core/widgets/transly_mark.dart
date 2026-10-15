import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_icons.dart';

/// The Transly mark (two interlocking rings) from the design's logo files,
/// drawn in its own colours: the back ring is faded (0.5 on white, 0.42 on
/// coral), which a single-colour tint would lose.
class TranslyMark extends StatelessWidget {
  /// White rings, for the gradient logo tiles.
  const TranslyMark.white({super.key, required this.size})
    : _asset = AppIcons.markWhite;

  /// Coral rings, for the white tile of the light onboarding screen.
  const TranslyMark.coral({super.key, required this.size})
    : _asset = AppIcons.markCoral;

  final double size;
  final String _asset;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      _asset,
      width: size,
      height: size,
      excludeFromSemantics: true,
    );
  }
}
