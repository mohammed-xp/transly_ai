import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/domain/entities/language_entity.dart';
import 'package:transly_ai/core/domain/usecases/get_cached_user_use_case.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/features/language_picker/domain/usecases/sync_languages_usecase.dart';
import 'package:transly_ai/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:transly_ai/features/splash/presentation/cubit/splash_state.dart';

import '../../../../helpers/fake_languages_repo.dart';
import '../../../../helpers/fake_user_repo.dart';

class _NeverSyncingLanguagesRepo extends FakeLanguagesRepo {
  @override
  Future<ApiResult<List<LanguageEntity>>> syncLanguages() {
    syncCalls++;
    return Completer<ApiResult<List<LanguageEntity>>>().future;
  }
}

void main() {
  SplashCubit buildCubit(
    FakeLanguagesRepo languagesRepo, {
    FakeUserRepo? userRepo,
  }) => SplashCubit(
    getCachedUserUseCase: GetCachedUserUseCase(
      userRepo ?? FakeUserRepo(testUser),
    ),
    syncLanguages: SyncLanguagesUseCase(languagesRepo),
  );

  test('refreshes the languages once when a user is signed in', () {
    fakeAsync((async) {
      final languagesRepo = FakeLanguagesRepo();
      final cubit = buildCubit(languagesRepo);

      cubit.checkAuthStatus();
      async.flushMicrotasks();

      expect(languagesRepo.syncCalls, 1);
      cubit.close();
    });
  });

  test('does not refresh the languages when no user is signed in', () {
    fakeAsync((async) {
      final languagesRepo = FakeLanguagesRepo();
      final cubit = buildCubit(languagesRepo, userRepo: FakeUserRepo());

      cubit.checkAuthStatus();
      async.elapse(SplashCubit.minSplashDuration);

      expect(languagesRepo.syncCalls, 0);
      cubit.close();
    });
  });

  test('startup does not wait for the language refresh', () {
    fakeAsync((async) {
      final cubit = buildCubit(_NeverSyncingLanguagesRepo());

      cubit.checkAuthStatus();
      async.elapse(SplashCubit.minSplashDuration);

      expect(cubit.state, isA<SplashReady>());
      cubit.close();
    });
  });
}
