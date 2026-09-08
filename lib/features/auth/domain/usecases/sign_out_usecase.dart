import '../../../../core/result/api_result.dart';
import '../repos/auth_repository.dart';

/// Clears the persisted session token — an ordinary, user-initiated
/// sign-out (as opposed to the backend rejecting the token).
class SignOutUseCase {
  const SignOutUseCase(this._repository);

  final AuthRepository _repository;

  Future<ApiResult<void>> call() => _repository.signOut();
}
