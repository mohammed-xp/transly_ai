import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/features/app_update/domain/entities/app_update_entity.dart';
import 'package:transly_ai/features/app_update/domain/repos/app_update_repo.dart';

class FakeAppUpdateRepo implements AppUpdateRepo {
  FakeAppUpdateRepo({
    this.checkResult = const ApiResult.success(null),
    this.openStoreResult = const ApiResult.success(null),
  });

  ApiResult<AppUpdateEntity?> checkResult;
  ApiResult<void> openStoreResult;
  int markPromptedCalls = 0;
  int openStoreCalls = 0;

  @override
  Future<ApiResult<AppUpdateEntity?>> checkForUpdate() async => checkResult;

  @override
  Future<ApiResult<void>> markPrompted() async {
    markPromptedCalls++;
    return const ApiResult.success(null);
  }

  @override
  Future<ApiResult<void>> openStore() async {
    openStoreCalls++;
    return openStoreResult;
  }
}

/// The design's `13 · Update` sheet: 2.1.0 installed, 2.4.0 in the store.
const testOptionalUpdate = AppUpdateEntity(
  installedVersion: '2.1.0',
  latestVersion: '2.4.0',
  releaseNotes: [
    '40% faster voice translation',
    'New tone: Friendly',
    'Performance fixes and improvements',
  ],
  isRequired: false,
);

/// The design's `13b · Update` screen.
const testRequiredUpdate = AppUpdateEntity(
  installedVersion: '2.1.0',
  latestVersion: '2.4.0',
  releaseNotes: [],
  isRequired: true,
);
