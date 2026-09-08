import 'package:google_mlkit_translation/google_mlkit_translation.dart';

import '../../domain/entities/language.dart';
import '../mappers/translate_language_mapper.dart';

/// On-device translation source. Abstracted so the repository can be tested with
/// a fake and so a future remote source sits behind the same repository.
abstract class TranslationLocalDataSource {
  Future<bool> areModelsDownloaded(Language from, Language to);
  Future<void> downloadModels(Language from, Language to);
  Future<String> translate(String text, Language from, Language to);
}

/// ML Kit implementation. Owns a single [OnDeviceTranslator] for the app
/// session, recreated only when the language pair changes (swap), which keeps
/// native resources bounded. Registered as a lazy singleton.
class MlKitTranslationLocalDataSource implements TranslationLocalDataSource {
  MlKitTranslationLocalDataSource(this._modelManager);

  final OnDeviceTranslatorModelManager _modelManager;

  OnDeviceTranslator? _translator;
  (Language, Language)? _activePair;

  @override
  Future<bool> areModelsDownloaded(Language from, Language to) async {
    final fromDownloaded = await _modelManager.isModelDownloaded(
      toMlKitLanguage(from).bcpCode,
    );
    final toDownloaded = await _modelManager.isModelDownloaded(
      toMlKitLanguage(to).bcpCode,
    );
    return fromDownloaded && toDownloaded;
  }

  @override
  Future<void> downloadModels(Language from, Language to) async {
    for (final language in {from, to}) {
      final code = toMlKitLanguage(language).bcpCode;
      if (!await _modelManager.isModelDownloaded(code)) {
        // Allow cellular downloads — models are fetched on demand at first use.
        await _modelManager.downloadModel(code, isWifiRequired: false);
      }
    }
  }

  @override
  Future<String> translate(String text, Language from, Language to) async {
    final translator = await _translatorFor(from, to);
    return translator.translateText(text);
  }

  /// Returns a translator for the pair, closing and recreating the cached one
  /// only when the pair changed. The close is awaited so an in-flight native
  /// call can't run against a translator that is being torn down (swap race).
  Future<OnDeviceTranslator> _translatorFor(Language from, Language to) async {
    if (_activePair != (from, to)) {
      await _translator?.close();
      _translator = OnDeviceTranslator(
        sourceLanguage: toMlKitLanguage(from),
        targetLanguage: toMlKitLanguage(to),
      );
      _activePair = (from, to);
    }
    return _translator!;
  }
}
