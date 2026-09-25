import '../../errors/failure.dart';
import '../../result/api_result.dart';
import '../entities/user_entity.dart';
import '../repos/user_repo.dart';

class GetCachedUserUseCase {
  const GetCachedUserUseCase(this._userRepo);

  final UserRepo _userRepo;

  ApiResult<UserEntity> call() {
    final user = _userRepo.getCachedUser();
    if (user == null) return const ApiResult.failure(UnauthorizedFailure());
    return ApiResult.success(user);
  }
}
