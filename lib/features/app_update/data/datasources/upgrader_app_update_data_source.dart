import 'package:upgrader/upgrader.dart';

import '../../../../core/errors/app_exceptions.dart';
import '../models/app_update_model.dart';
import 'app_update_data_source.dart';

class UpgraderAppUpdateDataSource implements AppUpdateDataSource {
  UpgraderAppUpdateDataSource(this._upgrader);

  final Upgrader _upgrader;

  @override
  Future<AppUpdateModel?> checkForUpdate() async {
    await _upgrader.initialize();
    if (!_upgrader.shouldDisplayUpgrade()) return null;

    final installedVersion = _upgrader.currentInstalledVersion;
    final latestVersion = _upgrader.currentAppStoreVersion;
    if (installedVersion == null || latestVersion == null) return null;

    return AppUpdateModel(
      installedVersion: installedVersion,
      latestVersion: latestVersion,
      releaseNotes: _upgrader.releaseNotes,
      isRequired: _upgrader.blocked(),
    );
  }

  @override
  Future<void> markPrompted() async {
    await _upgrader.saveLastAlerted();
  }

  @override
  Future<void> openStore() async {
    final listingUrl = _upgrader.currentAppStoreListingURL;
    if (listingUrl == null || listingUrl.isEmpty) {
      throw const UnknownException();
    }
    await _upgrader.sendUserToAppStore();
  }
}
