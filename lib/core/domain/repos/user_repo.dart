import '../entities/user_entity.dart';

abstract class UserRepo {
  UserEntity? getCachedUser();
}
