import '../../../../core/result/api_result.dart';
import '../entities/language.dart';
import '../repos/translation_repository.dart';

/// Reports whether the on-device models for a language pair are downloaded.
class CheckTranslationModelsUseCase {
  const CheckTranslationModelsUseCase(this._repository);

  final TranslationRepository _repository;

  Future<ApiResult<bool>> call({required Language from, required Language to}) {
    return _repository.areModelsDownloaded(from: from, to: to);
  }
}
