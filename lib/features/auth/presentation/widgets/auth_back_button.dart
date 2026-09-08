import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../l10n/app_localizations.dart';

/// Back-navigation chip in the sign-in screen's top-left (design `01b · Sign
/// In`): 40×40, radius 12, filled with [AppPalette.inputFill]. The chevron is
/// swapped explicitly per `Directionality` (same convention as onboarding's
/// `_GetStartedButton`) so it points the reading-forward direction in Arabic.
class AuthBackButton extends StatelessWidget {
  const AuthBackButton({super.key, required this.onTap});

  final VoidCallback onTap;

  static const double _size = 40;
  static const double _radius = 12;

  @override
  Widget build(BuildContext context) {
    final c = context.palette;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Semantics(
      button: true,
      label: AppLocalizations.of(context)!.signInBack,
      child: Material(
        color: c.inputFill,
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
              isRtl
                  ? Icons.arrow_forward_ios_rounded
                  : Icons.arrow_back_ios_new_rounded,
              size: AppDimens.iconS,
              color: c.ink,
            ),
          ),
        ),
      ),
    );
  }
}
