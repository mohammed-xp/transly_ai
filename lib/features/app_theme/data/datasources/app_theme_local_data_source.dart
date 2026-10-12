abstract class AppThemeLocalDataSource {
  String? getThemeModeName();

  Future<void> saveThemeModeName(String name);
}
