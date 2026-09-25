import '../../../../core/domain/entities/language_entity.dart';
import '../../../../core/services/tts_service.dart';

/// Speaks or stops speaking translate-screen text through the device's TTS
/// engine.
class SpeakTextUseCase {
  const SpeakTextUseCase(this._tts);

  final TtsService _tts;

  /// Speaks [text] in [language]. No-op on blank text (handled by [TtsService]).
  Future<void> call({required String text, required LanguageEntity language}) {
    return _tts.speak(text: text, languageCode: language.code);
  }

  /// Stops any speech in progress.
  Future<void> stop() => _tts.stop();
}
