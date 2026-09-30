import '../../../../core/errors/error_mapper.dart';
import '../../../../core/result/api_result.dart';
import '../../domain/repos/account_repo.dart';
import '../datasources/account_remote_data_source.dart';

class AccountRepoImpl implements AccountRepo {
  AccountRepoImpl(this._remote);

  final AccountRemoteDataSource _remote;

  @override
  Future<ApiResult<void>> deleteAccount({required String password}) async {
    try {
      await _remote.deleteAccount(password: password);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(ErrorMapper.map(e));
    }
  }
}
