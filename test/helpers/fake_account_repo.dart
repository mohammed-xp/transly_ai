import 'dart:async';

import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/features/profile/domain/repos/account_repo.dart';

class FakeAccountRepo implements AccountRepo {
  FakeAccountRepo(this.result);

  ApiResult<void> result;
  final List<String> passwords = [];

  /// When set, [deleteAccount] waits for it before answering, so a test can
  /// observe the in-flight state.
  Completer<void>? gate;

  @override
  Future<ApiResult<void>> deleteAccount({required String password}) async {
    passwords.add(password);
    await gate?.future;
    return result;
  }
}
