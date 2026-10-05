import '../models/user_login_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserLoginModel> signInWithEmail({
    required String email,
    required String password,
  });

  /// Exchanges a Google ID token for the app's own session.
  Future<UserLoginModel> signInWithGoogle({required String idToken});

  Future<void> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  });
}
