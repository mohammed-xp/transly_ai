import '../models/user_model.dart';

abstract class UserLocalDataSource {
  Future<void> cacheUserData(UserModel data);

  UserModel? getCachedUserData();

  Future<void> saveTokens({required String accessToken, String? refreshToken});

  Future<String?> getAccessToken();

  Future<String?> getRefreshToken();

  Future<void> cachePlan(String plan);

  String? getCachedPlan();

  Future<void> cacheSignInMethod(String method);

  String? getCachedSignInMethod();

  /// Also drops the cached plan and sign-in method — they belong to the
  /// signed-in user.
  Future<void> clearCachedUserData();

  Future<void> clearTokens();
}
