import '../../../../core/domain/entities/language_entity.dart';
import '../../../../core/result/api_result.dart';
import '../entities/translation_entity.dart';

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
}
