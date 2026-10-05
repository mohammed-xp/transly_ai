import '../../../../core/domain/entities/user_entity.dart';
import '../../../../core/result/api_result.dart';
import '../../../../core/session/session_manager.dart';
import '../repos/auth_repo.dart';

/// Signs in with a Google account and, on success, starts a new session.
/// A success carrying `null` means the user closed the account picker.
class SignInWithGoogleUseCase {
  const SignInWithGoogleUseCase(this._repository, this._session);

  final AuthRepo _repository;
  final SessionManager _session;

  Future<ApiResult<UserEntity?>> call() async {
    final result = await _repository.signInWithGoogle();
    if (result is ApiSuccess<UserEntity?> && result.data != null) {
      _session.markAuthenticated();
    }
    return result;
  }
}
