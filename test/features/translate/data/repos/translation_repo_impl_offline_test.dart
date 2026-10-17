import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/data/datasources/offline_models_data_source.dart';
import 'package:transly_ai/core/data/models/language_model.dart';
import 'package:transly_ai/core/domain/entities/language_entity.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/core/services/connectivity_service.dart';
import 'package:transly_ai/features/translate/data/datasources/tones_remote_data_source.dart';
import 'package:transly_ai/features/translate/data/datasources/translation_local_data_source.dart';
import 'package:transly_ai/features/translate/data/datasources/translation_remote_data_source.dart';
import 'package:transly_ai/features/translate/data/datasources/translation_settings_local_data_source.dart';
import 'package:transly_ai/features/translate/data/models/translation_response_model.dart';
import 'package:transly_ai/features/translate/data/repos/translation_repo_impl.dart';
import 'package:transly_ai/features/translate/domain/entities/translation_engine.dart';
import 'package:transly_ai/features/translate/domain/entities/translation_entity.dart';

class _FakeLocal implements TranslationLocalDataSource {
  int calls = 0;

  @override
  Future<String> translate(
    String text,
    LanguageModel from,
    LanguageModel to,
  ) async {
    calls++;
    return 'offline:$text';
  }
}

class _FakeModels implements OfflineModelsDataSource {
  final Set<String> supported = {'en', 'ar', 'fr'};
  final Set<String> downloaded = {'en', 'fr'};
  int checks = 0;

  @override
  bool isSupported(String code) => supported.contains(code);

  @override
  bool isBuiltIn(String code) => code == 'en';

  @override
  Future<bool> isDownloaded(String code) async {
    checks++;
    return downloaded.contains(code);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeConnectivity implements ConnectivityService {
  _FakeConnectivity({required this.connected});

  final bool connected;

  @override
  Future<bool> get isConnected async => connected;

  @override
  Stream<bool> get onConnectedChanged => const Stream.empty();

  @override
  Future<bool> get isOnWifi async => connected;
}

class _FakeRemote implements TranslationRemoteDataSource {
  @override
  Future<TranslationResponseModel> translate({
    required String text,
    required String from,
    required String to,
    required String? tone,
  }) async => TranslationResponseModel(
    sourceText: text,
    translatedText: 'online:$text',
    sourceLanguage: LanguageModel.fromEntity(LanguageEntity.english),
    targetLanguage: LanguageModel.fromEntity(_french),
    model: 'test',
    createdAt: DateTime(2026),
  );
}

class _UnusedRemoteTones implements TonesRemoteDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedSettings implements TranslationSettingsLocalDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

const _french = LanguageEntity(
  code: 'fr',
  name: 'French',
  nativeName: 'Français',
  isRtl: false,
);

const _unsupported = LanguageEntity(
  code: 'xx',
  name: 'Unknown',
  nativeName: 'Unknown',
  isRtl: false,
);

void main() {
  late _FakeLocal local;
  late _FakeModels models;

  setUp(() {
    local = _FakeLocal();
    models = _FakeModels();
  });

  TranslationRepoImpl buildRepo({required bool connected}) =>
      TranslationRepoImpl(
        local: local,
        models: models,
        connectivity: _FakeConnectivity(connected: connected),
        remote: _FakeRemote(),
        remoteTones: _UnusedRemoteTones(),
        settings: _UnusedSettings(),
      );

  Future<ApiResult<TranslationEntity>> translate(
    TranslationRepoImpl repo, {
    required LanguageEntity to,
  }) => repo.translate(
    text: 'hi',
    from: LanguageEntity.english,
    to: to,
    tone: 'formal',
  );

  Failure failureOf(ApiResult<TranslationEntity> result) =>
      (result as ApiFailure<TranslationEntity>).failure;

  group('offline', () {
    test('translates on the device when both models are there', () async {
      final result = await translate(buildRepo(connected: false), to: _french);

      final translation = (result as ApiSuccess<TranslationEntity>).data;
      expect(translation.translatedText, 'offline:hi');
      expect(translation.engine, TranslationEngine.offline);
    });

    test('does not need a download for the built-in language', () async {
      models.downloaded.remove('en');

      final result = await translate(buildRepo(connected: false), to: _french);

      expect(result, isA<ApiSuccess<TranslationEntity>>());
    });

    test('fails with a missing model when one is not downloaded', () async {
      final result = await translate(
        buildRepo(connected: false),
        to: LanguageEntity.arabic,
      );

      expect(failureOf(result), isA<OfflineModelMissingFailure>());
    });

    test('does not ask ML Kit to translate when a model is missing', () async {
      await translate(buildRepo(connected: false), to: LanguageEntity.arabic);

      expect(local.calls, 0);
    });

    test(
      'fails as unsupported for a language ML Kit has no model for',
      () async {
        final result = await translate(
          buildRepo(connected: false),
          to: _unsupported,
        );

        expect(failureOf(result), isA<UnsupportedLanguageFailure>());
      },
    );
  });

  group('online', () {
    test('does not check the on-device models', () async {
      await translate(buildRepo(connected: true), to: LanguageEntity.arabic);

      expect(models.checks, 0);
    });
  });
}
