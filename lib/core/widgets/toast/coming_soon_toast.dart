import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../app_icon_source.dart';
import 'app_toast.dart';

/// Shared by the actions that aren't built yet (social sign-in, forgot
/// password, create account, and the profile screen's account actions). The
/// design has no clock icon, so it stays Material.
void showComingSoonToast(BuildContext context) {
  AppToast.show(
    context,
    message: AppLocalizations.of(context)!.commonComingSoon,
    type: AppToastType.neutral,
    icon: const MaterialIconSource(Icons.schedule_rounded),
  );
}
