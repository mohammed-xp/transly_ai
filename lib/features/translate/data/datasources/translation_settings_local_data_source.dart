import '../models/tone_catalog_model.dart';

abstract class TranslationSettingsLocalDataSource {
  String? getToneCode();

  Future<void> saveToneCode(String code);

  ToneCatalogModel? getCachedTones();

  Future<void> cacheTones(ToneCatalogModel tones);
}
