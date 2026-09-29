import '../../../../core/result/api_result.dart';
import '../entities/app_update_entity.dart';
import '../repos/app_update_repo.dart';

class CheckForAppUpdateUseCase {
  const CheckForAppUpdateUseCase(this._repo);

  final AppUpdateRepo _repo;

  Future<ApiResult<AppUpdateEntity?>> call() => _repo.checkForUpdate();
}
