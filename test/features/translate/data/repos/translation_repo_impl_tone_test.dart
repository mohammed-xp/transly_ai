import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/data/datasources/offline_models_data_source.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/core/services/connectivity_service.dart';
import 'package:transly_ai/features/translate/data/datasources/translation_local_data_source.dart';
import 'package:transly_ai/features/translate/data/datasources/translation_remote_data_source.dart';
import 'package:transly_ai/features/translate/data/datasources/translation_settings_local_data_source.dart';
import 'package:transly_ai/features/translate/data/repos/translation_repo_impl.dart';
import 'package:transly_ai/features/translate/domain/entities/translation_tone.dart';

class _FakeSettings implements TranslationSettingsLocalDataSource {
  _FakeSettings({this.name, this.failOnRead = false, this.saveError});

  String? name;
  final bool failOnRead;
  final Object? saveError;

  @override
  String? getToneName() {
    if (failOnRead) throw StateError('box closed');
    return name;
  }

  @override
  Future<void> saveToneName(String name) async {
    final error = saveError;
    if (error != null) throw error;
    this.name = name;
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

TranslationRepoImpl _buildRepo(_FakeSettings settings) => TranslationRepoImpl(
  local: _UnusedLocal(),
  models: _UnusedModels(),
  connectivity: _UnusedConnectivity(),
  remote: _UnusedRemote(),
  settings: settings,
);

void main() {
  group('getSavedTone', () {
    test('maps the saved name to its tone', () {
      final repo = _buildRepo(_FakeSettings(name: 'casual'));

      expect(repo.getSavedTone(), TranslationTone.casual);
    });

    test('falls back to formal when nothing is saved', () {
      final repo = _buildRepo(_FakeSettings());

      expect(repo.getSavedTone(), TranslationTone.formal);
    });

    test('falls back to formal for an unknown name', () {
      final repo = _buildRepo(_FakeSettings(name: 'poetic'));

      expect(repo.getSavedTone(), TranslationTone.formal);
    });

    test('falls back to formal when storage throws', () {
      final repo = _buildRepo(_FakeSettings(failOnRead: true));

      expect(repo.getSavedTone(), TranslationTone.formal);
    });
  });

  group('saveTone', () {
    test('saves the tone name', () async {
      final settings = _FakeSettings();
      final repo = _buildRepo(settings);

      final result = await repo.saveTone(TranslationTone.concise);

      expect(result, isA<ApiSuccess<void>>());
      expect(settings.name, 'concise');
    });

    test('returns a failure when storage throws', () async {
      final repo = _buildRepo(_FakeSettings(saveError: StateError('disk')));

      final result = await repo.saveTone(TranslationTone.casual);

      expect(result, isA<ApiFailure<void>>());
    });
  });
}
