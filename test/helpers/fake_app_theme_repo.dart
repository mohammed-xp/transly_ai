import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/features/app_theme/domain/entities/app_theme_mode.dart';
import 'package:transly_ai/features/app_theme/domain/repos/app_theme_repo.dart';

class FakeAppThemeRepo implements AppThemeRepo {
  FakeAppThemeRepo({
    this.saved = AppThemeMode.system,
    this.saveResult = const ApiResult.success(null),
  });

  AppThemeMode saved;
  ApiResult<void> saveResult;
  int saveCalls = 0;

  @override
  AppThemeMode getThemeMode() => saved;

  @override
  Future<ApiResult<void>> saveThemeMode(AppThemeMode mode) async {
    saveCalls++;
    if (saveResult is ApiSuccess<void>) saved = mode;
    return saveResult;
  }
}
