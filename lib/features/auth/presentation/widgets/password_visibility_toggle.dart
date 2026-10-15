import 'package:flutter/material.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/app_icon_source.dart';
import '../../../../l10n/app_localizations.dart';

/// Eye icon at the end of a password field.
class PasswordVisibilityToggle extends StatelessWidget {
  const PasswordVisibilityToggle({
    super.key,
    required this.isVisible,
    required this.onTap,
  });

  final bool isVisible;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      button: true,
      label: isVisible ? l10n.signInHidePassword : l10n.signInShowPassword,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        // The design only draws the open eye; the struck one stays Material.
        child: AppIconView(
          isVisible
              ? const MaterialIconSource(Icons.visibility_off_outlined)
              : const SvgIconSource(AppIcons.eye),
          size: 19,
          color: context.palette.textMuted,
        ),
      ),
    );
  }
}
