import '../../../../core/result/api_result.dart';
import '../entities/app_update_entity.dart';

abstract class AppUpdateRepo {
  /// Succeeds with null when there is nothing to prompt for.
  Future<ApiResult<AppUpdateEntity?>> checkForUpdate();

  /// Records that the optional prompt was shown, so it is not repeated too
  /// soon.
  Future<ApiResult<void>> markPrompted();

  Future<ApiResult<void>> openStore();
}
