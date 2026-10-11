import 'dart:async';

import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/features/profile/domain/repos/account_repo.dart';

class FakeAccountRepo implements AccountRepo {
  FakeAccountRepo(
    this.result, {
    this.googleResult = const ApiResult.success(true),
  });

  ApiResult<void> result;
  final List<String> passwords = [];

  /// A success carrying `false` plays the user closing the account picker.
  ApiResult<bool> googleResult;
  int googleDeletions = 0;

  /// When set, both deletions wait for it before answering, so a test can
  /// observe the in-flight state.
  Completer<void>? gate;

  @override
  Future<ApiResult<void>> deleteAccount({required String password}) async {
    passwords.add(password);
    await gate?.future;
    return result;
  }

  @override
  Future<ApiResult<bool>> deleteAccountWithGoogle() async {
    googleDeletions++;
    await gate?.future;
    return googleResult;
  }
}
