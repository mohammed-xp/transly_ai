import 'package:flutter/widgets.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/l10n/failure_message.dart';
import '../../../../l10n/app_localizations.dart';

/// A 403 from delete-account means the confirmation password was wrong. It is
/// matched before [failureMessage], which would show the backend's untranslated
/// message instead.
String deleteAccountFailureMessage(BuildContext context, Failure failure) {
  return switch (failure) {
    ClientFailure(statusCode: 403) => AppLocalizations.of(
      context,
    )!.profileDeleteAccountWrongPassword,
    _ => failureMessage(context, failure),
  };
}
