import 'dart:async';

import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/features/language_picker/domain/entities/offline_model_status.dart';
import 'package:transly_ai/features/language_picker/domain/entities/offline_packs_settings.dart';
import 'package:transly_ai/features/language_picker/domain/repos/offline_models_repo.dart';

class FakeOfflineModelsRepo implements OfflineModelsRepo {
  FakeOfflineModelsRepo({
    this.statuses = const {},
    this.statusesResult,
    this.downloadResult = const ApiResult.success(null),
    this.deleteResult = const ApiResult.success(null),
    this.settings = defaultOfflinePacksSettings,
    this.saveSettingsResult = const ApiResult.success(null),
  });

  /// Answered for every code asked about; unknown codes are unsupported.
  Map<String, OfflineModelStatus> statuses;

  /// Replaces the answer built from [statuses] when set.
  ApiResult<Map<String, OfflineModelStatus>>? statusesResult;

  ApiResult<void> downloadResult;
  ApiResult<void> deleteResult;
  final List<String> downloads = [];
  final List<String> deletes = [];
  final List<String> autoDownloads = [];

  OfflinePacksSettings settings;
  ApiResult<void> saveSettingsResult;
  final List<OfflinePacksSettings> savedSettings = [];
  final StreamController<OfflineModelUpdate> updates =
      StreamController.broadcast();

  /// Holds back the answer of [getStatuses] / [download] until completed.
  Completer<void>? statusesGate;
  Completer<void>? downloadGate;

  @override
  Future<ApiResult<Map<String, OfflineModelStatus>>> getStatuses(
    List<String> codes,
  ) async {
    await statusesGate?.future;
    return statusesResult ??
        ApiResult.success({
          for (final code in codes)
            code: statuses[code] ?? const OfflineModelUnsupported(),
        });
  }

  @override
  Stream<OfflineModelUpdate> watchUpdates() => updates.stream;

  @override
  Future<ApiResult<void>> download(String code) async {
    downloads.add(code);
    await downloadGate?.future;
    return downloadResult;
  }

  @override
  Future<ApiResult<void>> delete(String code) async {
    deletes.add(code);
    return deleteResult;
  }

  @override
  Future<ApiResult<void>> autoDownload(String code) async {
    autoDownloads.add(code);
    return const ApiResult.success(null);
  }

  @override
  OfflinePacksSettings getSettings() => settings;

  @override
  Future<ApiResult<void>> saveSettings(OfflinePacksSettings settings) async {
    savedSettings.add(settings);
    if (saveSettingsResult is ApiSuccess<void>) this.settings = settings;
    return saveSettingsResult;
  }
}
