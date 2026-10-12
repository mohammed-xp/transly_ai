import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/features/app_theme/domain/entities/app_theme_mode.dart';
import 'package:transly_ai/features/app_theme/domain/usecases/get_app_theme_mode_usecase.dart';
import 'package:transly_ai/features/app_theme/domain/usecases/set_app_theme_mode_usecase.dart';
import 'package:transly_ai/features/app_theme/presentation/cubit/app_theme_cubit.dart';

import '../../../../helpers/fake_app_theme_repo.dart';

void main() {
  AppThemeCubit buildCubit(FakeAppThemeRepo repo) => AppThemeCubit(
    getThemeMode: GetAppThemeModeUseCase(repo),
    setThemeMode: SetAppThemeModeUseCase(repo),
  );

  test('starts in the saved mode', () {
    final cubit = buildCubit(FakeAppThemeRepo(saved: AppThemeMode.dark));
    addTearDown(cubit.close);

    expect(cubit.state, AppThemeMode.dark);
  });

  test('changeThemeMode switches once the choice is saved', () async {
    final repo = FakeAppThemeRepo();
    final cubit = buildCubit(repo);
    addTearDown(cubit.close);

    final saved = await cubit.changeThemeMode(AppThemeMode.light);

    expect(saved, isTrue);
    expect(cubit.state, AppThemeMode.light);
    expect(repo.saved, AppThemeMode.light);
  });

  test('changeThemeMode keeps the current mode when saving fails', () async {
    final repo = FakeAppThemeRepo(
      saved: AppThemeMode.dark,
      saveResult: const ApiResult.failure(UnknownFailure()),
    );
    final cubit = buildCubit(repo);
    addTearDown(cubit.close);

    final saved = await cubit.changeThemeMode(AppThemeMode.light);

    expect(saved, isFalse);
    expect(cubit.state, AppThemeMode.dark);
  });

  test('changeThemeMode to the current mode does not save again', () async {
    final repo = FakeAppThemeRepo(saved: AppThemeMode.light);
    final cubit = buildCubit(repo);
    addTearDown(cubit.close);

    final saved = await cubit.changeThemeMode(AppThemeMode.light);

    expect(saved, isTrue);
    expect(repo.saveCalls, 0);
  });
}
