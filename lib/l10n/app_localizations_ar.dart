// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'ترانسلي AI';

  @override
  String get splashTagline => 'ترجمة بالذكاء الاصطناعي';

  @override
  String get splashPoweredBy => 'مدعوم بالذكاء الاصطناعي';

  @override
  String get onboardingSubtitle =>
      'ترجمة فورية ودقيقة بالذكاء الاصطناعي — أكثر من ٩٠ لغة بين يديك.';

  @override
  String get onboardingCaption => 'تحدّث أو اكتب أو صوّر — وترجم في ثوانٍ.';

  @override
  String get onboardingGetStarted => 'ابدأ الآن';

  @override
  String get onboardingHaveAccount => 'لديك حساب؟';

  @override
  String get onboardingSignIn => 'تسجيل الدخول';

  @override
  String get translateKicker => 'الترجمة';

  @override
  String get translateAiPro => 'AI Pro';

  @override
  String get translateFrom => 'من';

  @override
  String get translateTo => 'إلى';

  @override
  String get translateAiBadge => 'AI';

  @override
  String get translateCopy => 'نسخ';

  @override
  String get translateSave => 'حفظ';

  @override
  String get translateToneCaption => 'اقتراح الذكاء الاصطناعي · النبرة';

  @override
  String get translateToneFormal => 'رسمية';

  @override
  String get translateToneCasual => 'عامية';

  @override
  String get translateToneConcise => 'مختصرة';

  @override
  String get translateDockKeyboard => 'لوحة المفاتيح';

  @override
  String get translateDockVoice => 'الصوت';

  @override
  String get translateDockCamera => 'الكاميرا';

  @override
  String get languageNativeName => 'العربية';

  @override
  String get languageBadge => 'ع';

  @override
  String get localeDigits => '٠١٢٣٤٥٦٧٨٩';

  @override
  String languageName(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'ar': 'العربية',
      'en': 'الإنجليزية',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get translateSourceHint => 'اكتب النص المراد ترجمته…';

  @override
  String get translateDownloadingModel => 'جارٍ تنزيل نموذج الترجمة…';

  @override
  String get translateInProgress => 'جاري الترجمة';

  @override
  String get translateAiAnalyzing => 'الذكاء الاصطناعي يحلّل السياق والنبرة…';

  @override
  String get translateListen => 'استماع';

  @override
  String get translateErrorGeneric => 'تعذّرت الترجمة. حاول مرة أخرى.';

  @override
  String get translateErrorModelDownload =>
      'تعذّر تنزيل نموذج الترجمة. تحقّق من الاتصال وحاول مجددًا.';

  @override
  String get translateErrorNoConnection => 'لا يوجد اتصال بالإنترنت.';

  @override
  String get translateCopied => 'تم نسخ الترجمة';

  @override
  String get translateErrorTitle => 'تعذّرت الترجمة';

  @override
  String get translateRetry => 'إعادة';

  @override
  String get signInTitle => 'أهلاً بعودتك';

  @override
  String get signInSubtitle => 'سجّل دخولك لمزامنة ترجماتك عبر أجهزتك.';

  @override
  String get signInEmailLabel => 'البريد الإلكتروني';

  @override
  String get signInEmailHint => 'ahmed@example.com';

  @override
  String get signInPasswordLabel => 'كلمة المرور';

  @override
  String get signInPasswordHint => 'أدخل كلمة المرور';

  @override
  String get signInForgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get signInSubmit => 'تسجيل الدخول';

  @override
  String get signInOrContinueWith => 'أو تابع باستخدام';

  @override
  String get signInNoAccount => 'ليس لديك حساب؟';

  @override
  String get signInCreateAccount => 'إنشاء حساب';

  @override
  String get commonComingSoon => 'قريبًا';

  @override
  String get commonLinkOpenFailed => 'تعذّر فتح الرابط. حاول مرة أخرى.';

  @override
  String get signInShowPassword => 'إظهار كلمة المرور';

  @override
  String get signInHidePassword => 'إخفاء كلمة المرور';

  @override
  String get commonBack => 'رجوع';

  @override
  String get commonRetry => 'إعادة المحاولة';

  @override
  String get authErrorEmailRequired => 'أدخل بريدك الإلكتروني.';

  @override
  String get authErrorEmailInvalid => 'أدخل بريدًا إلكترونيًا صحيحًا.';

  @override
  String get authErrorPasswordRequired => 'أدخل كلمة المرور.';

  @override
  String get authErrorPasswordTooShort => 'يجب ألا تقل كلمة المرور عن 6 أحرف.';

  @override
  String get authErrorInvalidCredentials =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة.';

  @override
  String get authErrorUserDisabled => 'تم تعطيل هذا الحساب.';

  @override
  String get authErrorTooManyRequests => 'محاولات كثيرة. حاول مرة أخرى لاحقًا.';

  @override
  String get authErrorNoConnection => 'لا يوجد اتصال بالإنترنت.';

  @override
  String get authErrorUnavailable => 'تسجيل الدخول غير متاح حاليًا.';

  @override
  String get authErrorGeneric => 'تعذّر تسجيل الدخول. حاول مرة أخرى.';

  @override
  String get authErrorSessionExpired =>
      'انتهت صلاحية الجلسة. سجّل الدخول مرة أخرى.';

  @override
  String get signUpTitle => 'أنشئ حسابك';

  @override
  String get signUpSubtitle => 'ابدأ مجانًا واحفظ ترجماتك على كل أجهزتك.';

  @override
  String get signUpNameLabel => 'الاسم الكامل';

  @override
  String get signUpNameHint => 'أحمد سالم';

  @override
  String get signUpPasswordHint => '8 أحرف على الأقل';

  @override
  String get signUpPasswordStrengthWeak => 'ضعيفة';

  @override
  String get signUpPasswordStrengthFair => 'متوسطة';

  @override
  String get signUpPasswordStrengthStrong => 'قوية';

  @override
  String get signUpPasswordStrengthVeryStrong => 'قوية جدًا';

  @override
  String signUpPasswordStrengthLabel(String strength) {
    return 'قوة كلمة المرور: $strength';
  }

  @override
  String get signUpAgreePrefix => 'أوافق على ';

  @override
  String get signUpAgreeAnd => ' و';

  @override
  String get signUpTermsRequired =>
      'يجب الموافقة على شروط الاستخدام وسياسة الخصوصية.';

  @override
  String get signUpSubmit => 'إنشاء حساب';

  @override
  String get signUpOrRegisterWith => 'أو سجّل باستخدام';

  @override
  String get signUpHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get signUpSignIn => 'تسجيل الدخول';

  @override
  String get signUpAccountCreated => 'تم إنشاء حسابك. سجّل دخولك للمتابعة.';

  @override
  String get signUpErrorNameRequired => 'أدخل اسمك.';

  @override
  String get signUpErrorNameTooShort => 'يجب ألا يقل الاسم عن 3 أحرف.';

  @override
  String get signUpErrorNameTooLong => 'يجب ألا يزيد الاسم عن 50 حرفًا.';

  @override
  String get signUpErrorPasswordTooShort =>
      'يجب ألا تقل كلمة المرور عن 8 أحرف.';

  @override
  String get authSignOut => 'تسجيل الخروج';

  @override
  String get profileTitle => 'الملف الشخصي';

  @override
  String get profileOpen => 'فتح الملف الشخصي';

  @override
  String get profileEdit => 'تعديل';

  @override
  String get profileChangePhoto => 'تغيير الصورة';

  @override
  String get profileAccountSection => 'الحساب';

  @override
  String get profileName => 'الاسم';

  @override
  String get profileEmail => 'البريد الإلكتروني';

  @override
  String get profileAppLanguage => 'لغة التطبيق';

  @override
  String get appLanguageSheetTitle => 'لغة التطبيق';

  @override
  String get appLanguageDevice => 'لغة الجهاز';

  @override
  String get appLanguageSheetSubtitle =>
      'لغة القوائم والأزرار فقط — لا تؤثر على لغات الترجمة.';

  @override
  String appLanguageDeviceAuto(String language) {
    return 'تلقائي · $language';
  }

  @override
  String get appLanguageAllLanguages => 'كل اللغات';

  @override
  String get appLanguageSave => 'حفظ';

  @override
  String get appLanguageSaveFailed => 'تعذّر تغيير اللغة. حاول مرة أخرى.';

  @override
  String get profileSignInMethod => 'تسجيل الدخول عبر';

  @override
  String get profileSignInMethodEmail => 'البريد الإلكتروني';

  @override
  String get profilePrivacySection => 'الخصوصية';

  @override
  String get profileSyncHistory => 'مزامنة السجل بين الأجهزة';

  @override
  String get profileDownloadData => 'تنزيل بياناتي';

  @override
  String get profilePrivacyPolicy => 'سياسة الخصوصية';

  @override
  String get profileTermsOfService => 'شروط الاستخدام';

  @override
  String get profileDeleteAccount => 'حذف الحساب';

  @override
  String get profileDeleteAccountTitle => 'حذف حسابك؟';

  @override
  String get profileDeleteAccountWarning =>
      'سيتم حذف حسابك وبيانات استخدامك نهائياً، ولا يمكن التراجع عن ذلك.';

  @override
  String get profileDeleteAccountPasswordHint => 'أدخل كلمة المرور للتأكيد';

  @override
  String get profileDeleteAccountConfirm => 'حذف نهائي';

  @override
  String get profileDeleteAccountCancel => 'إلغاء';

  @override
  String get profileDeleteAccountWrongPassword => 'كلمة المرور غير صحيحة';

  @override
  String get profileDeleteAccountDone => 'تم حذف حسابك';

  @override
  String get profileFreePlanTitle => 'الخطة المجانية';

  @override
  String profileUsageResetsInHours(int hours, String count) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'يتجدد الاستهلاك خلال $count ساعة',
      few: 'يتجدد الاستهلاك خلال $count ساعات',
      two: 'يتجدد الاستهلاك خلال ساعتين',
      one: 'يتجدد الاستهلاك خلال ساعة',
    );
    return '$_temp0';
  }

  @override
  String profileUsageResetsInMinutes(int minutes, String count) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'يتجدد الاستهلاك خلال $count دقيقة',
      few: 'يتجدد الاستهلاك خلال $count دقائق',
      two: 'يتجدد الاستهلاك خلال دقيقتين',
      one: 'يتجدد الاستهلاك خلال دقيقة',
    );
    return '$_temp0';
  }

  @override
  String profileUsagePercent(String percent) {
    return '$percent٪';
  }

  @override
  String get profileUsageToday => 'استهلاك اليوم';

  @override
  String profileUsageRemaining(String percent) {
    return 'متبقٍ $percent٪';
  }

  @override
  String get profileUpgradeToPro => 'الترقية إلى Pro';

  @override
  String get conversationComingSoonTitle => 'وضع الصوت';

  @override
  String get conversationComingSoonBody =>
      'قريبًا — تحدّث واحصل على ترجمة فورية.';

  @override
  String get cameraScanComingSoonTitle => 'وضع الكاميرا';

  @override
  String get cameraScanComingSoonBody =>
      'قريبًا — وجّه الكاميرا لترجمة النص فورًا.';

  @override
  String get errorNetwork =>
      'لا يوجد اتصال بالإنترنت. تحقّق من الشبكة وحاول مرة أخرى.';

  @override
  String get errorServer => 'حدث خطأ من جهتنا. حاول مرة أخرى لاحقًا.';

  @override
  String get errorUnauthorized => 'انتهت صلاحية الجلسة. سجّل الدخول مرة أخرى.';

  @override
  String get errorValidation => 'بعض البيانات التي أدخلتها غير صحيحة.';

  @override
  String get errorClient => 'تعذّر إتمام الطلب.';

  @override
  String get errorTooManyRequests =>
      'محاولات كثيرة. انتظر قليلًا ثم حاول مرة أخرى.';

  @override
  String get errorNotFound => 'لم نعثر على ما تبحث عنه.';

  @override
  String get errorFormat => 'وصلنا رد غير متوقع. حاول مرة أخرى.';

  @override
  String get errorUnsupportedLanguage =>
      'هذه اللغة غير متاحة بدون إنترنت حاليًا.';

  @override
  String get errorUnknown => 'حدث خطأ ما. حاول مرة أخرى.';

  @override
  String get errorEmailAlreadyRegistered =>
      'يوجد حساب مسجّل بهذا البريد الإلكتروني بالفعل.';

  @override
  String get errorQuotaExceeded => 'وصلت إلى الحد المسموح به للترجمة في خطتك.';

  @override
  String get errorTextTooLong =>
      'النص أطول من الحد المسموح به للترجمة الواحدة في خطتك.';

  @override
  String get errorTranslationUnavailable =>
      'الترجمة غير متاحة مؤقتًا. حاول مرة أخرى لاحقًا.';

  @override
  String get errorTranslationTimeout =>
      'استغرقت الترجمة وقتًا أطول من اللازم. حاول مرة أخرى.';

  @override
  String get updateOptionalTitle => 'تحديث جديد متاح';

  @override
  String get updateNewBadge => 'جديد';

  @override
  String updateVersionLabel(String version) {
    return 'v$version';
  }

  @override
  String get updateWhatsNew => 'ما الجديد';

  @override
  String get updateNow => 'تحديث الآن';

  @override
  String get updateLater => 'لاحقًا';

  @override
  String get updateRequiredTitle => 'يلزم تحديث التطبيق';

  @override
  String get updateRequiredBody =>
      'هذا الإصدار لم يعد مدعومًا. حدّث Transly للمتابعة في الترجمة.';

  @override
  String get updateYourVersion => 'إصدارك';

  @override
  String get updateLatestVersion => 'الأحدث';

  @override
  String get updateFromAppStore => 'التحديث من App Store';

  @override
  String get updateFromPlayStore => 'التحديث من Google Play';

  @override
  String get updateStoreOpenFailed => 'تعذّر فتح المتجر. حاول مرة أخرى.';
}
