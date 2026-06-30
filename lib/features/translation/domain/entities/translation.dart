import 'package:equatable/equatable.dart';
import '../../../../core/domain/entities/language.dart';
import '../../../../core/domain/entities/translation_tone.dart';

final class TranslationRequest extends Equatable {
  const TranslationRequest({
    required this.text,
    required this.pair,
    this.tone = TranslationTone.formal,
  });

  final String text;
  final LanguagePair pair;
  final TranslationTone tone;

  @override
  List<Object?> get props => [text, pair, tone];
}

final class Translation extends Equatable {
  const Translation({
    required this.sourceText,
    required this.translatedText,
    required this.pair,
    required this.tone,
    this.engine = TranslationEngine.mlKit,
    this.createdAt,
  });

  final String sourceText;
  final String translatedText;
  final LanguagePair pair;
  final TranslationTone tone;
  final TranslationEngine engine;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [sourceText, translatedText, pair, tone];
}

enum TranslationEngine { mlKit, ai }
