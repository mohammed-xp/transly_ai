import '../../../../core/domain/entities/language_entity.dart';
import '../../../../core/result/api_result.dart';
import '../entities/tone_catalog.dart';
import '../entities/translation_entity.dart';

abstract class TranslationRepo {
  /// A null [tone] lets the server apply its default.
  Future<ApiResult<TranslationEntity>> translate({
    required String text,
    required LanguageEntity from,
    required LanguageEntity to,
    required String? tone,
  });

  Stream<bool> watchOnlineAvailability();

  /// Synchronous so the translate screen opens on the cached tones.
  ToneCatalog? getCachedTones();

  Future<ApiResult<ToneCatalog>> syncTones();

  String? getSavedToneCode();

  Future<ApiResult<void>> saveToneCode(String code);
}
