import 'package:shared_preferences/shared_preferences.dart';

/// Local persistence for the "remember me" state. Abstracted so the
/// repository can be tested with a fake.
abstract class AuthLocalDataSource {
  /// Returns `(isRemembered, email)`.
  Future<(bool, String)> loadRememberedAccount();

  Future<void> saveRememberedAccount({
    required bool remember,
    required String email,
  });
}

class PrefsAuthLocalDataSource implements AuthLocalDataSource {
  PrefsAuthLocalDataSource(this._prefs);

  final SharedPreferences _prefs;

  static const String _rememberMeKey = 'auth_remember_me';
  static const String _rememberedEmailKey = 'auth_remembered_email';

  @override
  Future<(bool, String)> loadRememberedAccount() async {
    final isRemembered = _prefs.getBool(_rememberMeKey) ?? false;
    final email = _prefs.getString(_rememberedEmailKey) ?? '';
    return (isRemembered, email);
  }

  @override
  Future<void> saveRememberedAccount({
    required bool remember,
    required String email,
  }) async {
    await _prefs.setBool(_rememberMeKey, remember);
    if (remember) {
      await _prefs.setString(_rememberedEmailKey, email);
    } else {
      await _prefs.remove(_rememberedEmailKey);
    }
  }
}
