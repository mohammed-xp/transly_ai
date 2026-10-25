import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/domain/entities/user_entity.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/core/session/session_manager.dart';
import 'package:transly_ai/features/auth/domain/usecases/sign_in_with_google_usecase.dart';

import '../../../../helpers/fake_auth_repo.dart';
import '../../../../helpers/fake_logout_repo.dart';
import '../../../../helpers/fake_user_repo.dart';

void main() {
  late SessionManager session;

  setUp(() async {
    session = SessionManager(FakeLogoutRepo());
    await session.expire();
  });

  SignInWithGoogleUseCase useCaseWith(ApiResult<UserEntity?> googleResult) =>
      SignInWithGoogleUseCase(
        FakeAuthRepo(const ApiResult.success(null), googleResult: googleResult),
        session,
      );

  test('starts a new session when a user signs in', () async {
    final googleResult = ApiResult<UserEntity?>.success(testUser);

    final result = await useCaseWith(googleResult)();

    expect(result, same(googleResult));
    expect(session.status, SessionStatus.authenticated);
  });

  test('leaves the session ended when the picker is closed', () async {
    final result = await useCaseWith(const ApiResult.success(null))();

    expect(result, isA<ApiSuccess<UserEntity?>>());
    expect(session.status, SessionStatus.expired);
  });

  test('leaves the session ended when the sign-in fails', () async {
    final result = await useCaseWith(
      const ApiResult.failure(NetworkFailure()),
    )();

    expect(result, isA<ApiFailure<UserEntity?>>());
    expect(session.status, SessionStatus.expired);
  });
}
