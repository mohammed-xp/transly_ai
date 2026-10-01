import 'dart:async';

import 'package:transly_ai/core/domain/entities/user_entity.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/features/auth/domain/repos/auth_repo.dart';

class FakeAuthRepo implements AuthRepo {
  FakeAuthRepo(this.signUpResult);

  ApiResult<void> signUpResult;
  final List<({String name, String email, String password})> signUps = [];

  /// When set, [signUpWithEmail] waits for it before answering, so a test can
  /// observe the in-flight state.
  Completer<void>? gate;

  @override
  Future<ApiResult<void>> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    signUps.add((name: name, email: email, password: password));
    await gate?.future;
    return signUpResult;
  }

  @override
  Future<ApiResult<UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) => throw UnimplementedError();
}
