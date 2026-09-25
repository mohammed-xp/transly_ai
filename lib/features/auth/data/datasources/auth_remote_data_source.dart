import '../models/user_login_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserLoginModel> signInWithEmail({
    required String email,
    required String password,
  });
}
