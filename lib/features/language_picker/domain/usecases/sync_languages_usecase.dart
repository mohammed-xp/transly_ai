import '../../../../core/domain/entities/language_entity.dart';
import '../../../../core/result/api_result.dart';
import '../repos/languages_repo.dart';

class SyncLanguagesUseCase {
  const SyncLanguagesUseCase(this._repo);

  final LanguagesRepo _repo;

  Future<ApiResult<List<LanguageEntity>>> call() => _repo.syncLanguages();
}
