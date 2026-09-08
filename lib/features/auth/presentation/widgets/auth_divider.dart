import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../l10n/app_localizations.dart';

/// "Or continue with" divider above the social sign-in row (design `01b ·
/// Sign In`).
class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.palette;
    final textTheme = Theme.of(context).textTheme;

    // The label is Flexible so a long translation or a large text scale
    // ellipsizes instead of overflowing the row.
    return Row(
      children: [
        Expanded(child: Divider(color: c.border, height: 1)),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              AppLocalizations.of(context)!.signInOrContinueWith,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(color: c.textMuted),
            ),
          ),
        ),
        Expanded(child: Divider(color: c.border, height: 1)),
      ],
    );
  }
}
