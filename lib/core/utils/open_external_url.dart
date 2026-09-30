import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../widgets/toast/app_toast.dart';

/// Opens [url] in an in-app browser tab, or shows an error toast when it
/// can't be opened.
Future<void> openExternalUrl(BuildContext context, Uri url) async {
  bool opened;
  try {
    opened = await launchUrl(url, mode: LaunchMode.inAppBrowserView);
  } on PlatformException catch (_) {
    opened = false;
  }
  if (opened || !context.mounted) return;
  AppToast.show(
    context,
    message: AppLocalizations.of(context)!.commonLinkOpenFailed,
    type: AppToastType.error,
  );
}
