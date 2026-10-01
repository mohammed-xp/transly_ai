import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/features/app_language/domain/entities/app_language.dart';
import 'package:transly_ai/features/app_language/domain/usecases/get_app_language_usecase.dart';
import 'package:transly_ai/features/app_language/domain/usecases/set_app_language_usecase.dart';
import 'package:transly_ai/features/app_language/presentation/cubit/app_language_cubit.dart';

import '../../../../helpers/fake_app_language_repo.dart';

void main() {
  AppLanguageCubit buildCubit(FakeAppLanguageRepo repo) => AppLanguageCubit(
    getLanguage: GetAppLanguageUseCase(repo),
    setLanguage: SetAppLanguageUseCase(repo),
  );

  test('starts in the saved language', () {
    final cubit = buildCubit(
      FakeAppLanguageRepo(saved: const AppLanguage('ar')),
    );
    addTearDown(cubit.close);

    expect(cubit.state, const AppLanguage('ar'));
  });

  test('changeLanguage switches once the choice is saved', () async {
    final repo = FakeAppLanguageRepo();
    final cubit = buildCubit(repo);
    addTearDown(cubit.close);

    final saved = await cubit.changeLanguage(const AppLanguage('en'));

    expect(saved, isTrue);
    expect(cubit.state, const AppLanguage('en'));
    expect(repo.saved, const AppLanguage('en'));
  });

  test('changeLanguage keeps the current language when saving fails', () async {
    final repo = FakeAppLanguageRepo(
      saved: const AppLanguage('ar'),
      saveResult: const ApiResult.failure(UnknownFailure()),
    );
    final cubit = buildCubit(repo);
    addTearDown(cubit.close);

    final saved = await cubit.changeLanguage(const AppLanguage('en'));

    expect(saved, isFalse);
    expect(cubit.state, const AppLanguage('ar'));
  });

  test('changeLanguage to the current language does not save again', () async {
    final repo = FakeAppLanguageRepo(saved: const AppLanguage('en'));
    final cubit = buildCubit(repo);
    addTearDown(cubit.close);

    final saved = await cubit.changeLanguage(const AppLanguage('en'));

    expect(saved, isTrue);
    expect(repo.saveCalls, 0);
  });
}
