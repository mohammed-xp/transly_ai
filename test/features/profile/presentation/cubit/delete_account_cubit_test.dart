import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/core/session/session_manager.dart';
import 'package:transly_ai/features/profile/domain/usecases/delete_account_use_case.dart';
import 'package:transly_ai/features/profile/presentation/cubit/delete_account_cubit.dart';
import 'package:transly_ai/features/profile/presentation/cubit/delete_account_state.dart';

import '../../../../helpers/fake_account_repo.dart';
import '../../../../helpers/fake_logout_repo.dart';

void main() {
  DeleteAccountCubit buildCubit(FakeAccountRepo repo) => DeleteAccountCubit(
    deleteAccount: DeleteAccountUseCase(repo, SessionManager(FakeLogoutRepo())),
  );

  Future<List<DeleteAccountState>> statesOf(
    DeleteAccountCubit cubit,
    Future<void> Function() action,
  ) async {
    final states = <DeleteAccountState>[];
    final subscription = cubit.stream.listen(states.add);
    await action();
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();
    return states;
  }

  test('starts in DeleteAccountInitial', () {
    final cubit = buildCubit(FakeAccountRepo(const ApiResult.success(null)));
    addTearDown(cubit.close);

    expect(cubit.state, isA<DeleteAccountInitial>());
  });

  test('emits InProgress then Succeeded when the account is deleted', () async {
    final repo = FakeAccountRepo(const ApiResult.success(null));
    final cubit = buildCubit(repo);
    addTearDown(cubit.close);

    final states = await statesOf(
      cubit,
      () => cubit.deleteAccount('secret123'),
    );

    expect(states, [
      isA<DeleteAccountInProgress>(),
      isA<DeleteAccountSucceeded>(),
    ]);
    expect(repo.passwords, ['secret123']);
  });

  test('emits InProgress then Failed with the failure', () async {
    final cubit = buildCubit(
      FakeAccountRepo(const ApiResult.failure(ClientFailure(statusCode: 403))),
    );
    addTearDown(cubit.close);

    final states = await statesOf(cubit, () => cubit.deleteAccount('wrong'));

    expect(states, [
      isA<DeleteAccountInProgress>(),
      isA<DeleteAccountFailed>(),
    ]);
    expect(
      (states.last as DeleteAccountFailed).failure,
      isA<ClientFailure>().having((f) => f.statusCode, 'statusCode', 403),
    );
  });

  test('ignores a second request while one is in flight', () async {
    final repo = FakeAccountRepo(const ApiResult.success(null))
      ..gate = Completer<void>();
    final cubit = buildCubit(repo);
    addTearDown(cubit.close);

    final first = cubit.deleteAccount('secret123');
    await cubit.deleteAccount('secret123');
    repo.gate!.complete();
    await first;

    expect(repo.passwords, hasLength(1));
  });

  test('can retry after a failure', () async {
    final repo = FakeAccountRepo(
      const ApiResult.failure(ClientFailure(statusCode: 403)),
    );
    final cubit = buildCubit(repo);
    addTearDown(cubit.close);
    await cubit.deleteAccount('wrong');

    repo.result = const ApiResult.success(null);
    await cubit.deleteAccount('secret123');

    expect(repo.passwords, ['wrong', 'secret123']);
    expect(cubit.state, isA<DeleteAccountSucceeded>());
  });

  test('does not emit once closed while a deletion is in flight', () async {
    final repo = FakeAccountRepo(const ApiResult.success(null))
      ..gate = Completer<void>();
    final cubit = buildCubit(repo);

    final deletion = cubit.deleteAccount('secret123');
    final closing = cubit.close();
    repo.gate!.complete();

    await expectLater(deletion, completes);
    await closing;
  });
}
