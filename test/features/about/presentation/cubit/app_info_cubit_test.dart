import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/features/about/domain/entities/app_info_entity.dart';
import 'package:transly_ai/features/about/domain/repos/app_info_repo.dart';
import 'package:transly_ai/features/about/domain/usecases/get_app_info_usecase.dart';
import 'package:transly_ai/features/about/presentation/cubit/app_info_cubit.dart';
import 'package:transly_ai/features/about/presentation/cubit/app_info_state.dart';

class _FakeAppInfoRepo implements AppInfoRepo {
  _FakeAppInfoRepo(this.result);

  final ApiResult<AppInfoEntity> result;

  @override
  Future<ApiResult<AppInfoEntity>> getAppInfo() async => result;
}

void main() {
  AppInfoCubit buildCubit(ApiResult<AppInfoEntity> result) =>
      AppInfoCubit(getAppInfo: GetAppInfoUseCase(_FakeAppInfoRepo(result)));

  test('starts loading', () {
    final cubit = buildCubit(
      const ApiResult.success(AppInfoEntity(version: '1.2.2')),
    );
    addTearDown(cubit.close);

    expect(cubit.state, isA<AppInfoLoading>());
  });

  test('load shows the installed version', () async {
    const info = AppInfoEntity(version: '1.2.2');
    final cubit = buildCubit(const ApiResult.success(info));
    addTearDown(cubit.close);

    await cubit.load();

    expect(cubit.state, isA<AppInfoLoaded>());
    expect((cubit.state as AppInfoLoaded).info, same(info));
  });

  test('load reports the failure when the version cannot be read', () async {
    const failure = UnknownFailure();
    final cubit = buildCubit(const ApiResult.failure(failure));
    addTearDown(cubit.close);

    await cubit.load();

    expect(cubit.state, isA<AppInfoFailed>());
    expect((cubit.state as AppInfoFailed).failure, same(failure));
  });
}
