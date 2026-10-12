import 'package:hive_ce/hive.dart';

import 'app_theme_local_data_source.dart';

class AppThemeLocalDataSourceImpl implements AppThemeLocalDataSource {
  AppThemeLocalDataSourceImpl(this._box);

  static const _themeModeKey = 'appThemeMode';

  final Box<String> _box;

  @override
  String? getThemeModeName() => _box.get(_themeModeKey);

  @override
  Future<void> saveThemeModeName(String name) => _box.put(_themeModeKey, name);
}
