import 'analytics_event.dart';

/// Every call is best-effort: none of them throws, so a caller can fire and
/// forget.
abstract class AnalyticsService {
  Future<void> logEvent(AnalyticsEvent event);

  Future<void> logScreenView(String screenName);

  /// The backend account id, or null once signed out. Never an email.
  Future<void> setUserId(String? id);
}
