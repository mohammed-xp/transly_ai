import 'package:transly_ai/core/domain/entities/sign_in_method.dart';
import 'package:transly_ai/core/domain/entities/user_entity.dart';
import 'package:transly_ai/core/domain/repos/user_repo.dart';

class FakeUserRepo implements UserRepo {
  FakeUserRepo([this.cachedUser, this.signInMethod = SignInMethod.email]);

  final UserEntity? cachedUser;
  final SignInMethod signInMethod;

  @override
  UserEntity? getCachedUser() => cachedUser;

  @override
  SignInMethod getSignInMethod() => signInMethod;
}

final testUser = UserEntity(
  id: 'user-1',
  email: 'ahmed.hassan@gmail.com',
  username: 'Ahmed Hassan',
  createdAt: DateTime.utc(2026, 1, 1),
);
