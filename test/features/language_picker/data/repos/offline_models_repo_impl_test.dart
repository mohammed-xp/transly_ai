import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/data/datasources/offline_models_data_source.dart';
import 'package:transly_ai/core/errors/app_exceptions.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/core/services/connectivity_service.dart';
import 'package:transly_ai/features/language_picker/data/datasources/offline_packs_settings_local_data_source.dart';
import 'package:transly_ai/features/language_picker/data/repos/offline_models_repo_impl.dart';
import 'package:transly_ai/features/language_picker/domain/entities/offline_model_status.dart';
import 'package:transly_ai/features/language_picker/domain/entities/offline_packs_settings.dart';

class _FakeModels implements OfflineModelsDataSource {
  final Set<String> supported = {'en', 'ar', 'fr', 'de'};
  final Set<String> downloaded = {};
  int checks = 0;
  int downloadCalls = 0;
  Object? checkError;
  Object? downloadError;
  Object? deleteError;
  Completer<void>? downloadGate;
  bool? lastWifiRequired;

  @override
  bool isSupported(String code) => supported.contains(code);

  @override
  bool isBuiltIn(String code) => code == 'en';

  @override
  Future<bool> isDownloaded(String code) async {
    checks++;
    final error = checkError;
    if (error != null) throw error;
    return downloaded.contains(code);
  }

  @override
  Future<void> download(String code, {bool wifiRequired = false}) async {
    downloadCalls++;
    lastWifiRequired = wifiRequired;
    await downloadGate?.future;
    final error = downloadError;
    if (error != null) throw error;
    downloaded.add(code);
  }

  @override
  Future<void> delete(String code) async {
    final error = deleteError;
    if (error != null) throw error;
    downloaded.remove(code);
  }
}

class _FakeConnectivity implements ConnectivityService {
  bool connected = true;
  bool onWifi = true;

  @override
  Future<bool> get isConnected async => connected;

  @override
  Stream<bool> get onConnectedChanged => const Stream.empty();

  @override
  Future<bool> get isOnWifi async => onWifi;
}

class _FakeSettings implements OfflinePacksSettingsLocalDataSource {
  bool? autoDownload;
  bool? wifiOnly;
  Set<String> autoDownloaded = {};
  Object? readError;
  Object? saveError;

  @override
  bool? getAutoDownload() => _read(autoDownload);

  @override
  Future<void> saveAutoDownload(bool value) async {
    _checkSave();
    autoDownload = value;
  }

  @override
  bool? getWifiOnly() => _read(wifiOnly);

  @override
  Future<void> saveWifiOnly(bool value) async {
    _checkSave();
    wifiOnly = value;
  }

  @override
  Set<String> getAutoDownloadedCodes() => {..._read(autoDownloaded)};

  @override
  Future<void> saveAutoDownloadedCodes(Set<String> codes) async {
    _checkSave();
    autoDownloaded = {...codes};
  }

  T _read<T>(T value) {
    final error = readError;
    if (error != null) throw error;
    return value;
  }

  void _checkSave() {
    final error = saveError;
    if (error != null) throw error;
  }
}

void main() {
  late _FakeModels models;
  late _FakeConnectivity connectivity;
  late _FakeSettings settings;
  late OfflineModelsRepoImpl repo;

  setUp(() {
    models = _FakeModels();
    connectivity = _FakeConnectivity();
    settings = _FakeSettings();
    repo = OfflineModelsRepoImpl(
      models: models,
      connectivity: connectivity,
      settings: settings,
    );
  });

  Future<Map<String, OfflineModelStatus>> statusesOf(List<String> codes) async {
    final result = await repo.getStatuses(codes);
    return (result as ApiSuccess<Map<String, OfflineModelStatus>>).data;
  }

  Future<List<OfflineModelStatus>> statusesReportedDuring(
    Future<void> Function() action,
  ) async {
    final reported = <OfflineModelStatus>[];
    final subscription = repo.watchUpdates().listen(
      (update) => reported.add(update.status),
    );
    await action();
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();
    return reported;
  }

  Failure failureOf(ApiResult<void> result) =>
      (result as ApiFailure<void>).failure;

  group('getStatuses', () {
    test('marks a language ML Kit has no model for as unsupported', () async {
      final statuses = await statusesOf(['xx']);

      expect(statuses['xx'], isA<OfflineModelUnsupported>());
    });

    test('marks English as built in', () async {
      final statuses = await statusesOf(['en']);

      expect(statuses['en'], isA<OfflineModelBuiltIn>());
    });

    test('marks a model on the device as downloaded', () async {
      models.downloaded.add('fr');

      final statuses = await statusesOf(['fr']);

      expect(statuses['fr'], isA<OfflineModelDownloaded>());
    });

    test('marks a model not on the device as not downloaded', () async {
      final statuses = await statusesOf(['de']);

      expect(statuses['de'], isA<OfflineModelNotDownloaded>());
    });

    test('asks the device about each language only once', () async {
      await repo.getStatuses(['fr', 'de']);

      await repo.getStatuses(['fr', 'de']);

      expect(models.checks, 2);
    });

    test('fails when the device can not be asked', () async {
      models.checkError = Exception('channel');

      final result = await repo.getStatuses(['fr']);

      expect(result, isA<ApiFailure<Map<String, OfflineModelStatus>>>());
    });
  });

  group('download', () {
    test('reports downloading, then downloaded', () async {
      final reported = await statusesReportedDuring(() => repo.download('fr'));

      expect(reported, [
        isA<OfflineModelDownloading>(),
        isA<OfflineModelDownloaded>(),
      ]);
    });

    test('is remembered for the next status request', () async {
      await repo.download('fr');

      final statuses = await statusesOf(['fr']);

      expect(statuses['fr'], isA<OfflineModelDownloaded>());
    });

    test('fails with a network failure when offline', () async {
      connectivity.connected = false;

      final result = await repo.download('fr');

      expect(failureOf(result), isA<NetworkFailure>());
    });

    test('does not start a download when offline', () async {
      connectivity.connected = false;

      await repo.download('fr');

      expect(models.downloadCalls, 0);
    });

    test('a failed download goes back to not downloaded', () async {
      models.downloadError = Exception('channel');

      final reported = await statusesReportedDuring(() => repo.download('fr'));

      expect(reported.last, isA<OfflineModelNotDownloaded>());
    });

    test('a failed download fails with a model download failure', () async {
      models.downloadError = Exception('channel');

      final result = await repo.download('fr');

      expect(failureOf(result), isA<ModelDownloadFailure>());
    });

    test('an unsupported language fails as unsupported', () async {
      models.downloadError = const UnsupportedLanguageException();

      final result = await repo.download('fr');

      expect(failureOf(result), isA<UnsupportedLanguageFailure>());
    });

    test('a second request while downloading joins the first', () async {
      final gate = Completer<void>();
      models.downloadGate = gate;

      final first = repo.download('fr');
      final second = repo.download('fr');
      gate.complete();
      await Future.wait([first, second]);

      expect(models.downloadCalls, 1);
    });

    test('an offline request reports no status change', () async {
      connectivity.connected = false;

      final reported = await statusesReportedDuring(() => repo.download('fr'));

      expect(reported, isEmpty);
    });

    test('is reported as downloading to a status request meanwhile', () async {
      final gate = Completer<void>();
      models.downloadGate = gate;

      final downloading = repo.download('fr');
      await Future<void>.delayed(Duration.zero);
      final statuses = await statusesOf(['fr']);
      gate.complete();
      await downloading;

      expect(statuses['fr'], isA<OfflineModelDownloading>());
    });

    test('a download that never ends fails once it times out', () async {
      final timingOut = OfflineModelsRepoImpl(
        models: models..downloadGate = Completer<void>(),
        connectivity: connectivity,
        settings: settings,
        downloadTimeout: Duration.zero,
      );

      final result = await timingOut.download('fr');

      expect(failureOf(result), isA<ModelDownloadFailure>());
    });

    test('a timed-out download goes back to not downloaded', () async {
      final timingOut = OfflineModelsRepoImpl(
        models: models..downloadGate = Completer<void>(),
        connectivity: connectivity,
        settings: settings,
        downloadTimeout: Duration.zero,
      );
      await timingOut.download('fr');

      final result = await timingOut.getStatuses(['fr']);

      expect(
        (result as ApiSuccess<Map<String, OfflineModelStatus>>).data['fr'],
        isA<OfflineModelNotDownloaded>(),
      );
    });

    test('a request after the download ended starts a new one', () async {
      models.downloadError = Exception('channel');
      await repo.download('fr');

      await repo.download('fr');

      expect(models.downloadCalls, 2);
    });
  });

  group('delete', () {
    test('reports the language as not downloaded', () async {
      models.downloaded.add('fr');

      final reported = await statusesReportedDuring(() => repo.delete('fr'));

      expect(reported.single, isA<OfflineModelNotDownloaded>());
    });

    test('is remembered for the next status request', () async {
      models.downloaded.add('fr');
      await repo.getStatuses(['fr']);
      await repo.delete('fr');

      final statuses = await statusesOf(['fr']);

      expect(statuses['fr'], isA<OfflineModelNotDownloaded>());
    });

    test('fails when the removal fails', () async {
      models.deleteError = const UnknownException();

      final result = await repo.delete('fr');

      expect(result, isA<ApiFailure<void>>());
    });

    test('a failed removal keeps the language downloaded', () async {
      models
        ..downloaded.add('fr')
        ..deleteError = const UnknownException();
      await repo.getStatuses(['fr']);

      final reported = await statusesReportedDuring(() => repo.delete('fr'));
      final statuses = await statusesOf(['fr']);

      expect(reported, isEmpty);
      expect(statuses['fr'], isA<OfflineModelDownloaded>());
    });
  });

  group('manual download', () {
    test('is not held back for Wi-Fi', () async {
      await repo.download('fr');

      expect(models.lastWifiRequired, isFalse);
    });

    test('is not marked as automatic', () async {
      final reported = await statusesReportedDuring(() => repo.download('fr'));

      expect(
        reported.last,
        isA<OfflineModelDownloaded>().having((s) => s.isAuto, 'isAuto', false),
      );
    });
  });

  group('autoDownload', () {
    test('downloads a language that is not on the device', () async {
      final result = await repo.autoDownload('fr');

      expect(result, isA<ApiSuccess<void>>());
      expect(models.downloaded, contains('fr'));
    });

    test('reports the download as automatic', () async {
      final reported = await statusesReportedDuring(
        () => repo.autoDownload('fr'),
      );

      expect(reported, [
        isA<OfflineModelDownloading>().having((s) => s.isAuto, 'isAuto', true),
        isA<OfflineModelDownloaded>().having((s) => s.isAuto, 'isAuto', true),
      ]);
    });

    test('remembers the language as auto-downloaded', () async {
      await repo.autoDownload('fr');

      expect(settings.autoDownloaded, {'fr'});
    });

    test('marks a saved auto-download in a later session', () async {
      models.downloaded.add('fr');
      settings.autoDownloaded = {'fr'};

      final statuses = await statusesOf(['fr']);

      expect(
        statuses['fr'],
        isA<OfflineModelDownloaded>().having((s) => s.isAuto, 'isAuto', true),
      );
    });

    test('does nothing when auto-download is turned off', () async {
      settings.autoDownload = false;

      final result = await repo.autoDownload('fr');

      expect(result, isA<ApiSuccess<void>>());
      expect(models.downloadCalls, 0);
    });

    test('skips a language already on the device', () async {
      models.downloaded.add('fr');

      await repo.autoDownload('fr');

      expect(models.downloadCalls, 0);
    });

    test('skips the built-in and unsupported languages', () async {
      await repo.autoDownload('en');
      await repo.autoDownload('xx');

      expect(models.downloadCalls, 0);
    });

    test('waits for Wi-Fi when only Wi-Fi is allowed', () async {
      connectivity.onWifi = false;

      final reported = await statusesReportedDuring(
        () => repo.autoDownload('fr'),
      );

      expect(models.downloadCalls, 0);
      expect(reported, isEmpty);
    });

    test('asks the engine to stay on Wi-Fi when only Wi-Fi is allowed', () async {
      await repo.autoDownload('fr');

      expect(models.lastWifiRequired, isTrue);
    });

    test('uses mobile data when Wi-Fi only is turned off', () async {
      settings.wifiOnly = false;
      connectivity.onWifi = false;

      await repo.autoDownload('fr');

      expect(models.downloadCalls, 1);
      expect(models.lastWifiRequired, isFalse);
    });

    test('joins a download that is already running', () async {
      final gate = Completer<void>();
      models.downloadGate = gate;

      final manual = repo.download('fr');
      final auto = repo.autoDownload('fr');
      gate.complete();
      await Future.wait([manual, auto]);

      expect(models.downloadCalls, 1);
    });

    test(
      'still succeeds when the auto-download mark cannot be saved',
      () async {
        settings.saveError = Exception('box');

        final result = await repo.autoDownload('fr');

        expect(result, isA<ApiSuccess<void>>());
      },
    );

    test('fails quietly when the device cannot be asked', () async {
      models.checkError = Exception('channel');

      final result = await repo.autoDownload('fr');

      expect(result, isA<ApiFailure<void>>());
      expect(models.downloadCalls, 0);
    });
  });

  group('delete of an auto-downloaded language', () {
    test('forgets that it was auto-downloaded', () async {
      models.downloaded.add('fr');
      settings.autoDownloaded = {'fr'};

      await repo.delete('fr');

      expect(settings.autoDownloaded, isEmpty);
    });
  });

  group('settings', () {
    test('default to auto-download over Wi-Fi only', () {
      expect(repo.getSettings(), defaultOfflinePacksSettings);
      expect(defaultOfflinePacksSettings, (autoDownload: true, wifiOnly: true));
    });

    test('reads the saved choices', () {
      settings
        ..autoDownload = false
        ..wifiOnly = false;

      expect(repo.getSettings(), (autoDownload: false, wifiOnly: false));
    });

    test('fall back to the defaults when they cannot be read', () {
      settings.readError = Exception('box');

      expect(repo.getSettings(), defaultOfflinePacksSettings);
    });

    test('saves both choices', () async {
      final result = await repo.saveSettings((
        autoDownload: false,
        wifiOnly: false,
      ));

      expect(result, isA<ApiSuccess<void>>());
      expect(settings.autoDownload, isFalse);
      expect(settings.wifiOnly, isFalse);
    });

    test('fail to save when the box cannot be written', () async {
      settings.saveError = Exception('box');

      final result = await repo.saveSettings((
        autoDownload: false,
        wifiOnly: true,
      ));

      expect(result, isA<ApiFailure<void>>());
    });
  });
}
