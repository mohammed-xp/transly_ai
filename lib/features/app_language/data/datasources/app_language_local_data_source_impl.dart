import 'package:hive_ce/hive.dart';

import 'app_language_local_data_source.dart';

class AppLanguageLocalDataSourceImpl implements AppLanguageLocalDataSource {
  AppLanguageLocalDataSourceImpl(this._box);

  static const _languageKey = 'appLanguage';

  final Box<String> _box;

  @override
  String? getLanguageCode() => _box.get(_languageKey);

  @override
  Future<void> saveLanguageCode(String? code) {
    if (code == null) return _box.delete(_languageKey);
    return _box.put(_languageKey, code);
  }
}
