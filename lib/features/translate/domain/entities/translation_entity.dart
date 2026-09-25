import '../../../../core/domain/entities/language_entity.dart';
import 'translation_engine.dart';

class TranslationEntity {
  const TranslationEntity({
    required this.sourceText,
    required this.translatedText,
    required this.from,
    required this.to,
    required this.model,
    this.engine = TranslationEngine.offline,
  });

  final String sourceText;
  final String translatedText;
  final LanguageEntity from;
  final LanguageEntity to;
  final String? model;
  final TranslationEngine engine;
}
