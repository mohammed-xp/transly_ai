import 'package:google_mlkit_translation/google_mlkit_translation.dart';

import '../../errors/app_exceptions.dart';

/// The ML Kit language for a backend language [code].
///
/// Throws [UnsupportedLanguageException] when ML Kit has no on-device model
/// for it.
TranslateLanguage mlKitLanguage(String code) {
  final language = BCP47Code.fromRawValue(code.toLowerCase());
  if (language == null) throw const UnsupportedLanguageException();
  return language;
}
