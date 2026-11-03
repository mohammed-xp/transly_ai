import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/domain/entities/sign_in_method.dart';
import 'package:transly_ai/core/domain/entities/user_entity.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/core/services/analytics_event.dart';
import 'package:transly_ai/core/session/session_manager.dart';
import 'package:transly_ai/features/auth/domain/usecases/sign_in_with_email_usecase.dart';

import '../../../../helpers/fake_analytics_service.dart';
import '../../../../helpers/fake_auth_repo.dart';
import '../../../../helpers/fake_logout_repo.dart';
import '../../../../helpers/fake_user_repo.dart';

void main() {
  late SessionManager session;
  late FakeAnalyticsService analytics;

  setUp(() async {
    session = SessionManager(FakeLogoutRepo());
    await session.expire();
    analytics = FakeAnalyticsService();
  });

  SignInWithEmailUseCase useCaseWith(ApiResult<UserEntity> emailResult) =>
      SignInWithEmailUseCase(
        FakeAuthRepo(const ApiResult.success(null), emailResult: emailResult),
        session,
        analytics,
      );

  test('starts a new session and returns the result on success', () async {
    final emailResult = ApiResult<UserEntity>.success(testUser);

    final result = await useCaseWith(emailResult)(
      email: 'ahmed@example.com',
      password: 'secret123',
    );

    expect(result, same(emailResult));
    expect(session.status, SessionStatus.authenticated);
  });

  test('links analytics to the account id and logs the login', () async {
    await useCaseWith(ApiResult<UserEntity>.success(testUser))(
      email: 'ahmed@example.com',
      password: 'secret123',
    );

    expect(analytics.userIds, [testUser.id]);
    expect(
      analytics.events.single,
      isA<LoginEvent>().having((e) => e.method, 'method', SignInMethod.email),
    );
  });

  test('leaves the session ended when the sign-in fails', () async {
    final result = await useCaseWith(
      const ApiResult.failure(UnauthorizedFailure()),
    )(email: 'ahmed@example.com', password: 'wrong-pass');

    expect(result, isA<ApiFailure<UserEntity>>());
    expect(session.status, SessionStatus.expired);
  });

  test('reports nothing to analytics when the sign-in fails', () async {
    await useCaseWith(const ApiResult.failure(UnauthorizedFailure()))(
      email: 'ahmed@example.com',
      password: 'wrong-pass',
    );

    expect(analytics.userIds, isEmpty);
    expect(analytics.events, isEmpty);
  });
}
