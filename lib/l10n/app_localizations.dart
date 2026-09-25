import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// The application title.
  ///
  /// In en, this message translates to:
  /// **'Transly AI'**
  String get appTitle;

  /// Subtitle shown under the wordmark on the splash screen.
  ///
  /// In en, this message translates to:
  /// **'AI-powered translation'**
  String get splashTagline;

  /// Caption shown near the bottom of the splash screen.
  ///
  /// In en, this message translates to:
  /// **'Powered by AI'**
  String get splashPoweredBy;

  /// Primary subtitle under the wordmark on the onboarding welcome screen.
  ///
  /// In en, this message translates to:
  /// **'Fast, accurate AI translation — 90+ languages at your fingertips.'**
  String get onboardingSubtitle;

  /// Secondary caption under the subtitle on the onboarding welcome screen.
  ///
  /// In en, this message translates to:
  /// **'Speak, type or scan — translate in seconds.'**
  String get onboardingCaption;

  /// Primary call-to-action button on the onboarding welcome screen.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStarted;

  /// Prompt preceding the sign-in link on the onboarding welcome screen.
  ///
  /// In en, this message translates to:
  /// **'Have an account?'**
  String get onboardingHaveAccount;

  /// Sign-in link on the onboarding welcome screen.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get onboardingSignIn;

  /// Uppercase kicker above the title on the translate screen.
  ///
  /// In en, this message translates to:
  /// **'TRANSLATE'**
  String get translateKicker;

  /// Label of the plan badge in the translate screen header.
  ///
  /// In en, this message translates to:
  /// **'AI Pro'**
  String get translateAiPro;

  /// Source-language column label in the language switch bar.
  ///
  /// In en, this message translates to:
  /// **'FROM'**
  String get translateFrom;

  /// Target-language column label in the language switch bar.
  ///
  /// In en, this message translates to:
  /// **'TO'**
  String get translateTo;

  /// Badge marking the AI-generated translation output.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get translateAiBadge;

  /// Copy action button under the translation output.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get translateCopy;

  /// Save action button under the translation output.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get translateSave;

  /// Caption above the tone selector chips.
  ///
  /// In en, this message translates to:
  /// **'AI suggested · Tone'**
  String get translateToneCaption;

  /// Formal tone option.
  ///
  /// In en, this message translates to:
  /// **'Formal'**
  String get translateToneFormal;

  /// Casual tone option.
  ///
  /// In en, this message translates to:
  /// **'Casual'**
  String get translateToneCasual;

  /// Concise tone option.
  ///
  /// In en, this message translates to:
  /// **'Concise'**
  String get translateToneConcise;

  /// Keyboard input mode in the bottom input dock.
  ///
  /// In en, this message translates to:
  /// **'Keyboard'**
  String get translateDockKeyboard;

  /// Voice input mode in the bottom input dock.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get translateDockVoice;

  /// Camera input mode in the bottom input dock.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get translateDockCamera;

  /// Display name of the English language.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Display name of the Arabic language.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageArabic;

  /// Placeholder in the source text field before the user types.
  ///
  /// In en, this message translates to:
  /// **'Type text to translate…'**
  String get translateSourceHint;

  /// Status shown while the on-device language model is downloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading translation model…'**
  String get translateDownloadingModel;

  /// Short header label shown in the output card while a translation (or model download) is in flight.
  ///
  /// In en, this message translates to:
  /// **'Translating'**
  String get translateInProgress;

  /// Caption shown under the output card while a translation is running.
  ///
  /// In en, this message translates to:
  /// **'AI is analyzing context and tone…'**
  String get translateAiAnalyzing;

  /// Accessibility label for the speaker button that reads text aloud.
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get translateListen;

  /// Generic translation failure message.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t translate. Please try again.'**
  String get translateErrorGeneric;

  /// Shown when the on-device model download fails.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t download the translation model. Check your connection and try again.'**
  String get translateErrorModelDownload;

  /// Shown when an online-only translation is attempted while offline.
  ///
  /// In en, this message translates to:
  /// **'No internet connection.'**
  String get translateErrorNoConnection;

  /// Headline on the sign-in screen.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get signInTitle;

  /// Subtitle under the headline on the sign-in screen.
  ///
  /// In en, this message translates to:
  /// **'Sign in to sync your translations across devices.'**
  String get signInSubtitle;

  /// Label above the email field on the sign-in screen.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get signInEmailLabel;

  /// Placeholder in the email field on the sign-in screen.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get signInEmailHint;

  /// Label above the password field on the sign-in screen.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get signInPasswordLabel;

  /// Placeholder in the password field on the sign-in screen.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get signInPasswordHint;

  /// Forgot-password link on the sign-in screen.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get signInForgotPassword;

  /// Primary submit button on the sign-in screen.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInSubmit;

  /// Divider label above the social sign-in buttons.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get signInOrContinueWith;

  /// Prompt preceding the create-account link on the sign-in screen.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get signInNoAccount;

  /// Create-account link on the sign-in screen.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signInCreateAccount;

  /// Shown when tapping an action that isn't implemented yet (social sign-in, forgot password, create account).
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get signInComingSoon;

  /// Accessibility label for the button that reveals the password field's text.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get signInShowPassword;

  /// Accessibility label for the button that hides the password field's text.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get signInHidePassword;

  /// Accessibility label for the back button on the sign-in screen.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get signInBack;

  /// Shown under the email field when it is left empty.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address.'**
  String get authErrorEmailRequired;

  /// Shown under the email field when the format is invalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get authErrorEmailInvalid;

  /// Shown under the password field when it is left empty.
  ///
  /// In en, this message translates to:
  /// **'Enter your password.'**
  String get authErrorPasswordRequired;

  /// Shown under the password field when it is too short.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get authErrorPasswordTooShort;

  /// Shown when sign-in fails because the credentials are wrong.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password.'**
  String get authErrorInvalidCredentials;

  /// Shown when sign-in fails because the account is disabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled.'**
  String get authErrorUserDisabled;

  /// Shown when sign-in fails because of rate limiting.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again later.'**
  String get authErrorTooManyRequests;

  /// Shown when sign-in fails because the device is offline.
  ///
  /// In en, this message translates to:
  /// **'No internet connection.'**
  String get authErrorNoConnection;

  /// Shown when no auth provider is configured.
  ///
  /// In en, this message translates to:
  /// **'Sign-in isn\'t available right now.'**
  String get authErrorUnavailable;

  /// Generic sign-in failure message.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t sign in. Please try again.'**
  String get authErrorGeneric;

  /// Shown when the backend rejects the session token and the user is routed back to sign-in.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get authErrorSessionExpired;

  /// Tooltip/label for the sign-out action on the translate screen.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get authSignOut;

  /// Title of the placeholder shown on the voice-input tab before it is built.
  ///
  /// In en, this message translates to:
  /// **'Voice mode'**
  String get conversationComingSoonTitle;

  /// Body text of the placeholder shown on the voice-input tab before it is built.
  ///
  /// In en, this message translates to:
  /// **'Coming soon — speak and get an instant translation.'**
  String get conversationComingSoonBody;

  /// Title of the placeholder shown on the camera-input tab before it is built.
  ///
  /// In en, this message translates to:
  /// **'Camera mode'**
  String get cameraScanComingSoonTitle;

  /// Body text of the placeholder shown on the camera-input tab before it is built.
  ///
  /// In en, this message translates to:
  /// **'Coming soon — point your camera to translate text instantly.'**
  String get cameraScanComingSoonBody;

  /// A request failed because the device is offline or the server is unreachable.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Check your network and try again.'**
  String get errorNetwork;

  /// The server returned a 5xx error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on our side. Please try again later.'**
  String get errorServer;

  /// The server rejected the request as unauthorized (401).
  ///
  /// In en, this message translates to:
  /// **'Your session is no longer valid. Please sign in again.'**
  String get errorUnauthorized;

  /// The server rejected the request's input (422) without a readable message.
  ///
  /// In en, this message translates to:
  /// **'Some of the information you entered isn\'t valid.'**
  String get errorValidation;

  /// A generic 4xx error without a readable backend message.
  ///
  /// In en, this message translates to:
  /// **'The request couldn\'t be completed.'**
  String get errorClient;

  /// The server rate-limited the request (429) or it timed out (408).
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait a moment and try again.'**
  String get errorTooManyRequests;

  /// The server returned 404.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find what you were looking for.'**
  String get errorNotFound;

  /// The server response didn't match the expected shape.
  ///
  /// In en, this message translates to:
  /// **'We received an unexpected response. Please try again.'**
  String get errorFormat;

  /// The on-device translation engine doesn't support the selected language.
  ///
  /// In en, this message translates to:
  /// **'This language isn\'t available offline yet.'**
  String get errorUnsupportedLanguage;

  /// Fallback for any unexpected error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorUnknown;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
