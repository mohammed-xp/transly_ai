import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/domain/entities/sign_in_method.dart';
import 'package:transly_ai/core/services/analytics_event.dart';

void main() {
  test('login carries the sign-in method', () {
    const event = LoginEvent(SignInMethod.google);

    expect(event.name, 'login');
    expect(event.parameters, {'method': 'google'});
  });

  test('sign_up is always by email', () {
    const event = SignUpEvent();

    expect(event.name, 'sign_up');
    expect(event.parameters, {'method': 'email'});
  });

  test('translate carries the pair and the engine', () {
    const event = TranslateEvent(
      sourceLanguage: 'en',
      targetLanguage: 'ar',
      engine: 'online',
    );

    expect(event.name, 'translate');
    expect(event.parameters, {
      'source_language': 'en',
      'target_language': 'ar',
      'engine': 'online',
    });
  });

  test('conversation_turn carries both languages', () {
    const event = ConversationTurnEvent(languageA: 'en', languageB: 'ar');

    expect(event.name, 'conversation_turn');
    expect(event.parameters, {'language_a': 'en', 'language_b': 'ar'});
  });

  test('quota_reached carries the feature', () {
    const event = QuotaReachedEvent(QuotaFeature.conversation);

    expect(event.name, 'quota_reached');
    expect(event.parameters, {'feature': 'conversation'});
  });

  test('offline_pack_download carries the language', () {
    const event = OfflinePackDownloadEvent('ar');

    expect(event.name, 'offline_pack_download');
    expect(event.parameters, {'language': 'ar'});
  });
}
