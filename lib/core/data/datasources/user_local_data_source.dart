import '../models/user_model.dart';

abstract class UserLocalDataSource {
  Future<void> cacheUserData(UserModel data);

  UserModel? getCachedUserData();

  Future<void> saveTokens({required String accessToken, String? refreshToken});

  Future<String?> getAccessToken();

  Future<String?> getRefreshToken();

  Future<void> clearCachedUserData();

  Future<void> clearTokens();
}
