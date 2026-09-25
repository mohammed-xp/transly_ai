import '../../../../core/domain/entities/user_entity.dart';
import '../../../../core/result/api_result.dart';

abstract class AuthRepo {
  Future<ApiResult<UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });
}
