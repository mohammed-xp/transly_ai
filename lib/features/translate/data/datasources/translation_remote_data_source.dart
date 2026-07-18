import '../../domain/entities/language.dart';
import '../../domain/entities/translation_tone.dart';

/// Online, tone-aware translation source (e.g. Gemini). Interface only for now —
/// the repository is already wired to route to it when connected, so the
/// implementation can be added later as a data source + one DI line, with no
/// change to the domain or repository contracts.
abstract class TranslationRemoteDataSource {
  Future<String> translate({
    required String text,
    required Language from,
    required Language to,
    required TranslationTone tone,
  });
}
