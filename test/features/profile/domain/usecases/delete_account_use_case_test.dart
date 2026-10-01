import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/core/session/session_manager.dart';
import 'package:transly_ai/features/profile/domain/usecases/delete_account_use_case.dart';

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

  test(
    'ends the session as accountDeleted once the backend deleted it',
    () async {
      final useCase = DeleteAccountUseCase(
        FakeAccountRepo(const ApiResult.success(null)),
        session,
      );

      final result = await useCase(password: 'secret123');
      await Future<void>.delayed(Duration.zero);

      expect(result, isA<ApiSuccess<void>>());
      expect(logoutRepo.calls, 1);
      expect(session.status, SessionStatus.accountDeleted);
      expect(statuses, [SessionStatus.accountDeleted]);
    },
  );

  test('keeps the session and local data when the deletion fails', () async {
    final useCase = DeleteAccountUseCase(
      FakeAccountRepo(const ApiResult.failure(ClientFailure(statusCode: 400))),
      session,
    );

    final result = await useCase(password: 'wrong');
    await Future<void>.delayed(Duration.zero);

    expect(result, isA<ApiFailure<void>>());
    expect(logoutRepo.calls, 0);
    expect(session.status, SessionStatus.authenticated);
    expect(statuses, isEmpty);
  });
}
