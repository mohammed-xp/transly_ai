import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/core/session/session_manager.dart';
import 'package:transly_ai/features/profile/domain/usecases/delete_account_with_google_use_case.dart';

import '../../../../helpers/fake_account_repo.dart';
import '../../../../helpers/fake_logout_repo.dart';

void main() {
  late FakeLogoutRepo logoutRepo;
  late SessionManager session;
  late List<SessionStatus> statuses;

  setUp(() {
    logoutRepo = FakeLogoutRepo();
    session = SessionManager(logoutRepo);
    statuses = [];
    session.stream.listen(statuses.add);
  });

  DeleteAccountWithGoogleUseCase useCaseWith(ApiResult<bool> googleResult) =>
      DeleteAccountWithGoogleUseCase(
        FakeAccountRepo(
          const ApiResult.success(null),
          googleResult: googleResult,
        ),
        session,
      );

  test(
    'ends the session as accountDeleted once the backend deleted it',
    () async {
      final useCase = useCaseWith(const ApiResult.success(true));

      final result = await useCase();
      await Future<void>.delayed(Duration.zero);

      expect((result as ApiSuccess<bool>).data, isTrue);
      expect(logoutRepo.calls, 1);
      expect(session.status, SessionStatus.accountDeleted);
      expect(statuses, [SessionStatus.accountDeleted]);
    },
  );

  test('keeps the session when the account picker is closed', () async {
    final useCase = useCaseWith(const ApiResult.success(false));

    final result = await useCase();
    await Future<void>.delayed(Duration.zero);

    expect((result as ApiSuccess<bool>).data, isFalse);
    expect(logoutRepo.calls, 0);
    expect(session.status, SessionStatus.authenticated);
    expect(statuses, isEmpty);
  });

  test('keeps the session and local data when the deletion fails', () async {
    final useCase = useCaseWith(
      const ApiResult.failure(ClientFailure(statusCode: 400)),
    );

    final result = await useCase();
    await Future<void>.delayed(Duration.zero);

    expect(result, isA<ApiFailure<bool>>());
    expect(logoutRepo.calls, 0);
    expect(session.status, SessionStatus.authenticated);
    expect(statuses, isEmpty);
  });
}
