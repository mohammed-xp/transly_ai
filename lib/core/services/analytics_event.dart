import '../domain/entities/sign_in_method.dart';

/// What the app reports to analytics. Parameters carry only codes and enum
/// names — never the user's text, name or email.
sealed class AnalyticsEvent {
  const AnalyticsEvent();

  String get name;

  Map<String, Object> get parameters;
}

class LoginEvent extends AnalyticsEvent {
  const LoginEvent(this.method);

  final SignInMethod method;

  @override
  String get name => 'login';

  @override
  Map<String, Object> get parameters => {'method': method.name};
}

class SignUpEvent extends AnalyticsEvent {
  const SignUpEvent();

  @override
  String get name => 'sign_up';

  @override
  Map<String, Object> get parameters => {'method': SignInMethod.email.name};
}

/// One translation served, not one sentence: the Translate tab re-translates
/// after every typing pause and on each tone or language change.
class TranslateEvent extends AnalyticsEvent {
  const TranslateEvent({
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.engine,
  });

  final String sourceLanguage;
  final String targetLanguage;

  /// `online` or `offline`.
  final String engine;

  @override
  String get name => 'translate';

  @override
  Map<String, Object> get parameters => {
    'source_language': sourceLanguage,
    'target_language': targetLanguage,
    'engine': engine,
  };
}

class ConversationTurnEvent extends AnalyticsEvent {
  const ConversationTurnEvent({
    required this.languageA,
    required this.languageB,
  });

  final String languageA;
  final String languageB;

  @override
  String get name => 'conversation_turn';

  @override
  Map<String, Object> get parameters => {
    'language_a': languageA,
    'language_b': languageB,
  };
}

enum QuotaFeature { translate, conversation }

class QuotaReachedEvent extends AnalyticsEvent {
  const QuotaReachedEvent(this.feature);

  final QuotaFeature feature;

  @override
  String get name => 'quota_reached';

  @override
  Map<String, Object> get parameters => {'feature': feature.name};
}

class OfflinePackDownloadEvent extends AnalyticsEvent {
  const OfflinePackDownloadEvent(this.language);

  final String language;

  @override
  String get name => 'offline_pack_download';

  @override
  Map<String, Object> get parameters => {'language': language};
}
