import '../../../../core/result/api_result.dart';
import '../entities/app_theme_mode.dart';

abstract class AppThemeRepo {
  /// Synchronous so the app starts in the saved appearance on its first frame.
  AppThemeMode getThemeMode();

  Future<ApiResult<void>> saveThemeMode(AppThemeMode mode);
}
