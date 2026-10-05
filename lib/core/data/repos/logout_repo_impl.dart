import '../../domain/repos/logout_repo.dart';
import '../../errors/error_mapper.dart';
import '../../result/api_result.dart';
import '../datasources/google_auth_data_source.dart';
import '../datasources/user_local_data_source.dart';

class LogoutRepoImpl implements LogoutRepo {
  LogoutRepoImpl(this._userLocal, this._google);

  final UserLocalDataSource _userLocal;
  final GoogleAuthDataSource _google;

  @override
  Future<ApiResult<void>> logout() async {
    try {
      await _userLocal.clearCachedUserData();
      await _userLocal.clearTokens();
      await _google.signOut();
      return const ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ErrorMapper.map(e));
    }
  }
}
