import '../../../../core/domain/entities/language_entity.dart';

/// One translated turn: what was said in [language], and its [translation]
/// into [translationLanguage].
class ConversationTurn {
  const ConversationTurn({
    required this.language,
    required this.translationLanguage,
    required this.text,
    required this.translation,
    required this.spokenAt,
  });

  final LanguageEntity language;
  final LanguageEntity translationLanguage;

  /// The speaker's own words, in their language and dialect.
  final String text;
  final String translation;
  final DateTime spokenAt;
}
