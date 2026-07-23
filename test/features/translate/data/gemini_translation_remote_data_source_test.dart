import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/errors/app_exceptions.dart';
import 'package:transly_ai/core/network/rest_client.dart';
import 'package:transly_ai/features/translate/data/datasources/gemini_translation_remote_data_source.dart';
import 'package:transly_ai/features/translate/domain/entities/language.dart';
import 'package:transly_ai/features/translate/domain/entities/translation_tone.dart';

/// Hand-written fake — no mocking framework in this project. Records the
/// outgoing call and either returns a canned decoded JSON body or throws the
/// exception the test configured, exactly as a real [RestClient] would.
class _FakeRestClient implements RestClient {
  String? lastUrl;
  Map<String, String>? lastHeaders;
  Object? lastBody;

  dynamic responseJson = <String, dynamic>{};
  Object? throwOnPost;

  @override
  Future<dynamic> postJson(
    String url, {
    Map<String, String>? headers,
    required Object body,
  }) async {
    lastUrl = url;
    lastHeaders = headers;
    lastBody = body;
    if (throwOnPost != null) throw throwOnPost!;
    return responseJson;
  }
}

Map<String, dynamic> _successBody(String text) => {
      'candidates': [
        {
          'content': {
            'parts': [
              {'text': text},
            ],
          },
          'finishReason': 'STOP',
        },
      ],
    };

void main() {
  late _FakeRestClient restClient;
  late GeminiTranslationRemoteDataSource dataSource;

  setUp(() {
    restClient = _FakeRestClient();
    dataSource =
        GeminiTranslationRemoteDataSource(restClient: restClient, apiKey: 'test-key');
  });

  group('GeminiTranslationRemoteDataSource.translate', () {
    test('posts to the model URL with the api key header and prompt body',
        () async {
      restClient.responseJson = _successBody('مرحبا');

      await dataSource.translate(
        text: 'hello',
        from: Language.english,
        to: Language.arabic,
        tone: TranslationTone.casual,
      );

      expect(
        restClient.lastUrl,
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent',
      );
      expect(restClient.lastHeaders!['x-goog-api-key'], 'test-key');

      final body = restClient.lastBody! as Map<String, dynamic>;
      expect(body['generationConfig']['temperature'], 0.2);
      expect(body['generationConfig']['thinkingConfig']['thinkingBudget'], 0);

      final prompt = body['contents'][0]['parts'][0]['text'] as String;
      expect(prompt, contains('English'));
      expect(prompt, contains('Arabic'));
      expect(prompt, contains('relaxed, conversational'));
      expect(prompt, contains('hello'));
      expect(prompt, contains('ONLY the translated text'));
    });

    test('parses the translated text from candidates', () async {
      restClient.responseJson = _successBody('مرحبا');

      final result = await dataSource.translate(
        text: 'hello',
        from: Language.english,
        to: Language.arabic,
        tone: TranslationTone.formal,
      );

      expect(result, 'مرحبا');
    });

    test('trims whitespace around the translated text', () async {
      restClient.responseJson = _successBody('  مرحبا  \n');

      final result = await dataSource.translate(
        text: 'hello',
        from: Language.english,
        to: Language.arabic,
        tone: TranslationTone.formal,
      );

      expect(result, 'مرحبا');
    });

    test('throws RemoteApiException when candidates are empty', () async {
      restClient.responseJson = {'candidates': <dynamic>[]};

      expect(
        () => dataSource.translate(
          text: 'hello',
          from: Language.english,
          to: Language.arabic,
          tone: TranslationTone.formal,
        ),
        throwsA(isA<RemoteApiException>()),
      );
    });

    test('throws RemoteApiException when promptFeedback blocks the request',
        () async {
      restClient.responseJson = {
        'promptFeedback': {'blockReason': 'SAFETY'},
      };

      expect(
        () => dataSource.translate(
          text: 'hello',
          from: Language.english,
          to: Language.arabic,
          tone: TranslationTone.formal,
        ),
        throwsA(isA<RemoteApiException>()),
      );
    });

    test('throws RemoteApiException when finishReason is SAFETY with no text',
        () async {
      restClient.responseJson = {
        'candidates': [
          {
            'content': {'parts': <dynamic>[]},
            'finishReason': 'SAFETY',
          },
        ],
      };

      expect(
        () => dataSource.translate(
          text: 'hello',
          from: Language.english,
          to: Language.arabic,
          tone: TranslationTone.formal,
        ),
        throwsA(isA<RemoteApiException>()),
      );
    });

    test('propagates a RemoteApiException raised by the RestClient', () async {
      restClient.throwOnPost = const RemoteApiException('HTTP 429');

      expect(
        () => dataSource.translate(
          text: 'hello',
          from: Language.english,
          to: Language.arabic,
          tone: TranslationTone.formal,
        ),
        throwsA(isA<RemoteApiException>()),
      );
    });

    test('propagates a RemoteConnectionException raised by the RestClient',
        () async {
      restClient.throwOnPost = const RemoteConnectionException('timeout');

      expect(
        () => dataSource.translate(
          text: 'hello',
          from: Language.english,
          to: Language.arabic,
          tone: TranslationTone.formal,
        ),
        throwsA(isA<RemoteConnectionException>()),
      );
    });
  });
}
