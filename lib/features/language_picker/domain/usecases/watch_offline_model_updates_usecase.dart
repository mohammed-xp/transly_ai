import '../entities/offline_model_status.dart';
import '../repos/offline_models_repo.dart';

class WatchOfflineModelUpdatesUseCase {
  const WatchOfflineModelUpdatesUseCase(this._repo);

  final OfflineModelsRepo _repo;

  Stream<OfflineModelUpdate> call() => _repo.watchUpdates();
}
