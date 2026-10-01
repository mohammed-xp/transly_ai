import '../entities/app_language.dart';
import '../repos/app_language_repo.dart';

class GetAppLanguageUseCase {
  const GetAppLanguageUseCase(this._repo);

  final AppLanguageRepo _repo;

  AppLanguage call() => _repo.getLanguage();
}
