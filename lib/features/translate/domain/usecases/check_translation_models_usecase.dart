import '../../../../core/domain/entities/language_entity.dart';
import '../../../../core/result/api_result.dart';
import '../repos/translation_repo.dart';

/// Reports whether the on-device models for a language pair are downloaded.
class CheckTranslationModelsUseCase {
  const CheckTranslationModelsUseCase(this._repository);

  final TranslationRepo _repository;

  Future<ApiResult<bool>> call({
    required LanguageEntity from,
    required LanguageEntity to,
  }) {
    return _repository.areModelsDownloaded(from: from, to: to);
  }
}
