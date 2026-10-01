import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/features/app_language/domain/entities/app_language.dart';
import 'package:transly_ai/features/app_language/domain/repos/app_language_repo.dart';

class FakeAppLanguageRepo implements AppLanguageRepo {
  FakeAppLanguageRepo({
    this.saved = AppLanguage.device,
    this.saveResult = const ApiResult.success(null),
  });

  AppLanguage saved;
  ApiResult<void> saveResult;
  int saveCalls = 0;

  @override
  AppLanguage getLanguage() => saved;

  @override
  Future<ApiResult<void>> saveLanguage(AppLanguage language) async {
    saveCalls++;
    if (saveResult is ApiSuccess<void>) saved = language;
    return saveResult;
  }
}
