import '../../../../core/data/models/language_model.dart';
import '../../domain/entities/conversation_turn.dart';
import '../../domain/entities/turn_result.dart';

enum ConversationTurnStatus { ok, noSpeech, unsupportedLanguage }

/// `data` of `POST /api/v1/conversations/turns`. The languages, transcript
/// and translation are only there when [status] is `ok`.
class ConversationTurnResponseModel {
  const ConversationTurnResponseModel({
    required this.status,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.transcript,
    required this.translation,
    required this.createdAt,
  });

  final ConversationTurnStatus status;
  final LanguageModel? sourceLanguage;
  final LanguageModel? targetLanguage;
  final String? transcript;
  final String? translation;
  final DateTime createdAt;

  factory ConversationTurnResponseModel.fromJson(Map<String, dynamic> json) {
    final source = json['sourceLanguage'];
    final target = json['targetLanguage'];
    return ConversationTurnResponseModel(
      // A status added later is read as "nothing to show", not a crash.
      status: ConversationTurnStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => ConversationTurnStatus.noSpeech,
      ),
      sourceLanguage: source is Map<String, dynamic>
          ? LanguageModel.fromJson(source)
          : null,
      targetLanguage: target is Map<String, dynamic>
          ? LanguageModel.fromJson(target)
          : null,
      transcript: json['transcript'] as String?,
      translation: json['translation'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Throws a [FormatException] for an `ok` turn missing what it promised.
  TurnResult toResult({int? secondsRemaining}) {
    return switch (status) {
      ConversationTurnStatus.ok => TurnTranslated(
        _translatedTurn(),
        secondsRemaining: secondsRemaining,
      ),
      ConversationTurnStatus.noSpeech => TurnNoSpeech(
        secondsRemaining: secondsRemaining,
      ),
      ConversationTurnStatus.unsupportedLanguage => TurnUnsupportedLanguage(
        secondsRemaining: secondsRemaining,
      ),
    };
  }

  ConversationTurn _translatedTurn() {
    final source = sourceLanguage;
    final target = targetLanguage;
    final transcript = this.transcript;
    final translation = this.translation;
    if (source == null ||
        target == null ||
        transcript == null ||
        translation == null) {
      throw const FormatException('An ok turn without its translation');
    }
    return ConversationTurn(
      language: source.toEntity(),
      translationLanguage: target.toEntity(),
      text: transcript,
      translation: translation,
      spokenAt: createdAt.toLocal(),
    );
  }
}
