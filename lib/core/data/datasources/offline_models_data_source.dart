/// The on-device translation models, one per language.
abstract class OfflineModelsDataSource {
  bool isSupported(String code);

  /// Ships with the device and can't be downloaded or removed.
  bool isBuiltIn(String code);

  Future<bool> isDownloaded(String code);

  Future<void> download(String code);

  Future<void> delete(String code);
}
