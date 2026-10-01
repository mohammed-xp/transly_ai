import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/domain/entities/backend_error_code.dart';
import 'package:transly_ai/core/domain/entities/error_entity.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/l10n/failure_message.dart';
import 'package:transly_ai/l10n/app_localizations.dart';

ErrorEntity _error(String detail, {BackendErrorCode? code}) =>
    ErrorEntity(success: false, message: detail, errors: const {}, code: code);

void main() {
  Future<String> messageIn(
    WidgetTester tester,
    Locale locale,
    Failure failure,
  ) async {
    late String result;
    await tester.pumpWidget(
      Localizations(
        locale: locale,
        delegates: AppLocalizations.localizationsDelegates,
        child: Builder(
          builder: (context) {
            result = failureMessage(context, failure);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    return result;
  }

  testWidgets('translates a backend error key in English', (tester) async {
    final failure = TooManyRequestsFailure(
      statusCode: 429,
      error: _error(
        'translation.quota_exceeded',
        code: BackendErrorCode.quotaExceeded,
      ),
    );

    expect(
      await messageIn(tester, const Locale('en'), failure),
      "You've reached your plan's translation limit.",
    );
  });

  testWidgets('translates the same key in Arabic', (tester) async {
    final failure = TooManyRequestsFailure(
      statusCode: 429,
      error: _error(
        'translation.quota_exceeded',
        code: BackendErrorCode.quotaExceeded,
      ),
    );

    expect(
      await messageIn(tester, const Locale('ar'), failure),
      'وصلت إلى الحد المسموح به للترجمة في خطتك.',
    );
  });

  testWidgets('falls back to the failure type when there is no key', (
    tester,
  ) async {
    final failure = ServerFailure(
      statusCode: 500,
      error: _error('The translation could not be completed'),
    );

    expect(
      await messageIn(tester, const Locale('en'), failure),
      'Something went wrong on our side. Please try again later.',
    );
  });

  testWidgets('never shows the raw backend text', (tester) async {
    final failure = ClientFailure(
      statusCode: 400,
      error: _error('Password is incorrect'),
    );

    final message = await messageIn(tester, const Locale('ar'), failure);

    expect(message, isNot(contains('Password is incorrect')));
    expect(message, 'تعذّر إتمام الطلب.');
  });
}
