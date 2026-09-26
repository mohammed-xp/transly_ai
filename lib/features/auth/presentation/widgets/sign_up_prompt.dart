import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/toast/coming_soon_toast.dart';
import '../../../../l10n/app_localizations.dart';

/// "Don't have an account? Create account" footer (design `01b · Sign In`).
/// The link is inert — sign-up isn't built yet — and announces "coming soon".
class SignUpPrompt extends StatelessWidget {
  const SignUpPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.palette;
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: AppDimens.spaceXS,
        children: [
          Text(
            l10n.signInNoAccount,
            style: textTheme.bodySmall?.copyWith(color: c.textMuted),
          ),
          Semantics(
            button: true,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => showComingSoonToast(context),
              child: Padding(
                // Widens the 14px link toward a reachable tap target.
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Text(
                  l10n.signInCreateAccount,
                  style: textTheme.bodySmall?.copyWith(
                    color: c.coral,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
