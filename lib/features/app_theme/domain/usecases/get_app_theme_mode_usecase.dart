import '../entities/app_theme_mode.dart';
import '../repos/app_theme_repo.dart';

class GetAppThemeModeUseCase {
  const GetAppThemeModeUseCase(this._repo);

  final AppThemeRepo _repo;

  AppThemeMode call() => _repo.getThemeMode();
}
