import 'package:hive_ce/hive.dart';

import 'offline_packs_settings_local_data_source.dart';

class OfflinePacksSettingsLocalDataSourceImpl
    implements OfflinePacksSettingsLocalDataSource {
  OfflinePacksSettingsLocalDataSourceImpl(this._box);

  static const _autoDownloadKey = 'offlineAutoDownload';
  static const _wifiOnlyKey = 'offlineWifiOnly';
  static const _autoDownloadedKey = 'offlineAutoDownloaded';

  final Box<String> _box;

  @override
  bool? getAutoDownload() => _readBool(_autoDownloadKey);

  @override
  Future<void> saveAutoDownload(bool value) =>
      _box.put(_autoDownloadKey, '$value');

  @override
  bool? getWifiOnly() => _readBool(_wifiOnlyKey);

  @override
  Future<void> saveWifiOnly(bool value) => _box.put(_wifiOnlyKey, '$value');

  @override
  Set<String> getAutoDownloadedCodes() {
    final joined = _box.get(_autoDownloadedKey);
    if (joined == null || joined.isEmpty) return {};
    return joined.split(',').toSet();
  }

  @override
  Future<void> saveAutoDownloadedCodes(Set<String> codes) =>
      _box.put(_autoDownloadedKey, codes.join(','));

  bool? _readBool(String key) => switch (_box.get(key)) {
    'true' => true,
    'false' => false,
    _ => null,
  };
}
