import '../../../../core/data/datasources/user_local_data_source.dart';
import '../../../../core/domain/entities/user_entity.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/result/api_result.dart';
import '../../domain/repos/auth_repo.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_login_model.dart';

class AuthRepoImpl implements AuthRepo {
  AuthRepoImpl({
    required AuthRemoteDataSource remote,
    required UserLocalDataSource userLocal,
  }) : _remote = remote,
       _userLocal = userLocal;

  final AuthRemoteDataSource _remote;
  final UserLocalDataSource _userLocal;

  @override
  Future<ApiResult<UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _remote.signInWithEmail(
        email: email,
        password: password,
      );
      await _persistSession(result);
      return ApiResult.success(result.userModel.toEntity());
    } catch (e) {
      return ApiResult.failure(ErrorMapper.map(e));
    }
  }

  Future<void> _persistSession(UserLoginModel login) async {
    await _userLocal.cacheUserData(login.userModel);
    await _userLocal.saveTokens(
      accessToken: login.userTokenModel.accessToken,
      refreshToken: login.userTokenModel.refreshToken,
    );
  }
}
