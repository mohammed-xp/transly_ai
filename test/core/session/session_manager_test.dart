import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/core/session/session_manager.dart';

import '../../helpers/fake_logout_repo.dart';

void main() {
  late FakeLogoutRepo logoutRepo;
  late SessionManager session;
  late List<SessionStatus> statuses;

  setUp(() {
    logoutRepo = FakeLogoutRepo();
    session = SessionManager(logoutRepo);
    statuses = [];
    final subscription = session.stream.listen(statuses.add);
    addTearDown(subscription.cancel);
  });

  Future<void> flush() => Future<void>.delayed(Duration.zero);

  test('starts authenticated', () {
    expect(session.status, SessionStatus.authenticated);
  });

  test('expire logs out once and emits expired', () async {
    await session.expire();
    await flush();

    expect(logoutRepo.calls, 1);
    expect(session.status, SessionStatus.expired);
    expect(statuses, [SessionStatus.expired]);
  });

  test('a second expire neither logs out again nor emits again', () async {
    await session.expire();
    await session.expire();
    await flush();

    expect(logoutRepo.calls, 1);
    expect(statuses, [SessionStatus.expired]);
  });

  test('ignores an expire while a sign-out is still in flight', () async {
    logoutRepo.gate = Completer<void>();

    final signingOut = session.signOut();
    final expiring = session.expire();
    logoutRepo.gate!.complete();
    await Future.wait([signingOut, expiring]);
    await flush();

    expect(logoutRepo.calls, 1);
    expect(session.status, SessionStatus.signedOut);
    expect(statuses, [SessionStatus.signedOut]);
  });

  test('markAuthenticated after an expiry lets the next expire end the session '
      'again', () async {
    await session.expire();
    session.markAuthenticated();
    await session.expire();
    await flush();

    expect(logoutRepo.calls, 2);
    expect(statuses, [
      SessionStatus.expired,
      SessionStatus.authenticated,
      SessionStatus.expired,
    ]);
  });

  test('ends the session even when the logout call fails', () async {
    logoutRepo.result = const ApiResult.failure(NetworkFailure());

    await session.expire();
    await flush();

    expect(logoutRepo.calls, 1);
    expect(session.status, SessionStatus.expired);
    expect(statuses, [SessionStatus.expired]);
  });

  test('signOut emits signedOut', () async {
    await session.signOut();
    await flush();

    expect(session.status, SessionStatus.signedOut);
    expect(statuses, [SessionStatus.signedOut]);
  });

  test('accountDeleted emits accountDeleted', () async {
    await session.accountDeleted();
    await flush();

    expect(session.status, SessionStatus.accountDeleted);
    expect(statuses, [SessionStatus.accountDeleted]);
  });
}
