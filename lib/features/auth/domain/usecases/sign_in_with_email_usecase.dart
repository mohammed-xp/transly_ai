import '../../../../core/domain/entities/user_entity.dart';
import '../../../../core/result/api_result.dart';
import '../../../../core/session/session_manager.dart';
import '../repos/auth_repo.dart';

/// Signs in with [email] and [password] and, on success, starts a new session.
class SignInWithEmailUseCase {
  const SignInWithEmailUseCase(this._repository, this._session);

  final AuthRepo _repository;
  final SessionManager _session;

  Future<ApiResult<UserEntity>> call({
    required String email,
    required String password,
  }) async {
    final result = await _repository.signInWithEmail(
      email: email,
      password: password,
    );
    if (result is ApiSuccess<UserEntity>) _session.markAuthenticated();
    return result;
  }
}
