import '../../../../core/result/api_result.dart';
import '../repos/auth_repository.dart';

/// Whether a persisted session token exists right now, so the app can route
/// straight past sign-in on launch.
class HasActiveSessionUseCase {
  const HasActiveSessionUseCase(this._repository);

  final AuthRepository _repository;

  Future<ApiResult<bool>> call() => _repository.hasActiveSession();
}
