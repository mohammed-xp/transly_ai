import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:transly_ai/features/translate/data/mappers/translate_language_mapper.dart';
import 'package:transly_ai/features/translate/domain/entities/language.dart';

void main() {
  group('toMlKitLanguage', () {
    test('maps english to TranslateLanguage.english', () {
      expect(toMlKitLanguage(Language.english), TranslateLanguage.english);
    });

    test('maps arabic to TranslateLanguage.arabic', () {
      expect(toMlKitLanguage(Language.arabic), TranslateLanguage.arabic);
    });

    test('every Language maps to a TranslateLanguage with matching bcp code',
        () {
      // Guards against a new Language enum value missing its mapper arm.
      for (final language in Language.values) {
        expect(toMlKitLanguage(language).bcpCode, language.code);
      }
    });
  });
}
