import '../../domain/repos/logout_repo.dart';
import '../../errors/error_mapper.dart';
import '../../result/api_result.dart';
import '../datasources/google_auth_data_source.dart';
import '../datasources/user_local_data_source.dart';

class LogoutRepoImpl implements LogoutRepo {
  LogoutRepoImpl(this._userLocal, this._google);

  final UserLocalDataSource _userLocal;
  final GoogleAuthDataSource _google;

  /// Every step runs even when an earlier one fails: a leftover cached user
  /// signs the user back in on the next launch, and a leftover refresh token
  /// outlives the session. The first error is the one reported.
  @override
  Future<ApiResult<void>> logout() async {
    Object? error;
    for (final step in [
      _userLocal.clearTokens,
      _userLocal.clearCachedUserData,
      _google.signOut,
    ]) {
      try {
        await step();
      } catch (e) {
        error ??= e;
      }
    }
    return error == null
        ? const ApiResult.success(null)
        : ApiResult.failure(ErrorMapper.map(error));
  }
}
