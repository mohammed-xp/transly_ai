import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/errors/app_exceptions.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/core/services/connectivity_service.dart';
import 'package:transly_ai/features/translate/data/datasources/translation_local_data_source.dart';
import 'package:transly_ai/features/translate/data/datasources/translation_remote_data_source.dart';
import 'package:transly_ai/features/translate/data/repos/translation_repository_impl.dart';
import 'package:transly_ai/features/translate/domain/entities/language.dart';
import 'package:transly_ai/features/translate/domain/entities/translation_engine.dart';
import 'package:transly_ai/features/translate/domain/entities/translation_tone.dart';

class _FakeLocalDataSource implements TranslationLocalDataSource {
  bool modelsDownloaded = true;
  Object? throwOnTranslate;
  Object? throwOnCheck;
  Object? throwOnDownload;

  bool translateCalled = false;
  bool downloadCalled = false;

  @override
  Future<bool> areModelsDownloaded(Language from, Language to) async {
    if (throwOnCheck != null) throw throwOnCheck!;
    return modelsDownloaded;
  }

  @override
  Future<void> downloadModels(Language from, Language to) async {
    downloadCalled = true;
    if (throwOnDownload != null) throw throwOnDownload!;
  }

  @override
  Future<String> translate(String text, Language from, Language to) async {
    translateCalled = true;
    if (throwOnTranslate != null) throw throwOnTranslate!;
    return 'local:$text';
  }
}

class _FakeRemoteDataSource implements TranslationRemoteDataSource {
  bool translateCalled = false;
  TranslationTone? receivedTone;
  Object? throwOnTranslate;

  @override
  Future<String> translate({
    required String text,
    required Language from,
    required Language to,
    required TranslationTone tone,
  }) async {
    translateCalled = true;
    receivedTone = tone;
    if (throwOnTranslate != null) throw throwOnTranslate!;
    return 'remote:$text';
  }
}

class _FakeConnectivity implements ConnectivityService {
  _FakeConnectivity(this._connected);
  final bool _connected;

  @override
  Future<bool> get isConnected async => _connected;
}

void main() {
  group('TranslationRepositoryImpl.translate', () {
    test('returns success with a TranslationEntity from the local source', () async {
      final local = _FakeLocalDataSource();
      final repo = TranslationRepositoryImpl(
        local: local,
        connectivity: _FakeConnectivity(false),
      );

      final result = await repo.translate(
        text: 'hi',
        from: Language.english,
        to: Language.arabic,
        tone: TranslationTone.formal,
      );

      expect(result, isA<ApiSuccess<dynamic>>());
      final entity = (result as ApiSuccess).data;
      expect(entity.translatedText, 'local:hi');
      expect(entity.sourceText, 'hi');
      expect(entity.from, Language.english);
      expect(entity.to, Language.arabic);
    });

    test('maps a thrown exception to TranslationFailure', () async {
      final local = _FakeLocalDataSource()..throwOnTranslate = Exception('boom');
      final repo = TranslationRepositoryImpl(
        local: local,
        connectivity: _FakeConnectivity(false),
      );

      final result = await repo.translate(
        text: 'hi',
        from: Language.english,
        to: Language.arabic,
        tone: TranslationTone.formal,
      );

      expect(result, isA<ApiFailure<dynamic>>());
      expect((result as ApiFailure).failure, isA<TranslationFailure>());
    });

    test('routes to remote (tone-aware) when a remote exists and is connected',
        () async {
      final local = _FakeLocalDataSource();
      final remote = _FakeRemoteDataSource();
      final repo = TranslationRepositoryImpl(
        local: local,
        connectivity: _FakeConnectivity(true),
        remote: remote,
      );

      final result = await repo.translate(
        text: 'hi',
        from: Language.english,
        to: Language.arabic,
        tone: TranslationTone.casual,
      );

      expect(remote.translateCalled, isTrue);
      expect(remote.receivedTone, TranslationTone.casual);
      expect(local.translateCalled, isFalse);
      final entity = (result as ApiSuccess).data;
      expect(entity.translatedText, 'remote:hi');
      expect(entity.engine, TranslationEngine.online);
    });

    test('routes to local when a remote exists but the device is offline',
        () async {
      final local = _FakeLocalDataSource();
      final remote = _FakeRemoteDataSource();
      final repo = TranslationRepositoryImpl(
        local: local,
        connectivity: _FakeConnectivity(false),
        remote: remote,
      );

      final result = await repo.translate(
        text: 'hi',
        from: Language.english,
        to: Language.arabic,
        tone: TranslationTone.formal,
      );

      expect(local.translateCalled, isTrue);
      expect(remote.translateCalled, isFalse);
      expect((result as ApiSuccess).data.engine, TranslationEngine.offline);
    });

    test('routes to local when no remote is configured', () async {
      final local = _FakeLocalDataSource();
      final repo = TranslationRepositoryImpl(
        local: local,
        connectivity: _FakeConnectivity(true),
      );

      await repo.translate(
        text: 'hi',
        from: Language.english,
        to: Language.arabic,
        tone: TranslationTone.formal,
      );

      expect(local.translateCalled, isTrue);
    });

    test('falls back to local when the remote call fails', () async {
      final local = _FakeLocalDataSource();
      final remote = _FakeRemoteDataSource()
        ..throwOnTranslate = const RemoteApiException('quota exceeded');
      final repo = TranslationRepositoryImpl(
        local: local,
        connectivity: _FakeConnectivity(true),
        remote: remote,
      );

      final result = await repo.translate(
        text: 'hi',
        from: Language.english,
        to: Language.arabic,
        tone: TranslationTone.formal,
      );

      expect(remote.translateCalled, isTrue);
      expect(local.translateCalled, isTrue);
      expect(result, isA<ApiSuccess<dynamic>>());
      final entity = (result as ApiSuccess).data;
      expect(entity.translatedText, 'local:hi');
      expect(entity.engine, TranslationEngine.offline);
    });

    test(
        'maps a RemoteConnectionException to NoConnectionFailure when local '
        'also fails', () async {
      final local = _FakeLocalDataSource()..throwOnTranslate = Exception('boom');
      final remote = _FakeRemoteDataSource()
        ..throwOnTranslate = const RemoteConnectionException('offline');
      final repo = TranslationRepositoryImpl(
        local: local,
        connectivity: _FakeConnectivity(true),
        remote: remote,
      );

      final result = await repo.translate(
        text: 'hi',
        from: Language.english,
        to: Language.arabic,
        tone: TranslationTone.formal,
      );

      expect(result, isA<ApiFailure<dynamic>>());
      expect((result as ApiFailure).failure, isA<NoConnectionFailure>());
    });

    test(
        'maps a RemoteApiException to TranslationFailure when local also '
        'fails', () async {
      final local = _FakeLocalDataSource()..throwOnTranslate = Exception('boom');
      final remote = _FakeRemoteDataSource()
        ..throwOnTranslate = const RemoteApiException('server error');
      final repo = TranslationRepositoryImpl(
        local: local,
        connectivity: _FakeConnectivity(true),
        remote: remote,
      );

      final result = await repo.translate(
        text: 'hi',
        from: Language.english,
        to: Language.arabic,
        tone: TranslationTone.formal,
      );

      expect(result, isA<ApiFailure<dynamic>>());
      expect((result as ApiFailure).failure, isA<TranslationFailure>());
    });
  });

  group('TranslationRepositoryImpl.areModelsDownloaded', () {
    test('returns the local flag on success', () async {
      final local = _FakeLocalDataSource()..modelsDownloaded = false;
      final repo = TranslationRepositoryImpl(
        local: local,
        connectivity: _FakeConnectivity(false),
      );

      final result = await repo.areModelsDownloaded(
        from: Language.english,
        to: Language.arabic,
      );

      expect((result as ApiSuccess).data, isFalse);
    });

    test('maps a thrown exception to UnknownFailure', () async {
      final local = _FakeLocalDataSource()..throwOnCheck = Exception('boom');
      final repo = TranslationRepositoryImpl(
        local: local,
        connectivity: _FakeConnectivity(false),
      );

      final result = await repo.areModelsDownloaded(
        from: Language.english,
        to: Language.arabic,
      );

      expect((result as ApiFailure).failure, isA<UnknownFailure>());
    });
  });

  group('TranslationRepositoryImpl.downloadModels', () {
    test('returns success when the local download completes', () async {
      final local = _FakeLocalDataSource();
      final repo = TranslationRepositoryImpl(
        local: local,
        connectivity: _FakeConnectivity(false),
      );

      final result = await repo.downloadModels(
        from: Language.english,
        to: Language.arabic,
      );

      expect(local.downloadCalled, isTrue);
      expect(result, isA<ApiSuccess<void>>());
    });

    test('maps a thrown exception to ModelDownloadFailure', () async {
      final local = _FakeLocalDataSource()..throwOnDownload = Exception('boom');
      final repo = TranslationRepositoryImpl(
        local: local,
        connectivity: _FakeConnectivity(false),
      );

      final result = await repo.downloadModels(
        from: Language.english,
        to: Language.arabic,
      );

      expect((result as ApiFailure).failure, isA<ModelDownloadFailure>());
    });
  });
}
