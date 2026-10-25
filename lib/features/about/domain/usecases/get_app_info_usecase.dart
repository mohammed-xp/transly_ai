import '../../../../core/result/api_result.dart';
import '../entities/app_info_entity.dart';
import '../repos/app_info_repo.dart';

class GetAppInfoUseCase {
  const GetAppInfoUseCase(this._repo);

  final AppInfoRepo _repo;

  Future<ApiResult<AppInfoEntity>> call() => _repo.getAppInfo();
}
