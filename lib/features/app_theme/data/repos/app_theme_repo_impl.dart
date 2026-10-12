import '../../../../core/errors/error_mapper.dart';
import '../../../../core/result/api_result.dart';
import '../../domain/entities/app_theme_mode.dart';
import '../../domain/repos/app_theme_repo.dart';
import '../datasources/app_theme_local_data_source.dart';

class AppThemeRepoImpl implements AppThemeRepo {
  const AppThemeRepoImpl(this._dataSource);

  final AppThemeLocalDataSource _dataSource;

  /// Nothing saved, a value the app no longer knows, or a box that can't be
  /// read all fall back to following the device.
  @override
  AppThemeMode getThemeMode() {
    try {
      final name = _dataSource.getThemeModeName();
      return AppThemeMode.values.asNameMap()[name] ?? AppThemeMode.system;
    } catch (_) {
      return AppThemeMode.system;
    }
  }

  @override
  Future<ApiResult<void>> saveThemeMode(AppThemeMode mode) async {
    try {
      await _dataSource.saveThemeModeName(mode.name);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ErrorMapper.map(e));
    }
  }
}
