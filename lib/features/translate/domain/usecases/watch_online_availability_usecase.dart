import '../repos/translation_repository.dart';

/// Watches whether the online (tone-aware) translation source is available.
class WatchOnlineAvailabilityUseCase {
  const WatchOnlineAvailabilityUseCase(this._repository);

  final TranslationRepository _repository;

  Stream<bool> call() => _repository.watchOnlineAvailability();
}
