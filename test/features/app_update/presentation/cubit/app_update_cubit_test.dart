import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/features/app_update/domain/usecases/check_for_app_update_usecase.dart';
import 'package:transly_ai/features/app_update/domain/usecases/mark_app_update_prompted_usecase.dart';
import 'package:transly_ai/features/app_update/domain/usecases/open_app_store_usecase.dart';
import 'package:transly_ai/features/app_update/presentation/cubit/app_update_cubit.dart';
import 'package:transly_ai/features/app_update/presentation/cubit/app_update_state.dart';

import '../../../../helpers/fake_app_update_repo.dart';

void main() {
  AppUpdateCubit buildCubit(FakeAppUpdateRepo repo) {
    final cubit = AppUpdateCubit(
      checkForUpdate: CheckForAppUpdateUseCase(repo),
      markPrompted: MarkAppUpdatePromptedUseCase(repo),
      openStore: OpenAppStoreUseCase(repo),
    );
    addTearDown(cubit.close);
    return cubit;
  }

  test('starts in AppUpdateChecking', () {
    final cubit = buildCubit(FakeAppUpdateRepo());

    expect(cubit.state, isA<AppUpdateChecking>());
  });

  test('checkForUpdate emits None when there is no update', () async {
    final cubit = buildCubit(FakeAppUpdateRepo());

    await cubit.checkForUpdate();

    expect(cubit.state, isA<AppUpdateNone>());
  });

  test('checkForUpdate emits Optional for an optional update', () async {
    final cubit = buildCubit(
      FakeAppUpdateRepo(
        checkResult: const ApiResult.success(testOptionalUpdate),
      ),
    );

    await cubit.checkForUpdate();

    expect((cubit.state as AppUpdateOptional).update, same(testOptionalUpdate));
  });

  test('checkForUpdate emits Required for a required update', () async {
    final cubit = buildCubit(
      FakeAppUpdateRepo(
        checkResult: const ApiResult.success(testRequiredUpdate),
      ),
    );

    await cubit.checkForUpdate();

    expect((cubit.state as AppUpdateRequired).update, same(testRequiredUpdate));
  });

  test('checkForUpdate emits CheckFailed with the failure', () async {
    final cubit = buildCubit(
      FakeAppUpdateRepo(checkResult: const ApiResult.failure(NetworkFailure())),
    );

    await cubit.checkForUpdate();

    expect(
      (cubit.state as AppUpdateCheckFailed).failure,
      isA<NetworkFailure>(),
    );
  });

  test('optionalUpdatePrompted emits None and records the prompt', () async {
    final repo = FakeAppUpdateRepo(
      checkResult: const ApiResult.success(testOptionalUpdate),
    );
    final cubit = buildCubit(repo);
    await cubit.checkForUpdate();

    await cubit.optionalUpdatePrompted();

    expect(cubit.state, isA<AppUpdateNone>());
    expect(repo.markPromptedCalls, 1);
  });

  test(
    'optionalUpdatePrompted does nothing without an optional update',
    () async {
      final repo = FakeAppUpdateRepo(
        checkResult: const ApiResult.success(testRequiredUpdate),
      );
      final cubit = buildCubit(repo);
      await cubit.checkForUpdate();

      await cubit.optionalUpdatePrompted();

      expect(cubit.state, isA<AppUpdateRequired>());
      expect(repo.markPromptedCalls, 0);
    },
  );

  test('openStore returns true when the store opens', () async {
    final repo = FakeAppUpdateRepo();
    final cubit = buildCubit(repo);

    expect(await cubit.openStore(), isTrue);
    expect(repo.openStoreCalls, 1);
  });

  test('openStore returns false when the store cannot be opened', () async {
    final cubit = buildCubit(
      FakeAppUpdateRepo(
        openStoreResult: const ApiResult.failure(UnknownFailure()),
      ),
    );

    expect(await cubit.openStore(), isFalse);
  });
}
