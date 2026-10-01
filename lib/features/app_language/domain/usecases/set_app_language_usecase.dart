import '../../../../core/result/api_result.dart';
import '../entities/app_language.dart';
import '../repos/app_language_repo.dart';

class SetAppLanguageUseCase {
  const SetAppLanguageUseCase(this._repo);

  final AppLanguageRepo _repo;

  Future<ApiResult<void>> call(AppLanguage language) =>
      _repo.saveLanguage(language);
}
