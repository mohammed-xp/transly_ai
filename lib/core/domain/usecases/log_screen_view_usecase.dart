import '../../services/analytics_service.dart';

class LogScreenViewUseCase {
  const LogScreenViewUseCase(this._analytics);

  final AnalyticsService _analytics;

  Future<void> call(String screenName) => _analytics.logScreenView(screenName);
}
