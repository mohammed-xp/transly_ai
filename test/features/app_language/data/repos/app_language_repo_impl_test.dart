import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/features/app_language/data/datasources/app_language_local_data_source.dart';
import 'package:transly_ai/features/app_language/data/repos/app_language_repo_impl.dart';
import 'package:transly_ai/features/app_language/domain/entities/app_language.dart';

class _FakeDataSource implements AppLanguageLocalDataSource {
  _FakeDataSource({this.code, this.failOnRead = false, this.saveError});

  String? code;
  final bool failOnRead;
  final Object? saveError;

  @override
  String? getLanguageCode() {
    if (failOnRead) throw StateError('box closed');
    return code;
  }

  @override
  Future<void> saveLanguageCode(String? code) async {
    final error = saveError;
    if (error != null) throw error;
    this.code = code;
  }
}

const _supported = {'ar', 'en'};

AppLanguageRepoImpl _repo(_FakeDataSource dataSource) =>
    AppLanguageRepoImpl(dataSource, supportedCodes: _supported);

void main() {
  group('getLanguage', () {
    test('maps the saved code to its language', () {
      final repo = _repo(_FakeDataSource(code: 'ar'));

      expect(repo.getLanguage(), const AppLanguage('ar'));
    });

    test('falls back to the device language when nothing is saved', () {
      final repo = _repo(_FakeDataSource());

      expect(repo.getLanguage(), AppLanguage.device);
    });

    test('falls back to the device language for an unsupported code', () {
      final repo = _repo(_FakeDataSource(code: 'fr'));

      expect(repo.getLanguage(), AppLanguage.device);
    });

    test('falls back to the device language when storage throws', () {
      final repo = _repo(_FakeDataSource(failOnRead: true));

      expect(repo.getLanguage(), AppLanguage.device);
    });
  });

  group('saveLanguage', () {
    test('saves the language code', () async {
      final dataSource = _FakeDataSource();
      final repo = _repo(dataSource);

      final result = await repo.saveLanguage(const AppLanguage('en'));

      expect(result, isA<ApiSuccess<void>>());
      expect(dataSource.code, 'en');
    });

    test('clears the saved code for the device language', () async {
      final dataSource = _FakeDataSource(code: 'ar');
      final repo = _repo(dataSource);

      await repo.saveLanguage(AppLanguage.device);

      expect(dataSource.code, isNull);
    });

    test('returns a failure when storage throws', () async {
      final repo = _repo(_FakeDataSource(saveError: Exception('disk full')));

      final result = await repo.saveLanguage(const AppLanguage('ar'));

      expect(result, isA<ApiFailure<void>>());
      expect((result as ApiFailure<void>).failure, isA<UnknownFailure>());
    });
  });
}
