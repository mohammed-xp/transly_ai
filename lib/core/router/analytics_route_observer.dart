import 'dart:async';

import 'package:flutter/widgets.dart';

import '../domain/usecases/log_screen_view_usecase.dart';

/// Reports the page that comes into view under its route name. Dialogs and
/// sheets aren't pages, so they don't count as screens.
///
/// A page in [selfReportingRoutes] holds several screens of its own (the
/// home tabs), so it subscribes as a [RouteAware] and reports whichever one
/// is showing.
class AnalyticsRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  AnalyticsRouteObserver(
    this._logScreenView, {
    this.selfReportingRoutes = const {},
  });

  final LogScreenViewUseCase _logScreenView;
  final Set<String> selfReportingRoutes;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _log(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _log(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (route is PageRoute) _log(previousRoute);
  }

  void _log(Route<dynamic>? route) {
    if (route is! PageRoute) return;
    final name = route.settings.name;
    if (name == null || selfReportingRoutes.contains(name)) return;
    unawaited(_logScreenView(name));
  }
}
