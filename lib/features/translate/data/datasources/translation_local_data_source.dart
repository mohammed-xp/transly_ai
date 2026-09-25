import 'package:google_mlkit_translation/google_mlkit_translation.dart';

import '../../../../core/errors/app_exceptions.dart';
import '../models/language_model.dart';

abstract class TranslationLocalDataSource {
  Future<bool> areModelsDownloaded(LanguageModel from, LanguageModel to);
  Future<void> downloadModels(LanguageModel from, LanguageModel to);
  Future<String> translate(String text, LanguageModel from, LanguageModel to);
}

class MlKitTranslationLocalDataSource implements TranslationLocalDataSource {
  MlKitTranslationLocalDataSource(this._modelManager);

  final OnDeviceTranslatorModelManager _modelManager;

  OnDeviceTranslator? _translator;
  (String, String)? _activePair;

  @override
  Future<bool> areModelsDownloaded(LanguageModel from, LanguageModel to) async {
    final fromDownloaded = await _modelManager.isModelDownloaded(
      _mlKitLanguage(from.code).bcpCode,
    );
    final toDownloaded = await _modelManager.isModelDownloaded(
      _mlKitLanguage(to.code).bcpCode,
    );
    return fromDownloaded && toDownloaded;
  }

  @override
  Future<void> downloadModels(LanguageModel from, LanguageModel to) async {
    for (final code in {from.code, to.code}) {
      final bcpCode = _mlKitLanguage(code).bcpCode;
      if (!await _modelManager.isModelDownloaded(bcpCode)) {
        // Allow cellular downloads — models are fetched on demand at first use.
        await _modelManager.downloadModel(bcpCode, isWifiRequired: false);
      }
    }
  }

  @override
  Future<String> translate(
    String text,
    LanguageModel from,
    LanguageModel to,
  ) async {
    final translator = await _translatorFor(from.code, to.code);
    return translator.translateText(text);
  }

  Future<OnDeviceTranslator> _translatorFor(String from, String to) async {
    if (_activePair != (from, to)) {
      await _translator?.close();
      _translator = OnDeviceTranslator(
        sourceLanguage: _mlKitLanguage(from),
        targetLanguage: _mlKitLanguage(to),
      );
      _activePair = (from, to);
    }
    return _translator!;
  }

  TranslateLanguage _mlKitLanguage(String code) {
    final normalized = code.toLowerCase();
    for (final language in TranslateLanguage.values) {
      if (language.bcpCode == normalized) return language;
    }
    throw const UnsupportedLanguageException();
  }
}
