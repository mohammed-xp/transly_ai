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
}
