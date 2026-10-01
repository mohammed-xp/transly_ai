import 'package:flutter/widgets.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/l10n/failure_message.dart';
import '../../../../l10n/app_localizations.dart';

/// A 400 from delete-account means the confirmation password was wrong. The
/// backend's `account.wrong_password` key says so directly; the status check
/// covers backend builds that don't send keys yet.
String deleteAccountFailureMessage(BuildContext context, Failure failure) {
  return switch (failure) {
    _ when failure.error?.code != null => failureMessage(context, failure),
    ClientFailure(statusCode: 400) => AppLocalizations.of(
      context,
    )!.profileDeleteAccountWrongPassword,
    _ => failureMessage(context, failure),
  };
}
