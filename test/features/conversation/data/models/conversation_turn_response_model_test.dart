import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/domain/entities/language_entity.dart';
import 'package:transly_ai/features/conversation/data/models/conversation_turn_response_model.dart';
import 'package:transly_ai/features/conversation/domain/entities/turn_result.dart';

void main() {
  Map<String, dynamic> okJson() => {
    'status': 'ok',
    'sourceLanguage': {
      'code': 'ar',
      'name': 'Arabic',
      'nativeName': 'العربية',
      'isRtl': true,
    },
    'targetLanguage': {
      'code': 'en',
      'name': 'English',
      'nativeName': 'English',
      'isRtl': false,
    },
    'transcript': 'هي لونها إيه؟',
    'translation': 'What color is it?',
    'audioSeconds': 2,
    'model': 'gemini-3.1-flash-lite',
    'createdAt': '2026-10-28T12:00:00.0000000+00:00',
  };

  Map<String, dynamic> emptyJson(String status) => {
    'status': status,
    'sourceLanguage': null,
    'targetLanguage': null,
    'transcript': null,
    'translation': null,
    'audioSeconds': 3,
    'model': 'gemini-3.1-flash-lite',
    'createdAt': '2026-10-28T12:00:05.0000000+00:00',
  };

  test('an ok turn becomes a translated turn', () {
    final result = ConversationTurnResponseModel.fromJson(
      okJson(),
    ).toResult(secondsRemaining: 258);

    expect(result, isA<TurnTranslated>());
    final turn = (result as TurnTranslated).turn;
    expect(turn.language, LanguageEntity.arabic);
    expect(turn.translationLanguage, LanguageEntity.english);
    expect(turn.text, 'هي لونها إيه؟');
    expect(turn.translation, 'What color is it?');
    expect(turn.spokenAt, DateTime.utc(2026, 10, 28, 12).toLocal());
    expect(result.secondsRemaining, 258);
  });

  test('noSpeech becomes no speech', () {
    final result = ConversationTurnResponseModel.fromJson(
      emptyJson('noSpeech'),
    ).toResult();

    expect(result, isA<TurnNoSpeech>());
  });

  test('unsupportedLanguage becomes an unsupported language', () {
    final result = ConversationTurnResponseModel.fromJson(
      emptyJson('unsupportedLanguage'),
    ).toResult();

    expect(result, isA<TurnUnsupportedLanguage>());
  });

  test('a status it does not know is read as no speech', () {
    final result = ConversationTurnResponseModel.fromJson(
      emptyJson('somethingNew'),
    ).toResult();

    expect(result, isA<TurnNoSpeech>());
  });

  test('an ok turn without its translation is a format error', () {
    final model = ConversationTurnResponseModel.fromJson(
      okJson()..['translation'] = null,
    );

    expect(model.toResult, throwsFormatException);
  });
}
