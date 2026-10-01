abstract class AppLanguageLocalDataSource {
  String? getLanguageCode();

  /// A null [code] clears the saved choice.
  Future<void> saveLanguageCode(String? code);
}
