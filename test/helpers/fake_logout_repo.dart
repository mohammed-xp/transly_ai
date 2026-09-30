import 'package:transly_ai/core/domain/repos/logout_repo.dart';
import 'package:transly_ai/core/result/api_result.dart';

class FakeLogoutRepo implements LogoutRepo {
  int calls = 0;

  @override
  Future<ApiResult<void>> logout() async {
    calls++;
    return const ApiResult.success(null);
  }
}
