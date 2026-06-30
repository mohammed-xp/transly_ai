// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Transly AI';

  @override
  String get getStarted => 'Get Started';

  @override
  String get haveAccount => 'Already have an account?';

  @override
  String get signIn => 'Sign In';

  @override
  String get taglineAr =>
      'Instant and accurate AI translation — 90+ languages at your fingertips.';

  @override
  String get taglineEn => 'Speak, type or scan — translate in seconds.';

  @override
  String get translate => 'Translate';

  @override
  String get translateLabel => 'TRANSLATE';

  @override
  String get from => 'FROM';

  @override
  String get to => 'TO';

  @override
  String get copy => 'Copy';

  @override
  String get save => 'Save';

  @override
  String get aiSuggested => 'AI suggested';

  @override
  String get tone => 'Tone';

  @override
  String get toneFormal => 'Formal';

  @override
  String get toneCasual => 'Casual';

  @override
  String get toneShort => 'Short';

  @override
  String get voice => 'Voice';

  @override
  String get conversation => 'Conversation';

  @override
  String get listening => 'Listening…';

  @override
  String get camera => 'Camera';

  @override
  String get scan => 'Scan';

  @override
  String get translatingLive => 'Translating live';

  @override
  String get history => 'History';

  @override
  String get searchHistory => 'Search translations…';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get settings => 'Settings';

  @override
  String get translationSection => 'TRANSLATION';

  @override
  String get defaultLanguagePair => 'Default language pair';

  @override
  String get aiTone => 'AI tone';

  @override
  String get offlinePacks => 'Offline packs';

  @override
  String get preferencesSection => 'PREFERENCES';

  @override
  String get autoPlayAudio => 'Auto-play translation audio';

  @override
  String get darkAppearance => 'Dark appearance';

  @override
  String installedPacks(int count) {
    return '$count installed';
  }

  @override
  String get errorNetwork =>
      'No internet connection. Please check your network.';

  @override
  String get errorServer => 'Server error. Please try again.';

  @override
  String get errorUnknown => 'Something went wrong. Please try again.';

  @override
  String get errorOffline => 'Offline mode: limited translation available.';

  @override
  String get keyboard => 'Keyboard';

  @override
  String get aiPro => 'AI Pro';
}
