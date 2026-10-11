import '../../../../core/data/datasources/google_auth_data_source.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/result/api_result.dart';
import '../../domain/repos/account_repo.dart';
import '../datasources/account_remote_data_source.dart';

class AccountRepoImpl implements AccountRepo {
  AccountRepoImpl(this._remote, this._google);

  final AccountRemoteDataSource _remote;
  final GoogleAuthDataSource _google;

  @override
  Future<ApiResult<void>> deleteAccount({required String password}) async {
    try {
      await _remote.deleteAccount(password: password);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ErrorMapper.map(e));
    }
  }

  @override
  Future<ApiResult<bool>> deleteAccountWithGoogle() async {
    try {
      final idToken = await _google.getIdToken();
      if (idToken == null) return const ApiResult.success(false);

      await _remote.deleteAccountWithGoogle(idToken: idToken);
      return const ApiResult.success(true);
    } catch (e) {
      return ApiResult.failure(ErrorMapper.map(e));
    }
  }
}
