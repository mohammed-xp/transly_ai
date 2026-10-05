import '../../../../core/domain/entities/user_entity.dart';
import '../../../../core/result/api_result.dart';

abstract class AuthRepo {
  Future<ApiResult<UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Succeeds with `null` when the user closed the Google account picker:
  /// nothing went wrong, and nobody is signed in.
  Future<ApiResult<UserEntity?>> signInWithGoogle();

  Future<ApiResult<void>> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  });
}
