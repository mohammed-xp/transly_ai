import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/domain/entities/backend_error_code.dart';
import 'package:transly_ai/core/domain/entities/error_entity.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/features/auth/presentation/utils/auth_l10n.dart';
import 'package:transly_ai/l10n/app_localizations.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  Future<String> signUpMessageIn(WidgetTester tester, Failure failure) async {
    late String result;
    await tester.pumpWidget(
      Localizations(
        locale: const Locale('en'),
        delegates: AppLocalizations.localizationsDelegates,
        child: Builder(
          builder: (context) {
            result = signUpFailureMessage(context, failure);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    return result;
  }

  testWidgets('reads a 409 without an error key as a taken email', (
    tester,
  ) async {
    final message = await signUpMessageIn(
      tester,
      const ClientFailure(statusCode: 409),
    );

    expect(message, l10n.errorEmailAlreadyRegistered);
  });

  testWidgets('prefers the backend error key when one is sent', (tester) async {
    final message = await signUpMessageIn(
      tester,
      const ClientFailure(
        statusCode: 409,
        error: ErrorEntity(
          success: false,
          message: 'server.unexpected_error',
          errors: {},
          code: BackendErrorCode.unexpectedError,
        ),
      ),
    );

    expect(message, l10n.errorServer);
  });

  testWidgets('reads a network failure as no connection', (tester) async {
    final message = await signUpMessageIn(tester, const NetworkFailure());

    expect(message, l10n.authErrorNoConnection);
  });
}
