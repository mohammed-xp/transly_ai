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

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'Transly AI'**
  String get appName;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get haveAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @taglineAr.
  ///
  /// In en, this message translates to:
  /// **'Instant and accurate AI translation — 90+ languages at your fingertips.'**
  String get taglineAr;

  /// No description provided for @taglineEn.
  ///
  /// In en, this message translates to:
  /// **'Speak, type or scan — translate in seconds.'**
  String get taglineEn;

  /// No description provided for @translate.
  ///
  /// In en, this message translates to:
  /// **'Translate'**
  String get translate;

  /// No description provided for @translateLabel.
  ///
  /// In en, this message translates to:
  /// **'TRANSLATE'**
  String get translateLabel;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'FROM'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'TO'**
  String get to;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @aiSuggested.
  ///
  /// In en, this message translates to:
  /// **'AI suggested'**
  String get aiSuggested;

  /// No description provided for @tone.
  ///
  /// In en, this message translates to:
  /// **'Tone'**
  String get tone;

  /// No description provided for @toneFormal.
  ///
  /// In en, this message translates to:
  /// **'Formal'**
  String get toneFormal;

  /// No description provided for @toneCasual.
  ///
  /// In en, this message translates to:
  /// **'Casual'**
  String get toneCasual;

  /// No description provided for @toneShort.
  ///
  /// In en, this message translates to:
  /// **'Short'**
  String get toneShort;

  /// No description provided for @voice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get voice;

  /// No description provided for @conversation.
  ///
  /// In en, this message translates to:
  /// **'Conversation'**
  String get conversation;

  /// No description provided for @listening.
  ///
  /// In en, this message translates to:
  /// **'Listening…'**
  String get listening;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// No description provided for @translatingLive.
  ///
  /// In en, this message translates to:
  /// **'Translating live'**
  String get translatingLive;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @searchHistory.
  ///
  /// In en, this message translates to:
  /// **'Search translations…'**
  String get searchHistory;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @translationSection.
  ///
  /// In en, this message translates to:
  /// **'TRANSLATION'**
  String get translationSection;

  /// No description provided for @defaultLanguagePair.
  ///
  /// In en, this message translates to:
  /// **'Default language pair'**
  String get defaultLanguagePair;

  /// No description provided for @aiTone.
  ///
  /// In en, this message translates to:
  /// **'AI tone'**
  String get aiTone;

  /// No description provided for @offlinePacks.
  ///
  /// In en, this message translates to:
  /// **'Offline packs'**
  String get offlinePacks;

  /// No description provided for @preferencesSection.
  ///
  /// In en, this message translates to:
  /// **'PREFERENCES'**
  String get preferencesSection;

  /// No description provided for @autoPlayAudio.
  ///
  /// In en, this message translates to:
  /// **'Auto-play translation audio'**
  String get autoPlayAudio;

  /// No description provided for @darkAppearance.
  ///
  /// In en, this message translates to:
  /// **'Dark appearance'**
  String get darkAppearance;

  /// No description provided for @installedPacks.
  ///
  /// In en, this message translates to:
  /// **'{count} installed'**
  String installedPacks(int count);

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your network.'**
  String get errorNetwork;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again.'**
  String get errorServer;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorUnknown;

  /// No description provided for @errorOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline mode: limited translation available.'**
  String get errorOffline;

  /// No description provided for @keyboard.
  ///
  /// In en, this message translates to:
  /// **'Keyboard'**
  String get keyboard;

  /// No description provided for @aiPro.
  ///
  /// In en, this message translates to:
  /// **'AI Pro'**
  String get aiPro;
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
