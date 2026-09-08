import '../../domain/entities/language.dart';
import '../../domain/entities/translation_tone.dart';
import '../models/translation_response_model.dart';

/// Online, tone-aware translation source backed by the backend API.
abstract class TranslationRemoteDataSource {
  Future<TranslationResponseModel> translate({
    required String text,
    required Language from,
    required Language to,
    required TranslationTone tone,
  });
}
