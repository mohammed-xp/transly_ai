import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_dimens.dart';
import '../theme/app_palette.dart';

/// Back-navigation chip (designs `01b · Sign In` and `12 · Profile`): 40×40,
/// radius 12, filled with [fillColor] — [AppPalette.inputFill] by default.
/// The chevron icon has `matchTextDirection`, so it mirrors on its own and
/// points right in Arabic, as the RTL profile design shows.
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, required this.onTap, this.fillColor});

  final VoidCallback onTap;
  final Color? fillColor;

  static const double _size = 40;
  static const double _radius = 12;

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
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: AppDimens.iconS,
              color: c.ink,
            ),
          ),
        ),
      ),
    );
  }
}
