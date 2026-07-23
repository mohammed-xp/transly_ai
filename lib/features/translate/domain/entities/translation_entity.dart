import 'language.dart';
import 'translation_engine.dart';

/// A completed translation: the original text, its result, and the language
/// pair. Pure Dart. Ready to back a future save/history feature.
class TranslationEntity {
  const TranslationEntity({
    required this.sourceText,
    required this.translatedText,
    required this.from,
    required this.to,
    this.engine = TranslationEngine.offline,
  });

  final String sourceText;
  final String translatedText;
  final Language from;
  final Language to;

  /// Which source produced [translatedText] — drives whether tone was honoured.
  final TranslationEngine engine;
}
