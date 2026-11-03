import '../../services/analytics_service.dart';
import '../repos/user_repo.dart';

/// Points analytics at the signed-in account, so users who signed in before
/// analytics shipped are linked too.
class SyncAnalyticsUserUseCase {
  const SyncAnalyticsUserUseCase(this._userRepo, this._analytics);

  final UserRepo _userRepo;
  final AnalyticsService _analytics;

  Future<void> call() => _analytics.setUserId(_userRepo.getCachedUser()?.id);
}
