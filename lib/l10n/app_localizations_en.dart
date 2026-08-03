// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Transly AI';

  @override
  String get splashTagline => 'AI-powered translation';

  @override
  String get splashPoweredBy => 'Powered by AI';

  @override
  String get onboardingSubtitle =>
      'Fast, accurate AI translation — 90+ languages at your fingertips.';

  @override
  String get onboardingCaption => 'Speak, type or scan — translate in seconds.';

  @override
  String get onboardingGetStarted => 'Get Started';

  @override
  String get onboardingHaveAccount => 'Have an account?';

  @override
  String get onboardingSignIn => 'Sign in';

  @override
  String get translateKicker => 'TRANSLATE';

  @override
  String get translateAiPro => 'AI Pro';

  @override
  String get translateFrom => 'FROM';

  @override
  String get translateTo => 'TO';

  @override
  String get translateAiBadge => 'AI';

  @override
  String get translateCopy => 'Copy';

  @override
  String get translateSave => 'Save';

  @override
  String get translateToneCaption => 'AI suggested · Tone';

  @override
  String get translateToneFormal => 'Formal';

  @override
  String get translateToneCasual => 'Casual';

  @override
  String get translateToneConcise => 'Concise';

  @override
  String get translateDockKeyboard => 'Keyboard';

  @override
  String get translateDockVoice => 'Voice';

  @override
  String get translateDockCamera => 'Camera';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'Arabic';

  @override
  String get translateSourceHint => 'Type text to translate…';

  @override
  String get translateDownloadingModel => 'Downloading translation model…';

  @override
  String get translateInProgress => 'Translating';

  @override
  String get translateAiAnalyzing => 'AI is analyzing context and tone…';

  @override
  String get translateListen => 'Listen';

  @override
  String get translateErrorGeneric => 'Couldn\'t translate. Please try again.';

  @override
  String get translateErrorModelDownload =>
      'Couldn\'t download the translation model. Check your connection and try again.';

  @override
  String get translateErrorNoConnection => 'No internet connection.';
}
