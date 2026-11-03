import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

import 'analytics_event.dart';
import 'analytics_service.dart';

/// [FirebaseAnalytics.instance] is read inside each call: it throws when
/// `Firebase.initializeApp` failed at startup, and analytics must not take
/// the app down with it.
class FirebaseAnalyticsService implements AnalyticsService {
  @override
  Future<void> logEvent(AnalyticsEvent event) => _run(
    () => FirebaseAnalytics.instance.logEvent(
      name: event.name,
      parameters: event.parameters,
    ),
  );

  @override
  Future<void> logScreenView(String screenName) => _run(
    () => FirebaseAnalytics.instance.logScreenView(screenName: screenName),
  );

  @override
  Future<void> setUserId(String? id) =>
      _run(() => FirebaseAnalytics.instance.setUserId(id: id));

  Future<void> _run(Future<void> Function() call) async {
    try {
      await call();
    } catch (error) {
      if (kDebugMode) debugPrint('Analytics call failed: $error');
    }
  }
}
