import '../../../../core/domain/entities/language_entity.dart';
import '../../../../core/result/api_result.dart';
import '../repos/translation_repo.dart';

/// Downloads any missing on-device models for a language pair.
class DownloadTranslationModelsUseCase {
  const DownloadTranslationModelsUseCase(this._repository);

  final TranslationRepo _repository;

  Future<ApiResult<void>> call({
    required LanguageEntity from,
    required LanguageEntity to,
  }) {
    return _repository.downloadModels(from: from, to: to);
  }
}
