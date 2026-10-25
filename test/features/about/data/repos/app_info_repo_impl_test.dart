import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/features/about/data/datasources/app_info_data_source.dart';
import 'package:transly_ai/features/about/data/models/app_info_model.dart';
import 'package:transly_ai/features/about/data/repos/app_info_repo_impl.dart';
import 'package:transly_ai/features/about/domain/entities/app_info_entity.dart';

class _FakeDataSource implements AppInfoDataSource {
  _FakeDataSource({this.info, this.error});

  final AppInfoModel? info;
  final Object? error;

  @override
  Future<AppInfoModel> getAppInfo() async {
    final error = this.error;
    if (error != null) throw error;
    return info!;
  }
}

void main() {
  test('returns the installed version', () async {
    final repo = AppInfoRepoImpl(
      _FakeDataSource(info: const AppInfoModel(version: '1.2.2')),
    );

    final result = await repo.getAppInfo();

    expect(result, isA<ApiSuccess<AppInfoEntity>>());
    final info = (result as ApiSuccess<AppInfoEntity>).data;
    expect(info.version, '1.2.2');
  });

  test('returns a failure when the platform lookup throws', () async {
    final repo = AppInfoRepoImpl(
      _FakeDataSource(error: Exception('no package info')),
    );

    final result = await repo.getAppInfo();

    expect(result, isA<ApiFailure<AppInfoEntity>>());
    expect(
      (result as ApiFailure<AppInfoEntity>).failure,
      isA<UnknownFailure>(),
    );
  });
}
