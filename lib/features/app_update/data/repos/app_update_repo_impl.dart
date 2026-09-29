import '../../../../core/errors/error_mapper.dart';
import '../../../../core/result/api_result.dart';
import '../../domain/entities/app_update_entity.dart';
import '../../domain/repos/app_update_repo.dart';
import '../datasources/app_update_data_source.dart';

class AppUpdateRepoImpl implements AppUpdateRepo {
  AppUpdateRepoImpl(this._dataSource);

  final AppUpdateDataSource _dataSource;

  @override
  Future<ApiResult<AppUpdateEntity?>> checkForUpdate() async {
    try {
      final update = await _dataSource.checkForUpdate();
      return ApiResult.success(update?.toEntity());
    } catch (e) {
      return ApiResult.failure(ErrorMapper.map(e));
    }
  }

  @override
  Future<ApiResult<void>> markPrompted() async {
    try {
      await _dataSource.markPrompted();
      return const ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ErrorMapper.map(e));
    }
  }

  @override
  Future<ApiResult<void>> openStore() async {
    try {
      await _dataSource.openStore();
      return const ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ErrorMapper.map(e));
    }
  }
}
