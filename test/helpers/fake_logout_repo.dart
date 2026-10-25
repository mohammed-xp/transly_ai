import 'dart:async';

import 'package:transly_ai/core/domain/repos/logout_repo.dart';
import 'package:transly_ai/core/result/api_result.dart';

class FakeLogoutRepo implements LogoutRepo {
  FakeLogoutRepo({this.result = const ApiResult.success(null), this.gate});

  ApiResult<void> result;

  /// When set, [logout] waits for it before answering, so a test can act
  /// while a logout is still in flight.
  Completer<void>? gate;

  int calls = 0;

  @override
  Future<ApiResult<void>> logout() async {
    calls++;
    await gate?.future;
    return result;
  }
}
