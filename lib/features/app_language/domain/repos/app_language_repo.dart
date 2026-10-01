import '../../../../core/result/api_result.dart';
import '../entities/app_language.dart';

abstract class AppLanguageRepo {
  /// Synchronous so the app starts in the saved language on its first frame.
  AppLanguage getLanguage();

  Future<ApiResult<void>> saveLanguage(AppLanguage language);
}
