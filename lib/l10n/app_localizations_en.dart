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

  @override
  String get signInTitle => 'Welcome back';

  @override
  String get signInSubtitle =>
      'Sign in to sync your translations across devices.';

  @override
  String get signInEmailLabel => 'Email';

  @override
  String get signInEmailHint => 'you@example.com';

  @override
  String get signInPasswordLabel => 'Password';

  @override
  String get signInPasswordHint => 'Enter your password';

  @override
  String get signInRememberMe => 'Remember me';

  @override
  String get signInForgotPassword => 'Forgot password?';

  @override
  String get signInSubmit => 'Sign in';

  @override
  String get signInOrContinueWith => 'Or continue with';

  @override
  String get signInNoAccount => 'Don\'t have an account?';

  @override
  String get signInCreateAccount => 'Create account';

  @override
  String get signInComingSoon => 'Coming soon';

  @override
  String get signInShowPassword => 'Show password';

  @override
  String get signInHidePassword => 'Hide password';

  @override
  String get signInBack => 'Back';

  @override
  String get authErrorEmailRequired => 'Enter your email address.';

  @override
  String get authErrorEmailInvalid => 'Enter a valid email address.';

  @override
  String get authErrorPasswordRequired => 'Enter your password.';

  @override
  String get authErrorPasswordTooShort =>
      'Password must be at least 6 characters.';

  @override
  String get authErrorInvalidCredentials => 'Incorrect email or password.';

  @override
  String get authErrorUserDisabled => 'This account has been disabled.';

  @override
  String get authErrorTooManyRequests =>
      'Too many attempts. Please try again later.';

  @override
  String get authErrorNoConnection => 'No internet connection.';

  @override
  String get authErrorUnavailable => 'Sign-in isn\'t available right now.';

  @override
  String get authErrorGeneric => 'Couldn\'t sign in. Please try again.';

  @override
  String get authErrorSessionExpired =>
      'Your session has expired. Please sign in again.';

  @override
  String get authSignOut => 'Sign out';

  @override
  String get conversationComingSoonTitle => 'Voice mode';

  @override
  String get conversationComingSoonBody =>
      'Coming soon — speak and get an instant translation.';

  @override
  String get cameraScanComingSoonTitle => 'Camera mode';

  @override
  String get cameraScanComingSoonBody =>
      'Coming soon — point your camera to translate text instantly.';
}
