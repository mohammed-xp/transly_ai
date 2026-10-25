import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_links.dart';
import '../../../../core/widgets/toast/app_toast.dart';
import '../../../../l10n/app_localizations.dart';

/// Opens the share sheet with a link to the app, or shows an error toast
/// when it can't be opened.
///
/// The link is the Google Play listing on every platform until the App Store
/// listing exists.
Future<void> shareApp(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final text = l10n.aboutShareMessage(AppLinks.playStoreListing.toString());
  try {
    await SharePlus.instance.share(ShareParams(text: text));
  } on PlatformException catch (_) {
    if (!context.mounted) return;
    AppToast.show(
      context,
      message: l10n.aboutShareFailed,
      type: AppToastType.error,
    );
  }
}
