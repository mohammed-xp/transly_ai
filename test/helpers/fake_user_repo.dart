import 'package:transly_ai/core/domain/entities/user_entity.dart';
import 'package:transly_ai/core/domain/repos/user_repo.dart';

class FakeUserRepo implements UserRepo {
  FakeUserRepo([this.cachedUser]);

  final UserEntity? cachedUser;

  @override
  UserEntity? getCachedUser() => cachedUser;
}

final testUser = UserEntity(
  id: 'user-1',
  email: 'ahmed.hassan@gmail.com',
  username: 'Ahmed Hassan',
  createdAt: DateTime.utc(2026, 1, 1),
);
