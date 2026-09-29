import '../models/app_update_model.dart';

abstract class AppUpdateDataSource {
  /// Null when there is nothing to prompt for.
  Future<AppUpdateModel?> checkForUpdate();

  Future<void> markPrompted();

  Future<void> openStore();
}
