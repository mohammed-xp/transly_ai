import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/data/models/language_model.dart';
import 'package:transly_ai/core/domain/entities/language_entity.dart';
import 'package:transly_ai/core/errors/app_exceptions.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/features/language_picker/data/datasources/languages_local_data_source.dart';
import 'package:transly_ai/features/language_picker/data/datasources/languages_remote_data_source.dart';
import 'package:transly_ai/features/language_picker/data/repos/languages_repo_impl.dart';

import '../../../../helpers/fake_languages_repo.dart';

class _FakeRemote implements LanguagesRemoteDataSource {
  _FakeRemote({this.languages = const [], this.error});

  final List<LanguageModel> languages;
  final Object? error;

  @override
  Future<List<LanguageModel>> getLanguages() async {
    final error = this.error;
    if (error != null) throw error;
    return languages;
  }
}

class _FakeLocal implements LanguagesLocalDataSource {
  _FakeLocal({
    this.cached,
    this.pair,
    this.recents = const [],
    this.failOnRead = false,
    this.saveError,
  });

  List<LanguageModel>? cached;
  ({LanguageModel from, LanguageModel to})? pair;
  List<LanguageModel> recents;
  int cacheWrites = 0;
  final bool failOnRead;
  final Object? saveError;

  void _checkRead() {
    if (failOnRead) throw const FormatException('corrupted');
  }

  void _checkSave() {
    final error = saveError;
    if (error != null) throw error;
  }

  @override
  List<LanguageModel>? getCachedLanguages() {
    _checkRead();
    return cached;
  }

  @override
  Future<void> cacheLanguages(List<LanguageModel> languages) async {
    _checkSave();
    cacheWrites++;
    cached = languages;
  }

  @override
  ({LanguageModel from, LanguageModel to})? getSavedPair() {
    _checkRead();
    return pair;
  }

  @override
  Future<void> savePair(LanguageModel from, LanguageModel to) async {
    _checkSave();
    pair = (from: from, to: to);
  }

  @override
  List<LanguageModel> getRecentLanguages() {
    _checkRead();
    return recents;
  }

  @override
  Future<void> saveRecentLanguages(List<LanguageModel> languages) async {
    _checkSave();
    recents = languages;
  }
}

final _german = LanguageModel.fromEntity(testGerman);
final _french = LanguageModel.fromEntity(testFrench);

List<String> _codes(ApiResult<List<LanguageEntity>> result) => [
  for (final language in (result as ApiSuccess<List<LanguageEntity>>).data)
    language.code,
];

void main() {
  group('getCachedLanguages', () {
    test('returns the cached languages', () {
      final repo = LanguagesRepoImpl(
        remote: _FakeRemote(),
        local: _FakeLocal(cached: [_german, _french]),
      );

      expect(repo.getCachedLanguages(), [testGerman, testFrench]);
    });

    test('returns no languages when nothing is cached', () {
      final repo = LanguagesRepoImpl(
        remote: _FakeRemote(),
        local: _FakeLocal(),
      );

      expect(repo.getCachedLanguages(), isEmpty);
    });

    test('returns no languages when the cache is unreadable', () {
      final repo = LanguagesRepoImpl(
        remote: _FakeRemote(),
        local: _FakeLocal(failOnRead: true),
      );

      expect(repo.getCachedLanguages(), isEmpty);
    });
  });

  group('syncLanguages', () {
    test('returns the languages from the server', () async {
      final repo = LanguagesRepoImpl(
        remote: _FakeRemote(languages: [_german, _french]),
        local: _FakeLocal(),
      );

      expect(_codes(await repo.syncLanguages()), ['de', 'fr']);
    });

    test('caches the list when nothing was cached', () async {
      final local = _FakeLocal();
      final repo = LanguagesRepoImpl(
        remote: _FakeRemote(languages: [_german, _french]),
        local: local,
      );

      await repo.syncLanguages();

      expect(local.cached, [_german, _french]);
    });

    test('replaces the cache when the server list differs', () async {
      final local = _FakeLocal(cached: [_german]);
      final repo = LanguagesRepoImpl(
        remote: _FakeRemote(languages: [_german, _french]),
        local: local,
      );

      await repo.syncLanguages();

      expect(local.cacheWrites, 1);
      expect(local.cached, [_german, _french]);
    });

    test('replaces the cache when a language changed', () async {
      final local = _FakeLocal(cached: [_german]);
      const renamed = LanguageModel(
        code: 'de',
        name: 'German',
        nativeName: 'Deutsch (DE)',
        isRtl: false,
      );
      final repo = LanguagesRepoImpl(
        remote: _FakeRemote(languages: [renamed]),
        local: local,
      );

      await repo.syncLanguages();

      expect(local.cacheWrites, 1);
    });

    test('leaves the cache alone when the server list is the same', () async {
      final local = _FakeLocal(
        cached: [
          LanguageModel.fromEntity(testGerman),
          LanguageModel.fromEntity(testFrench),
        ],
      );
      final repo = LanguagesRepoImpl(
        remote: _FakeRemote(languages: [_german, _french]),
        local: local,
      );

      await repo.syncLanguages();

      expect(local.cacheWrites, 0);
    });

    test('still returns the server list when caching it fails', () async {
      final repo = LanguagesRepoImpl(
        remote: _FakeRemote(languages: [_german]),
        local: _FakeLocal(saveError: Exception('disk full')),
      );

      expect(_codes(await repo.syncLanguages()), ['de']);
    });

    test('returns the failure when the server fails', () async {
      final repo = LanguagesRepoImpl(
        remote: _FakeRemote(error: const NetworkException()),
        local: _FakeLocal(cached: [_french]),
      );

      final result = await repo.syncLanguages();

      expect(
        (result as ApiFailure<List<LanguageEntity>>).failure,
        isA<NetworkFailure>(),
      );
    });

    test('keeps the cache when the server fails', () async {
      final local = _FakeLocal(cached: [_french]);
      final repo = LanguagesRepoImpl(
        remote: _FakeRemote(error: const NetworkException()),
        local: local,
      );

      await repo.syncLanguages();

      expect(local.cacheWrites, 0);
      expect(local.cached, [_french]);
    });
  });

  group('getSavedPair', () {
    test('returns the saved pair', () {
      final repo = LanguagesRepoImpl(
        remote: _FakeRemote(),
        local: _FakeLocal(pair: (from: _german, to: _french)),
      );

      expect(repo.getSavedPair(), (from: testGerman, to: testFrench));
    });

    test('falls back to the default pair when none is saved', () {
      final repo = LanguagesRepoImpl(
        remote: _FakeRemote(),
        local: _FakeLocal(),
      );

      expect(repo.getSavedPair(), (
        from: LanguageEntity.defaultSource,
        to: LanguageEntity.defaultTarget,
      ));
    });

    test('falls back to the default pair when storage is unreadable', () {
      final repo = LanguagesRepoImpl(
        remote: _FakeRemote(),
        local: _FakeLocal(failOnRead: true),
      );

      expect(repo.getSavedPair(), (
        from: LanguageEntity.defaultSource,
        to: LanguageEntity.defaultTarget,
      ));
    });
  });

  group('savePair', () {
    test('saves both languages', () async {
      final local = _FakeLocal();
      final repo = LanguagesRepoImpl(remote: _FakeRemote(), local: local);

      final result = await repo.savePair((from: testGerman, to: testFrench));

      expect(result, isA<ApiSuccess<void>>());
      expect((local.pair!.from.code, local.pair!.to.code), ('de', 'fr'));
    });

    test('returns a failure when storage throws', () async {
      final repo = LanguagesRepoImpl(
        remote: _FakeRemote(),
        local: _FakeLocal(saveError: Exception('disk full')),
      );

      final result = await repo.savePair((from: testGerman, to: testFrench));

      expect((result as ApiFailure<void>).failure, isA<UnknownFailure>());
    });
  });

  group('recent languages', () {
    test('returns the saved recents in order', () {
      final repo = LanguagesRepoImpl(
        remote: _FakeRemote(),
        local: _FakeLocal(recents: [_french, _german]),
      );

      expect(repo.getRecentLanguages(), [testFrench, testGerman]);
    });

    test('returns no recents when storage is unreadable', () {
      final repo = LanguagesRepoImpl(
        remote: _FakeRemote(),
        local: _FakeLocal(failOnRead: true),
      );

      expect(repo.getRecentLanguages(), isEmpty);
    });

    test('saves the recents', () async {
      final local = _FakeLocal();
      final repo = LanguagesRepoImpl(remote: _FakeRemote(), local: local);

      await repo.saveRecentLanguages([testFrench, testGerman]);

      expect([for (final recent in local.recents) recent.code], ['fr', 'de']);
    });

    test('returns a failure when saving the recents throws', () async {
      final repo = LanguagesRepoImpl(
        remote: _FakeRemote(),
        local: _FakeLocal(saveError: Exception('disk full')),
      );

      final result = await repo.saveRecentLanguages([testFrench]);

      expect(result, isA<ApiFailure<void>>());
    });
  });
}
