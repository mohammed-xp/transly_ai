import 'package:google_mlkit_translation/google_mlkit_translation.dart';

import '../../domain/entities/language.dart';

/// Maps a domain [Language] to ML Kit's [TranslateLanguage]. The exhaustive
/// switch makes adding a new [Language] a compile error until it is mapped.
TranslateLanguage toMlKitLanguage(Language language) {
  return switch (language) {
    Language.english => TranslateLanguage.english,
    Language.arabic => TranslateLanguage.arabic,
  };
}
