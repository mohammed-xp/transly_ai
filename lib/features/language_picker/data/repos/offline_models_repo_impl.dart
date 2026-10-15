import 'dart:async';

import '../../../../core/data/datasources/offline_models_data_source.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/result/api_result.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../domain/entities/offline_model_status.dart';
import '../../domain/entities/offline_packs_settings.dart';
import '../../domain/repos/offline_models_repo.dart';
import '../datasources/offline_packs_settings_local_data_source.dart';

/// Keeps the statuses for the whole app session (registered as a singleton):
/// the picker sheet is closed and reopened while a download runs, and asking
/// the device about every language on each opening would be slow.
class OfflineModelsRepoImpl implements OfflineModelsRepo {
  OfflineModelsRepoImpl({
    required OfflineModelsDataSource models,
    required ConnectivityService connectivity,
    required OfflinePacksSettingsLocalDataSource settings,
    this.downloadTimeout = const Duration(minutes: 5),
  }) : _models = models,
       _connectivity = connectivity,
       _settings = settings;

  final OfflineModelsDataSource _models;
  final ConnectivityService _connectivity;
  final OfflinePacksSettingsLocalDataSource _settings;

  /// ML Kit keeps waiting when the connection drops mid-download (or sits
  /// behind a captive portal); past this the download counts as failed so
  /// the user can try again.
  final Duration downloadTimeout;

  final Map<String, OfflineModelStatus> _known = {};
  final Map<String, Future<ApiResult<void>>> _inFlight = {};
  final StreamController<OfflineModelUpdate> _updates =
      StreamController.broadcast();

  late final Set<String> _autoDownloaded = _readAutoDownloaded();

  @override
  Future<ApiResult<Map<String, OfflineModelStatus>>> getStatuses(
    List<String> codes,
  ) async {
    try {
      await Future.wait([
        for (final code in codes.toSet())
          if (!_known.containsKey(code)) _check(code),
      ]);
      return ApiResult.success({for (final code in codes) code: _known[code]!});
    } catch (e) {
      return ApiResult.failure(ErrorMapper.map(e));
    }
  }

  @override
  Stream<OfflineModelUpdate> watchUpdates() => _updates.stream;

  /// A second call while the language is still downloading joins the first.
  @override
  Future<ApiResult<void>> download(String code) =>
      _join(code, () => _download(code, isAuto: false, wifiRequired: false));

  /// Never started off Wi-Fi when the settings ask for it: ML Kit would
  /// otherwise sit waiting for one until the timeout.
  @override
  Future<ApiResult<void>> autoDownload(String code) async {
    try {
      final settings = getSettings();
      if (!settings.autoDownload || _inFlight.containsKey(code)) {
        return const ApiResult.success(null);
      }
      if (!_known.containsKey(code)) await _check(code);
      if (_known[code] is! OfflineModelNotDownloaded) {
        return const ApiResult.success(null);
      }
      if (settings.wifiOnly && !await _connectivity.isOnWifi) {
        return const ApiResult.success(null);
      }
      return await _join(
        code,
        () => _download(code, isAuto: true, wifiRequired: settings.wifiOnly),
      );
    } catch (e) {
      return ApiResult.failure(ErrorMapper.map(e));
    }
  }

  @override
  Future<ApiResult<void>> delete(String code) async {
    try {
      await _models.delete(code);
      _set(code, const OfflineModelNotDownloaded());
      await _rememberAutoDownloaded(code, false);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ErrorMapper.map(e));
    }
  }

  /// Nothing saved, or a box that can't be read, gives the defaults.
  @override
  OfflinePacksSettings getSettings() {
    try {
      return (
        autoDownload:
            _settings.getAutoDownload() ??
            defaultOfflinePacksSettings.autoDownload,
        wifiOnly:
            _settings.getWifiOnly() ?? defaultOfflinePacksSettings.wifiOnly,
      );
    } catch (_) {
      return defaultOfflinePacksSettings;
    }
  }

  @override
  Future<ApiResult<void>> saveSettings(OfflinePacksSettings settings) async {
    try {
      await _settings.saveAutoDownload(settings.autoDownload);
      await _settings.saveWifiOnly(settings.wifiOnly);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ErrorMapper.map(e));
    }
  }

  Future<ApiResult<void>> _join(
    String code,
    Future<ApiResult<void>> Function() start,
  ) => _inFlight[code] ??= start().whenComplete(() {
    // A block body: returning the removed future would make this one wait
    // for itself.
    _inFlight.remove(code);
  });

  /// Leaves a status set meanwhile (a download started) in place.
  Future<void> _check(String code) async {
    final status = await _deviceStatus(code);
    _known.putIfAbsent(code, () => status);
  }

  Future<OfflineModelStatus> _deviceStatus(String code) async {
    if (!_models.isSupported(code)) return const OfflineModelUnsupported();
    if (_models.isBuiltIn(code)) return const OfflineModelBuiltIn();
    return await _models.isDownloaded(code)
        ? OfflineModelDownloaded(isAuto: _autoDownloaded.contains(code))
        : const OfflineModelNotDownloaded();
  }

  /// Without a connection ML Kit would wait for one with no end in sight, so
  /// the user is told straight away instead.
  Future<ApiResult<void>> _download(
    String code, {
    required bool isAuto,
    required bool wifiRequired,
  }) async {
    try {
      if (!await _connectivity.isConnected) {
        return const ApiResult.failure(NetworkFailure());
      }
      _set(code, OfflineModelDownloading(isAuto: isAuto));
      await _models
          .download(code, wifiRequired: wifiRequired)
          .timeout(downloadTimeout);
      _set(code, OfflineModelDownloaded(isAuto: isAuto));
      await _rememberAutoDownloaded(code, isAuto);
      return const ApiResult.success(null);
    } catch (e) {
      if (_known[code] is OfflineModelDownloading) {
        _set(code, const OfflineModelNotDownloaded());
      }
      final failure = ErrorMapper.map(e);
      return ApiResult.failure(
        failure is UnsupportedLanguageFailure
            ? failure
            : const ModelDownloadFailure(),
      );
    }
  }

  void _set(String code, OfflineModelStatus status) {
    _known[code] = status;
    _updates.add((code: code, status: status));
  }

  /// Only marks the pack in the list; failing to save it must not fail the
  /// download or removal itself.
  Future<void> _rememberAutoDownloaded(String code, bool isAuto) async {
    final changed = isAuto
        ? _autoDownloaded.add(code)
        : _autoDownloaded.remove(code);
    if (!changed) return;
    try {
      await _settings.saveAutoDownloadedCodes(_autoDownloaded);
    } catch (_) {}
  }

  Set<String> _readAutoDownloaded() {
    try {
      return _settings.getAutoDownloadedCodes();
    } catch (_) {
      return {};
    }
  }
}
