import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/core/services/analytics_event.dart';
import 'package:transly_ai/features/auth/domain/usecases/sign_up_with_email_usecase.dart';

import '../../../../helpers/fake_analytics_service.dart';
import '../../../../helpers/fake_auth_repo.dart';

void main() {
  late FakeAnalyticsService analytics;

  setUp(() => analytics = FakeAnalyticsService());

  Future<ApiResult<void>> signUpWith(ApiResult<void> result) =>
      SignUpWithEmailUseCase(FakeAuthRepo(result), analytics)(
        name: 'Ahmed',
        email: 'ahmed@example.com',
        password: 'secret123',
      );

  test('a created account logs sign_up without linking a user', () async {
    await signUpWith(const ApiResult.success(null));

    expect(analytics.events.single, isA<SignUpEvent>());
    expect(analytics.userIds, isEmpty);
  });

  test('a failed sign-up logs nothing', () async {
    await signUpWith(const ApiResult.failure(NetworkFailure()));

    expect(analytics.events, isEmpty);
  });
}
