import '../models/app_update_model.dart';
import 'app_update_data_source.dart';

/// Debug-only stand-in for the store lookup, so the update UI can be seen
/// before the app is published. Enabled with
/// `--dart-define=APP_UPDATE_PREVIEW=optional` (or `=required`).
class PreviewAppUpdateDataSource implements AppUpdateDataSource {
  const PreviewAppUpdateDataSource({required this.isRequired});

  final bool isRequired;

  @override
  Future<AppUpdateModel?> checkForUpdate() async {
    return AppUpdateModel(
      installedVersion: '2.1.0',
      latestVersion: '2.4.0',
      releaseNotes:
          '40% faster voice translation\n'
          'New tone: Friendly\n'
          'Performance fixes and improvements',
      isRequired: isRequired,
    );
  }

  @override
  Future<void> markPrompted() async {}

  @override
  Future<void> openStore() async {}
}
