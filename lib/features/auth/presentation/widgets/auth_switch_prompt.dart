import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_palette.dart';

/// "Don't have an account? Create account" style footer that switches between
/// the sign-in and sign-up screens.
class AuthSwitchPrompt extends StatelessWidget {
  const AuthSwitchPrompt({
    super.key,
    required this.question,
    required this.action,
    required this.onTap,
  });

  final String question;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppDimens.spaceXS,
        children: [
          Text(
            question,
            style: textTheme.bodySmall?.copyWith(color: c.textMuted),
          ),
          Semantics(
            button: true,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: Padding(
                // Widens the 14px link toward a reachable tap target.
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Text(
                  action,
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
