import '../repos/auth_repository.dart';

/// Watches for the backend session expiring (HTTP 401 on any request), so
/// the app can route back to sign-in.
class WatchSessionExpiredUseCase {
  const WatchSessionExpiredUseCase(this._repository);

  final AuthRepository _repository;

  Stream<void> call() => _repository.watchSessionExpired();
}
