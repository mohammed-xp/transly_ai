import 'package:transly_ai/features/app_update/data/datasources/app_update_data_source.dart';
import 'package:transly_ai/features/app_update/data/models/app_update_model.dart';

class FakeAppUpdateDataSource implements AppUpdateDataSource {
  FakeAppUpdateDataSource({this.update, this.error});

  AppUpdateModel? update;

  /// Thrown by every method when set.
  Object? error;

  int markPromptedCalls = 0;
  int openStoreCalls = 0;

  @override
  Future<AppUpdateModel?> checkForUpdate() async {
    if (error case final error?) throw error;
    return update;
  }

  @override
  Future<void> markPrompted() async {
    markPromptedCalls++;
    if (error case final error?) throw error;
  }

  @override
  Future<void> openStore() async {
    openStoreCalls++;
    if (error case final error?) throw error;
  }
}
