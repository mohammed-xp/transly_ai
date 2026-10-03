import 'package:hive_ce/hive.dart';

import '../../security/token_storage.dart';
import '../models/user_model.dart';
import 'user_local_data_source.dart';

class UserLocalDataSourceImpl implements UserLocalDataSource {
  UserLocalDataSourceImpl(this._box, this._settingsBox, this._tokenStorage);

  static const _currentUserKey = 'currentUser';
  static const _planKey = 'userPlan';

  final Box<UserModel> _box;
  final Box<String> _settingsBox;
  final TokenStorage _tokenStorage;

  @override
  Future<void> cacheUserData(UserModel data) => _box.put(_currentUserKey, data);

  @override
  UserModel? getCachedUserData() => _box.get(_currentUserKey);

  @override
  Future<void> cachePlan(String plan) => _settingsBox.put(_planKey, plan);

  @override
  String? getCachedPlan() => _settingsBox.get(_planKey);

  @override
  Future<void> clearCachedUserData() async {
    await _box.delete(_currentUserKey);
    await _settingsBox.delete(_planKey);
  }

  @override
  Future<void> saveTokens({required String accessToken, String? refreshToken}) {
    return _tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  @override
  Future<String?> getAccessToken() => _tokenStorage.getAccessToken();

  @override
  Future<String?> getRefreshToken() => _tokenStorage.getRefreshToken();

  @override
  Future<void> clearTokens() => _tokenStorage.clear();
}
