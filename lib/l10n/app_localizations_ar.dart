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
  String get languageEnglish => 'الإنجليزية';

  @override
  String get languageArabic => 'العربية';

  @override
  String get translateSourceHint => 'اكتب النص المراد ترجمته…';

  @override
  String get translateDownloadingModel => 'جارٍ تنزيل نموذج الترجمة…';

  @override
  String get translateListen => 'استماع';

  @override
  String get translateErrorGeneric => 'تعذّرت الترجمة. حاول مرة أخرى.';

  @override
  String get translateErrorModelDownload =>
      'تعذّر تنزيل نموذج الترجمة. تحقّق من الاتصال وحاول مجددًا.';

  @override
  String get translateErrorNoConnection => 'لا يوجد اتصال بالإنترنت.';
}
