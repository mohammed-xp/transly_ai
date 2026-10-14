import '../../../../core/domain/entities/language_entity.dart';
import '../../../../core/result/api_result.dart';
import '../entities/translation_entity.dart';
import '../entities/translation_tone.dart';

abstract class TranslationRepo {
  Future<ApiResult<TranslationEntity>> translate({
    required String text,
    required LanguageEntity from,
    required LanguageEntity to,
    required String tone,
  });

  Future<ApiResult<bool>> areModelsDownloaded({
    required LanguageEntity from,
    required LanguageEntity to,
  });

  Future<ApiResult<void>> downloadModels({
    required LanguageEntity from,
    required LanguageEntity to,
  });

  Stream<bool> watchOnlineAvailability();

  /// Synchronous so the translate screen opens on the saved tone.
  TranslationTone getSavedTone();

  Future<ApiResult<void>> saveTone(TranslationTone tone);
}
