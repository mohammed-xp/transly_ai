import 'package:google_mlkit_translation/google_mlkit_translation.dart';

import '../../../../core/data/datasources/ml_kit_language.dart';
import '../../../../core/data/models/language_model.dart';

abstract class TranslationLocalDataSource {
  Future<String> translate(String text, LanguageModel from, LanguageModel to);
}

class MlKitTranslationLocalDataSource implements TranslationLocalDataSource {
  OnDeviceTranslator? _translator;
  (String, String)? _activePair;

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
        sourceLanguage: mlKitLanguage(from),
        targetLanguage: mlKitLanguage(to),
      );
      _activePair = (from, to);
    }
    return _translator!;
  }
}
