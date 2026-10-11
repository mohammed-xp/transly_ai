import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/data/datasources/user_local_data_source.dart';
import 'package:transly_ai/core/data/repos/user_repo_impl.dart';
import 'package:transly_ai/core/domain/entities/sign_in_method.dart';

class _FakeUserLocal implements UserLocalDataSource {
  _FakeUserLocal(this.signInMethod);

  final String? signInMethod;

  @override
  String? getCachedSignInMethod() => signInMethod;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

void main() {
  SignInMethod methodFor(String? stored) =>
      UserRepoImpl(_FakeUserLocal(stored)).getSignInMethod();

  test('reads a session started with Google', () {
    expect(methodFor('google'), SignInMethod.google);
  });

  test('reads a session started with email', () {
    expect(methodFor('email'), SignInMethod.email);
  });

  test('treats a session that stored no method as email', () {
    expect(methodFor(null), SignInMethod.email);
  });

  test('treats an unknown stored method as email', () {
    expect(methodFor('apple'), SignInMethod.email);
  });
}
