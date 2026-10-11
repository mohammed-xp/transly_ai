import 'package:flutter/widgets.dart';

import '../../../../core/domain/entities/sign_in_method.dart';
import '../../../../l10n/app_localizations.dart';

String signInMethodLabel(BuildContext context, SignInMethod method) {
  final l10n = AppLocalizations.of(context)!;
  return switch (method) {
    SignInMethod.email => l10n.profileSignInMethodEmail,
    SignInMethod.google => l10n.profileSignInMethodGoogle,
  };
}
