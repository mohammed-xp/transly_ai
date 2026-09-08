import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/errors/app_exceptions.dart';
import 'package:transly_ai/core/network/api_endpoints.dart';
import 'package:transly_ai/core/network/rest_client.dart';
import 'package:transly_ai/features/translate/data/datasources/api_translation_remote_data_source.dart';
import 'package:transly_ai/features/translate/domain/entities/language.dart';
import 'package:transly_ai/features/translate/domain/entities/translation_tone.dart';

/// Hand-written fake — no mocking framework in this project (see
/// `dio_rest_client_test.dart`).
class _FakeRestClient implements RestClient {
  String? lastUrl;
  Object? lastBody;
  dynamic responseToReturn = <String, dynamic>{'translatedText': 'مرحبا'};
  Object? throwOnPost;

  @override
  Future<dynamic> postJson(
    String url, {
    Map<String, String>? headers,
    required Object body,
  }) async {
    lastUrl = url;
    lastBody = body;
    if (throwOnPost != null) throw throwOnPost!;
    return responseToReturn;
  }
}

void main() {
  late _FakeRestClient restClient;
  late ApiTranslationRemoteDataSource dataSource;

  setUp(() {
    restClient = _FakeRestClient();
    dataSource = ApiTranslationRemoteDataSource(restClient);
  });

  test(
    'posts to the translations endpoint with the expected body shape',
    () async {
      await dataSource.translate(
        text: 'Hello world',
        from: Language.english,
        to: Language.arabic,
        tone: TranslationTone.casual,
      );

      expect(
        restClient.lastUrl,
        '${ApiEndpoints.baseUrl}${ApiEndpoints.translations}',
      );
      expect(restClient.lastBody, {
        'text': 'Hello world',
        'sourceLanguage': 'en',
        'targetLanguage': 'ar',
        'tone': 'casual',
      });
    },
  );

  test('returns the parsed translated text', () async {
    restClient.responseToReturn = {'translatedText': 'Where you at, man?'};

    final result = await dataSource.translate(
      text: 'فينك يسطا',
      from: Language.arabic,
      to: Language.english,
      tone: TranslationTone.casual,
    );

    expect(result.translatedText, 'Where you at, man?');
  });

  test('propagates the exception when the response is malformed', () async {
    restClient.responseToReturn = {'unexpected': true};

    expect(
      () => dataSource.translate(
        text: 'hi',
        from: Language.english,
        to: Language.arabic,
        tone: TranslationTone.formal,
      ),
      throwsA(isA<RemoteApiException>()),
    );
  });

  test(
    'propagates transport/auth exceptions from the RestClient unchanged',
    () async {
      restClient.throwOnPost = const UnauthorizedException('HTTP 401');

      expect(
        () => dataSource.translate(
          text: 'hi',
          from: Language.english,
          to: Language.arabic,
          tone: TranslationTone.formal,
        ),
        throwsA(isA<UnauthorizedException>()),
      );
    },
  );
}
