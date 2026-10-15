import 'dart:async';

import '../../../../core/data/datasources/offline_models_data_source.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/result/api_result.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../domain/entities/offline_model_status.dart';
import '../../domain/repos/offline_models_repo.dart';

/// Keeps the statuses for the whole app session (registered as a singleton):
/// the picker sheet is closed and reopened while a download runs, and asking
/// the device about every language on each opening would be slow.
class OfflineModelsRepoImpl implements OfflineModelsRepo {
  OfflineModelsRepoImpl({
    required OfflineModelsDataSource models,
    required ConnectivityService connectivity,
    this.downloadTimeout = const Duration(minutes: 5),
  }) : _models = models,
       _connectivity = connectivity;

  final OfflineModelsDataSource _models;
  final ConnectivityService _connectivity;

  /// ML Kit keeps waiting when the connection drops mid-download (or sits
  /// behind a captive portal); past this the download counts as failed so
  /// the user can try again.
  final Duration downloadTimeout;

  final Map<String, OfflineModelStatus> _known = {};
  final Map<String, Future<ApiResult<void>>> _inFlight = {};
  final StreamController<OfflineModelUpdate> _updates =
      StreamController.broadcast();

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
      _inFlight[code] ??= _download(code).whenComplete(() {
        // A block body: returning the removed future would make this one
        // wait for itself.
        _inFlight.remove(code);
      });

  @override
  Future<ApiResult<void>> delete(String code) async {
    try {
      await _models.delete(code);
      _set(code, const OfflineModelNotDownloaded());
      return const ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ErrorMapper.map(e));
    }
  }

  /// Leaves a status set meanwhile (a download started) in place.
  Future<void> _check(String code) async {
    final status = await _deviceStatus(code);
    _known.putIfAbsent(code, () => status);
  }

  Future<OfflineModelStatus> _deviceStatus(String code) async {
    if (!_models.isSupported(code)) return const OfflineModelUnsupported();
    if (_models.isBuiltIn(code)) return const OfflineModelBuiltIn();
    return await _models.isDownloaded(code)
        ? const OfflineModelDownloaded()
        : const OfflineModelNotDownloaded();
  }

  /// Without a connection ML Kit would wait for one with no end in sight, so
  /// the user is told straight away instead.
  Future<ApiResult<void>> _download(String code) async {
    try {
      if (!await _connectivity.isConnected) {
        return const ApiResult.failure(NetworkFailure());
      }
      _set(code, const OfflineModelDownloading());
      await _models.download(code).timeout(downloadTimeout);
      _set(code, const OfflineModelDownloaded());
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
}
