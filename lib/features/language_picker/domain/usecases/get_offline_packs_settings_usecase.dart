import '../entities/offline_packs_settings.dart';
import '../repos/offline_models_repo.dart';

class GetOfflinePacksSettingsUseCase {
  const GetOfflinePacksSettingsUseCase(this._repo);

  final OfflineModelsRepo _repo;

  OfflinePacksSettings call() => _repo.getSettings();
}
