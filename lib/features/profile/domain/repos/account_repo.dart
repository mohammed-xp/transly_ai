import '../../../../core/result/api_result.dart';

abstract class AccountRepo {
  Future<ApiResult<void>> deleteAccount({required String password});
}
