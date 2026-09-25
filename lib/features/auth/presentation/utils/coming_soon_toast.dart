import 'package:flutter/material.dart';

import '../../../../core/widgets/toast/app_toast.dart';
import '../../../../l10n/app_localizations.dart';

/// Shared by the sign-in actions that aren't built yet (social sign-in,
/// forgot password, create account).
void showComingSoonToast(BuildContext context) {
  AppToast.show(
    context,
    message: AppLocalizations.of(context)!.signInComingSoon,
    type: AppToastType.neutral,
    icon: Icons.schedule_rounded,
  );
}
