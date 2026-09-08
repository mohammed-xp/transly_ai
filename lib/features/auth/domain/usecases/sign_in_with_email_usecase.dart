import 'package:transly_ai/features/auth/domain/entities/user_entity.dart';

import '../../../../core/result/api_result.dart';
import '../repos/auth_repository.dart';

/// Signs in with [email] and [password].
class SignInWithEmailUseCase {
  const SignInWithEmailUseCase(this._repository);

  final AuthRepository _repository;

  Future<ApiResult<UserEntity>> call({
    required String email,
    required String password,
  }) {
    return _repository.signInWithEmail(email: email, password: password);
  }
}
