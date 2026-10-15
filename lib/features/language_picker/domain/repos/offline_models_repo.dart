import '../../../../core/result/api_result.dart';
import '../entities/offline_model_status.dart';

abstract class OfflineModelsRepo {
  /// The status of each language in [codes], keyed by code.
  Future<ApiResult<Map<String, OfflineModelStatus>>> getStatuses(
    List<String> codes,
  );

  /// Every status change a download or a removal makes.
  Stream<OfflineModelUpdate> watchUpdates();

  Future<ApiResult<void>> download(String code);

  Future<ApiResult<void>> delete(String code);
}
