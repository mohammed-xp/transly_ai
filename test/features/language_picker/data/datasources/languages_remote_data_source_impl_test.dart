import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/network/endpoints.dart';
import 'package:transly_ai/features/language_picker/data/datasources/languages_remote_data_source_impl.dart';

import '../../../../helpers/fake_api_consumer.dart';

void main() {
  test('requests the languages endpoint', () async {
    final api = FakeApiConsumer(const {
      'data': {'languages': <dynamic>[]},
    });

    await LanguagesRemoteDataSourceImpl(api).getLanguages();

    expect(api.requestedUrls, [Endpoints.languages]);
  });

  test('reads the languages under data.languages', () async {
    final api = FakeApiConsumer(const {
      'data': {
        'languages': [
          {
            'code': 'de',
            'name': 'German',
            'nativeName': 'Deutsch',
            'isRtl': false,
          },
          {
            'code': 'ar',
            'name': 'Arabic',
            'nativeName': 'العربية',
            'isRtl': true,
          },
        ],
      },
    });

    final languages = await LanguagesRemoteDataSourceImpl(api).getLanguages();

    expect([for (final language in languages) language.code], ['de', 'ar']);
    expect(languages.last.isRtl, isTrue);
  });

  test('throws a TypeError when data is missing', () async {
    final api = FakeApiConsumer(const {});

    await expectLater(
      LanguagesRemoteDataSourceImpl(api).getLanguages(),
      throwsA(isA<TypeError>()),
    );
  });

  test('throws a TypeError when a language is malformed', () async {
    final api = FakeApiConsumer(const {
      'data': {
        'languages': [
          {'code': 'de', 'name': 'German'},
        ],
      },
    });

    await expectLater(
      LanguagesRemoteDataSourceImpl(api).getLanguages(),
      throwsA(isA<TypeError>()),
    );
  });
}
