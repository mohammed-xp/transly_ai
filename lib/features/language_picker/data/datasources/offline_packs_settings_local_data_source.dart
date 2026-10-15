abstract class OfflinePacksSettingsLocalDataSource {
  bool? getAutoDownload();

  Future<void> saveAutoDownload(bool value);

  bool? getWifiOnly();

  Future<void> saveWifiOnly(bool value);

  /// Codes of the languages auto-download put on the device.
  Set<String> getAutoDownloadedCodes();

  Future<void> saveAutoDownloadedCodes(Set<String> codes);
}
