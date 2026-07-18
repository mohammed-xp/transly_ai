/// Languages the translate feature can handle. Pure Dart — no Flutter, no ML Kit.
///
/// Extensible by design: adding a language is one enum value here, one arm in
/// `translate_language_mapper.dart`, and two l10n label keys. [code] is the
/// BCP-47 tag; [isRtl] drives output text direction in the UI.
enum Language {
  english(code: 'en', isRtl: false),
  arabic(code: 'ar', isRtl: true);

  const Language({required this.code, required this.isRtl});

  final String code;
  final bool isRtl;
}
