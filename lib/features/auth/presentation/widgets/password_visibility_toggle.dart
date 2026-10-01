import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
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
        child: Icon(
          isVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 19,
          color: context.palette.textMuted,
        ),
      ),
    );
  }
}
