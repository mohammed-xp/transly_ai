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
  String get translateCopied => 'Translation copied';

  @override
  String get translateErrorTitle => 'Translation failed';

  @override
  String get translateRetry => 'Retry';

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
  String get commonComingSoon => 'Coming soon';

  @override
  String get signInShowPassword => 'Show password';

  @override
  String get signInHidePassword => 'Hide password';

  @override
  String get commonBack => 'Back';

  @override
  String get commonRetry => 'Retry';

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
  String get profileTitle => 'Profile';

  @override
  String get profileOpen => 'Open profile';

  @override
  String get profileEdit => 'Edit';

  @override
  String get profileChangePhoto => 'Change photo';

  @override
  String get profileAccountSection => 'Account';

  @override
  String get profileName => 'Name';

  @override
  String get profileEmail => 'Email';

  @override
  String get profileNativeLanguage => 'Native language';

  @override
  String get profileSignInMethod => 'Signed in with';

  @override
  String get profileSignInMethodEmail => 'Email';

  @override
  String get profilePrivacySection => 'Privacy';

  @override
  String get profileSyncHistory => 'Sync history across devices';

  @override
  String get profileDownloadData => 'Download my data';

  @override
  String get profileDeleteAccount => 'Delete account';

  @override
  String get profileFreePlanTitle => 'Free plan';

  @override
  String profileUsageResetsInHours(int hours, String count) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'Usage resets in $count hours',
      one: 'Usage resets in 1 hour',
    );
    return '$_temp0';
  }

  @override
  String profileUsageResetsInMinutes(int minutes, String count) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'Usage resets in $count minutes',
      one: 'Usage resets in 1 minute',
    );
    return '$_temp0';
  }

  @override
  String profileUsagePercent(String percent) {
    return '$percent%';
  }

  @override
  String get profileUsageToday => 'Today\'s usage';

  @override
  String profileUsageRemaining(String percent) {
    return '$percent% left';
  }

  @override
  String get profileUpgradeToPro => 'Upgrade to Pro';

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

  @override
  String get errorNetwork =>
      'No internet connection. Check your network and try again.';

  @override
  String get errorServer =>
      'Something went wrong on our side. Please try again later.';

  @override
  String get errorUnauthorized =>
      'Your session is no longer valid. Please sign in again.';

  @override
  String get errorValidation =>
      'Some of the information you entered isn\'t valid.';

  @override
  String get errorClient => 'The request couldn\'t be completed.';

  @override
  String get errorTooManyRequests =>
      'Too many attempts. Please wait a moment and try again.';

  @override
  String get errorNotFound => 'We couldn\'t find what you were looking for.';

  @override
  String get errorFormat =>
      'We received an unexpected response. Please try again.';

  @override
  String get errorUnsupportedLanguage =>
      'This language isn\'t available offline yet.';

  @override
  String get errorUnknown => 'Something went wrong. Please try again.';

  @override
  String get updateOptionalTitle => 'A new update is available';

  @override
  String get updateNewBadge => 'New';

  @override
  String updateVersionLabel(String version) {
    return 'v$version';
  }

  @override
  String get updateWhatsNew => 'What\'s new';

  @override
  String get updateNow => 'Update now';

  @override
  String get updateLater => 'Later';

  @override
  String get updateRequiredTitle => 'Update required';

  @override
  String get updateRequiredBody =>
      'This version is no longer supported. Update Transly to keep translating.';

  @override
  String get updateYourVersion => 'Your version';

  @override
  String get updateLatestVersion => 'Latest';

  @override
  String get updateFromAppStore => 'Update from the App Store';

  @override
  String get updateFromPlayStore => 'Update from Google Play';

  @override
  String get updateStoreOpenFailed =>
      'Couldn\'t open the store. Please try again.';
}
