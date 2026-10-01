import '../../../../core/result/api_result.dart';
import '../repos/auth_repo.dart';

/// Creates an account. Registration returns no tokens, so the user still has
/// to sign in afterwards.
class SignUpWithEmailUseCase {
  const SignUpWithEmailUseCase(this._repository);

  final AuthRepo _repository;

  Future<ApiResult<void>> call({
    required String name,
    required String email,
    required String password,
  }) {
    return _repository.signUpWithEmail(
      name: name,
      email: email,
      password: password,
    );
  }
}
