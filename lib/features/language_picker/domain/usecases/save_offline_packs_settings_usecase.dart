import '../../../../core/result/api_result.dart';
import '../entities/offline_packs_settings.dart';
import '../repos/offline_models_repo.dart';

class SaveOfflinePacksSettingsUseCase {
  const SaveOfflinePacksSettingsUseCase(this._repo);

  final OfflineModelsRepo _repo;

  Future<ApiResult<void>> call(OfflinePacksSettings settings) =>
      _repo.saveSettings(settings);
}
