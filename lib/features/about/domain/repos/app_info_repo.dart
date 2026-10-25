import '../../../../core/result/api_result.dart';
import '../entities/app_info_entity.dart';

abstract class AppInfoRepo {
  Future<ApiResult<AppInfoEntity>> getAppInfo();
}
