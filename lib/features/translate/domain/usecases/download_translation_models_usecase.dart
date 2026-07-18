import '../../../../core/result/api_result.dart';
import '../entities/language.dart';
import '../repos/translation_repository.dart';

/// Downloads any missing on-device models for a language pair.
class DownloadTranslationModelsUseCase {
  const DownloadTranslationModelsUseCase(this._repository);

  final TranslationRepository _repository;

  Future<ApiResult<void>> call({
    required Language from,
    required Language to,
  }) {
    return _repository.downloadModels(from: from, to: to);
  }
}
