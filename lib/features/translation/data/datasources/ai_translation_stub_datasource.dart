import '../../domain/entities/translation.dart';
import 'translation_datasource.dart';

// Stub datasource — returns canned responses.
// Replace with a real Claude-proxy Dio datasource when the backend is ready.
final class AiTranslationStubDatasource implements TranslationDatasource {
  @override
  Future<Translation> translate(TranslationRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return Translation(
      sourceText: request.text,
      translatedText: '[AI stub] ${request.text}',
      pair: request.pair,
      tone: request.tone,
      engine: TranslationEngine.ai,
      createdAt: DateTime.now(),
    );
  }
}
