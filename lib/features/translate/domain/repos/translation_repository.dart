import '../../../../core/result/api_result.dart';
import '../entities/language.dart';
import '../entities/translation_entity.dart';
import '../entities/translation_tone.dart';

/// Contract for translating text and managing on-device models. Implementations
/// choose between an offline source (ML Kit) and an online source (Gemini) —
/// [tone] is in the contract now so the online source plugs in later without any
/// change here; the offline source ignores it.
abstract class TranslationRepository {
  Future<ApiResult<TranslationEntity>> translate({
    required String text,
    required Language from,
    required Language to,
    required TranslationTone tone,
  });

  /// Whether the on-device models for both languages are already downloaded.
  Future<ApiResult<bool>> areModelsDownloaded({
    required Language from,
    required Language to,
  });

  /// Downloads any missing on-device models for the pair.
  Future<ApiResult<void>> downloadModels({
    required Language from,
    required Language to,
  });
}
