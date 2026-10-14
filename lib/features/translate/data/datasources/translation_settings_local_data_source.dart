abstract class TranslationSettingsLocalDataSource {
  String? getToneName();

  Future<void> saveToneName(String name);
}
