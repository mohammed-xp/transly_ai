import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/translation.dart';
import 'translation_datasource.dart';

final class MlKitTranslationDatasource implements TranslationDatasource {
  MlKitTranslationDatasource();

  OnDeviceTranslator? _translator;

  @override
  Future<Translation> translate(TranslationRequest request) async {
    await _ensureTranslator(request);

    try {
      final result = await _translator!.translateText(request.text);
      return Translation(
        sourceText: request.text,
        translatedText: result,
        pair: request.pair,
        tone: request.tone,
        engine: TranslationEngine.mlKit,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw ServerException(message: 'ML Kit translation failed: $e');
    }
  }

  Future<void> _ensureTranslator(TranslationRequest request) async {
    final source = _toTranslateLanguage(request.pair.source.code);
    final target = _toTranslateLanguage(request.pair.target.code);

    if (_translator == null ||
        _translator!.sourceLanguage != source ||
        _translator!.targetLanguage != target) {
      await _translator?.close();
      _translator = OnDeviceTranslator(
        sourceLanguage: source,
        targetLanguage: target,
      );
    }
  }

  TranslateLanguage _toTranslateLanguage(String bcpCode) =>
      TranslateLanguage.values.firstWhere(
        (l) => l.bcpCode == bcpCode,
        orElse: () => TranslateLanguage.english,
      );

  Future<void> dispose() async {
    await _translator?.close();
    _translator = null;
  }
}
