import '../../result/api_result.dart';

abstract class LogoutRepo {
  Future<ApiResult<void>> logout();
}
