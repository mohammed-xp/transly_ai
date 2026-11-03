import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/domain/usecases/log_screen_view_usecase.dart';
import 'package:transly_ai/core/router/analytics_route_observer.dart';

import '../../helpers/fake_analytics_service.dart';

void main() {
  late FakeAnalyticsService analytics;
  late AnalyticsRouteObserver observer;

  setUp(() {
    analytics = FakeAnalyticsService();
    observer = AnalyticsRouteObserver(LogScreenViewUseCase(analytics));
  });

  Route<void> page(String? name) => MaterialPageRoute<void>(
    settings: RouteSettings(name: name),
    builder: (_) => const SizedBox(),
  );

  Route<void> dialog(String name) => RawDialogRoute<void>(
    settings: RouteSettings(name: name),
    pageBuilder: (_, _, _) => const SizedBox(),
  );

  test('a pushed page is reported by its route name', () async {
    observer.didPush(page('profile'), null);
    await pumpEventQueue();

    expect(analytics.screens, ['profile']);
  });

  test('popping a page reports the page under it', () async {
    observer.didPop(page('about'), page('profile'));
    await pumpEventQueue();

    expect(analytics.screens, ['profile']);
  });

  test('a replacing page is reported', () async {
    observer.didReplace(newRoute: page('home'), oldRoute: page('signIn'));
    await pumpEventQueue();

    expect(analytics.screens, ['home']);
  });

  test('dialogs are not screens, pushed or popped', () async {
    observer.didPush(dialog('confirm'), page('profile'));
    observer.didPop(dialog('confirm'), page('profile'));
    await pumpEventQueue();

    expect(analytics.screens, isEmpty);
  });

  test('an unnamed page is not reported', () async {
    observer.didPush(page(null), null);
    await pumpEventQueue();

    expect(analytics.screens, isEmpty);
  });

  test('a self-reporting page is left to report its own screens', () async {
    final selfReporting = AnalyticsRouteObserver(
      LogScreenViewUseCase(analytics),
      selfReportingRoutes: const {'home'},
    );

    selfReporting.didPush(page('home'), null);
    selfReporting.didPop(page('profile'), page('home'));
    await pumpEventQueue();

    expect(analytics.screens, isEmpty);
  });
}
