import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../constants/app_icons.dart';
import '../theme/app_palette.dart';
import 'app_svg_icon.dart';

/// Back-navigation chip (designs `01b · Sign In` and `12 · Profile`): 40×40,
/// radius 12, filled with [fillColor] — [AppPalette.inputFill] by default.
/// The chevron mirrors itself, so it points right in Arabic, as the RTL
/// profile design shows.
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, required this.onTap, this.fillColor});

  final VoidCallback onTap;
  final Color? fillColor;

  static const double _size = 40;
  static const double _radius = 12;
  static const double _iconSize = 18;

  @override
  Widget build(BuildContext context) {
    final c = context.palette;
    return Semantics(
      button: true,
      label: AppLocalizations.of(context)!.commonBack,
      child: Material(
        color: fillColor ?? c.inputFill,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
          side: BorderSide(color: c.border),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(_radius),
          child: SizedBox(
            width: _size,
            height: _size,
            child: Center(
              child: AppSvgIcon(
                AppIcons.back,
                size: _iconSize,
                color: c.ink,
                matchTextDirection: true,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
