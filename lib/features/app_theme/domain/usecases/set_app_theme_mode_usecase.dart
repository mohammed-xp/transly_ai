import '../../../../core/result/api_result.dart';
import '../entities/app_theme_mode.dart';
import '../repos/app_theme_repo.dart';

class SetAppThemeModeUseCase {
  const SetAppThemeModeUseCase(this._repo);

  final AppThemeRepo _repo;

  Future<ApiResult<void>> call(AppThemeMode mode) => _repo.saveThemeMode(mode);
}
