import '../../../../core/errors/error_mapper.dart';
import '../../../../core/result/api_result.dart';
import '../../domain/entities/app_info_entity.dart';
import '../../domain/repos/app_info_repo.dart';
import '../datasources/app_info_data_source.dart';

class AppInfoRepoImpl implements AppInfoRepo {
  const AppInfoRepoImpl(this._dataSource);

  final AppInfoDataSource _dataSource;

  @override
  Future<ApiResult<AppInfoEntity>> getAppInfo() async {
    try {
      final info = await _dataSource.getAppInfo();
      return ApiResult.success(info.toEntity());
    } catch (e) {
      return ApiResult.failure(ErrorMapper.map(e));
    }
  }
}
