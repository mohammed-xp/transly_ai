import '../entities/sign_in_method.dart';
import '../entities/user_entity.dart';

abstract class UserRepo {
  UserEntity? getCachedUser();

  /// How the current session was started. Sessions that predate Google
  /// sign-in stored nothing and were all email sessions.
  SignInMethod getSignInMethod();
}
