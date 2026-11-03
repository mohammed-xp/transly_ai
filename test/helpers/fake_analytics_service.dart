import 'package:transly_ai/core/services/analytics_event.dart';
import 'package:transly_ai/core/services/analytics_service.dart';

class FakeAnalyticsService implements AnalyticsService {
  final List<AnalyticsEvent> events = [];
  final List<String> screens = [];

  /// Every value passed to [setUserId], in order; null means cleared.
  final List<String?> userIds = [];

  @override
  Future<void> logEvent(AnalyticsEvent event) async => events.add(event);

  @override
  Future<void> logScreenView(String screenName) async =>
      screens.add(screenName);

  @override
  Future<void> setUserId(String? id) async => userIds.add(id);
}
