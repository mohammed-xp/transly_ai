import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../l10n/app_localizations.dart';

/// Row of three equal-width social sign-in buttons (design `01b · Sign In`).
/// Shape-only per product decision: tapping any of them just announces
/// "coming soon" — no provider is wired up yet.
class SocialAuthRow extends StatelessWidget {
  const SocialAuthRow({super.key});

  static const double _height = 52;

  @override
  Widget build(BuildContext context) {
    final c = context.palette;

    return Row(
      children: [
        Expanded(
          child: _SocialButton(
            icon: Icons.g_mobiledata_rounded,
            label: 'Google',
            palette: c,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SocialButton(
            icon: Icons.apple_rounded,
            label: 'Apple',
            palette: c,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SocialButton(
            icon: Icons.facebook_rounded,
            label: 'Facebook',
            palette: c,
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.palette,
  });

  final IconData icon;
  final String label;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: palette.inputFill,
        borderRadius: BorderRadius.circular(AppDimens.radiusInput),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimens.radiusInput),
          onTap: () => _showComingSoon(context),
          child: Container(
            height: SocialAuthRow._height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimens.radiusInput),
              border: Border.all(color: palette.border),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: AppDimens.iconL, color: palette.ink),
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.signInComingSoon)),
    );
  }
}
