import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/data/datasources/offline_models_data_source.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/core/services/connectivity_service.dart';
import 'package:transly_ai/features/translate/data/datasources/tones_remote_data_source.dart';
import 'package:transly_ai/features/translate/data/datasources/translation_local_data_source.dart';
import 'package:transly_ai/features/translate/data/datasources/translation_remote_data_source.dart';
import 'package:transly_ai/features/translate/data/datasources/translation_settings_local_data_source.dart';
import 'package:transly_ai/features/translate/data/models/tone_catalog_model.dart';
import 'package:transly_ai/features/translate/data/models/tone_model.dart';
import 'package:transly_ai/features/translate/data/repos/translation_repo_impl.dart';
import 'package:transly_ai/features/translate/domain/entities/tone_catalog.dart';

const _catalog = ToneCatalogModel(
  tones: [
    ToneModel(code: 'formal', name: 'Formal', nameAr: 'رسمية'),
    ToneModel(code: 'casual', name: 'Casual', nameAr: 'عامية'),
  ],
  defaultTone: 'formal',
);

class _FakeSettings implements TranslationSettingsLocalDataSource {
  _FakeSettings({
    this.code,
    this.tones,
    this.failOnRead = false,
    this.saveError,
  });

  String? code;
  ToneCatalogModel? tones;
  final bool failOnRead;
  final Object? saveError;

  @override
  String? getToneCode() {
    if (failOnRead) throw StateError('box closed');
    return code;
  }

  @override
  Future<void> saveToneCode(String code) async {
    final error = saveError;
    if (error != null) throw error;
    this.code = code;
  }

  @override
  ToneCatalogModel? getCachedTones() {
    if (failOnRead) throw StateError('box closed');
    return tones;
  }

  @override
  Future<void> cacheTones(ToneCatalogModel tones) async {
    final error = saveError;
    if (error != null) throw error;
    this.tones = tones;
  }
}

class _FakeRemoteTones implements TonesRemoteDataSource {
  _FakeRemoteTones({this.error});

  final Object? error;

  @override
  Future<ToneCatalogModel> getTones() async {
    final error = this.error;
    if (error != null) throw error;
    return _catalog;
  }
}

class _UnusedLocal implements TranslationLocalDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedModels implements OfflineModelsDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedRemote implements TranslationRemoteDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedConnectivity implements ConnectivityService {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

TranslationRepoImpl _buildRepo(
  _FakeSettings settings, {
  _FakeRemoteTones? remoteTones,
}) => TranslationRepoImpl(
  local: _UnusedLocal(),
  models: _UnusedModels(),
  connectivity: _UnusedConnectivity(),
  remote: _UnusedRemote(),
  remoteTones: remoteTones ?? _FakeRemoteTones(),
  settings: settings,
);

void main() {
  group('getCachedTones', () {
    test('maps the cached tones to entities', () {
      final repo = _buildRepo(_FakeSettings(tones: _catalog));

      final catalog = repo.getCachedTones();

      expect(catalog?.tones.map((t) => t.code), ['formal', 'casual']);
      expect(catalog?.defaultCode, 'formal');
    });

    test('returns null when nothing is cached', () {
      final repo = _buildRepo(_FakeSettings());

      expect(repo.getCachedTones(), isNull);
    });

    test('returns null when storage throws', () {
      final repo = _buildRepo(_FakeSettings(failOnRead: true));

      expect(repo.getCachedTones(), isNull);
    });
  });

  group('syncTones', () {
    test('returns the server tones and caches them', () async {
      final settings = _FakeSettings();
      final repo = _buildRepo(settings);

      final result = await repo.syncTones();

      expect(result, isA<ApiSuccess<ToneCatalog>>());
      expect(settings.tones, same(_catalog));
    });

    test('still succeeds when caching fails', () async {
      final repo = _buildRepo(_FakeSettings(saveError: StateError('disk')));

      final result = await repo.syncTones();

      expect(result, isA<ApiSuccess<ToneCatalog>>());
    });

    test('returns a failure when the request fails', () async {
      final repo = _buildRepo(
        _FakeSettings(),
        remoteTones: _FakeRemoteTones(error: StateError('offline')),
      );

      final result = await repo.syncTones();

      expect(result, isA<ApiFailure<ToneCatalog>>());
    });
  });

  group('getSavedToneCode', () {
    test('returns the saved code', () {
      final repo = _buildRepo(_FakeSettings(code: 'casual'));

      expect(repo.getSavedToneCode(), 'casual');
    });

    test('returns null when storage throws', () {
      final repo = _buildRepo(_FakeSettings(failOnRead: true));

      expect(repo.getSavedToneCode(), isNull);
    });
  });

  group('saveToneCode', () {
    test('saves the code', () async {
      final settings = _FakeSettings();
      final repo = _buildRepo(settings);

      final result = await repo.saveToneCode('concise');

      expect(result, isA<ApiSuccess<void>>());
      expect(settings.code, 'concise');
    });

    test('returns a failure when storage throws', () async {
      final repo = _buildRepo(_FakeSettings(saveError: StateError('disk')));

      final result = await repo.saveToneCode('casual');

      expect(result, isA<ApiFailure<void>>());
    });
  });
}
