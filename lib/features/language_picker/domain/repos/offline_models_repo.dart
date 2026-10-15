import '../../../../core/result/api_result.dart';
import '../entities/offline_model_status.dart';
import '../entities/offline_packs_settings.dart';

abstract class OfflineModelsRepo {
  /// The status of each language in [codes], keyed by code.
  Future<ApiResult<Map<String, OfflineModelStatus>>> getStatuses(
    List<String> codes,
  );

  /// Every status change a download or a removal makes.
  Stream<OfflineModelUpdate> watchUpdates();

  Future<ApiResult<void>> download(String code);

  /// Downloads [code] in the background when the settings allow it and it
  /// isn't on the device yet. Skipping it counts as a success.
  Future<ApiResult<void>> autoDownload(String code);

  Future<ApiResult<void>> delete(String code);

  OfflinePacksSettings getSettings();

  Future<ApiResult<void>> saveSettings(OfflinePacksSettings settings);
}
