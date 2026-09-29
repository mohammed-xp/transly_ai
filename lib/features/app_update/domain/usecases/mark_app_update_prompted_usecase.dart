import '../../../../core/result/api_result.dart';
import '../repos/app_update_repo.dart';

class MarkAppUpdatePromptedUseCase {
  const MarkAppUpdatePromptedUseCase(this._repo);

  final AppUpdateRepo _repo;

  Future<ApiResult<void>> call() => _repo.markPrompted();
}
