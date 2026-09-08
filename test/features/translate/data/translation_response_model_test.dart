import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/errors/app_exceptions.dart';
import 'package:transly_ai/features/translate/data/models/translation_response_model.dart';

void main() {
  group('TranslationResponseModel.fromJson', () {
    test('parses a well-formed response', () {
      final model = TranslationResponseModel.fromJson({
        'sourceText': 'فينك يسطا',
        'translatedText': 'Where you at, man?',
        'sourceLanguage': 'ar',
        'targetLanguage': 'en',
        'tone': 'casual',
        'model': 'gemini-3.1-flash-lite',
        'createdAt': '2026-08-30T12:59:42.981205+00:00',
      });

      expect(model.translatedText, 'Where you at, man?');
      expect(model.model, 'gemini-3.1-flash-lite');
      expect(
        model.createdAt,
        DateTime.parse('2026-08-30T12:59:42.981205+00:00'),
      );
    });

    test('parses a response with no model/createdAt', () {
      final model = TranslationResponseModel.fromJson({
        'translatedText': 'Hello',
      });

      expect(model.translatedText, 'Hello');
      expect(model.model, isNull);
      expect(model.createdAt, isNull);
    });

    test('throws RemoteApiException when translatedText is missing', () {
      expect(
        () => TranslationResponseModel.fromJson({'sourceText': 'x'}),
        throwsA(isA<RemoteApiException>()),
      );
    });

    test('throws RemoteApiException when translatedText is empty', () {
      expect(
        () => TranslationResponseModel.fromJson({'translatedText': ''}),
        throwsA(isA<RemoteApiException>()),
      );
    });

    test(
      'throws RemoteApiException when the response is not a JSON object',
      () {
        expect(
          () => TranslationResponseModel.fromJson('not json'),
          throwsA(isA<RemoteApiException>()),
        );
      },
    );
  });
}
