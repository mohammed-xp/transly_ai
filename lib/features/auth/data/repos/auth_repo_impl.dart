import '../../../../core/data/datasources/google_auth_data_source.dart';
import '../../../../core/data/datasources/user_local_data_source.dart';
import '../../../../core/domain/entities/sign_in_method.dart';
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
    required GoogleAuthDataSource google,
  }) : _remote = remote,
       _userLocal = userLocal,
       _google = google;

  final AuthRemoteDataSource _remote;
  final UserLocalDataSource _userLocal;
  final GoogleAuthDataSource _google;

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
      await _persistSession(result, SignInMethod.email);
      return ApiResult.success(result.userModel.toEntity());
    } catch (e) {
      return ApiResult.failure(ErrorMapper.map(e));
    }
  }

  @override
  Future<ApiResult<UserEntity?>> signInWithGoogle() async {
    try {
      final idToken = await _google.getIdToken();
      if (idToken == null) return const ApiResult.success(null);

      final result = await _remote.signInWithGoogle(idToken: idToken);
      await _persistSession(result, SignInMethod.google);
      return ApiResult.success(result.userModel.toEntity());
    } catch (e) {
      return ApiResult.failure(ErrorMapper.map(e));
    }
  }

  @override
  Future<ApiResult<void>> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      await _remote.signUpWithEmail(
        name: name,
        email: email,
        password: password,
      );
      return const ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ErrorMapper.map(e));
    }
  }

  Future<void> _persistSession(
    UserLoginModel login,
    SignInMethod method,
  ) async {
    await _userLocal.cacheUserData(login.userModel);
    await _userLocal.cacheSignInMethod(method.name);
    await _userLocal.saveTokens(
      accessToken: login.userTokenModel.accessToken,
      refreshToken: login.userTokenModel.refreshToken,
    );
  }
}
