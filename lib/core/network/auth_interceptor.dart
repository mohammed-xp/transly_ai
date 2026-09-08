import 'dart:async';

import 'package:dio/dio.dart';

import 'api_endpoints.dart';
import '../session/session_manager.dart';

/// Attaches the backend session token to every outgoing request and reacts to
/// the backend rejecting it. There is no refresh token yet (CLAUDE.md-adjacent
/// note: single access token only) — a 401 simply expires the local session
/// so the app routes back to sign-in; the failed request still surfaces its
/// error to the caller so it can fall back (e.g. translation falls back to
/// the on-device engine).
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._sessionManager);

  final SessionManager _sessionManager;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _sessionManager.token;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // A 401 from the login endpoint itself just means "wrong credentials" —
    // ApiAuthRemoteDataSource maps that to AuthFailureReason.invalidCredentials
    // already. Only a 401 from an *authenticated* endpoint means an existing
    // session actually expired.
    if (err.response?.statusCode == 401 &&
        !_isUnauthenticatedEndpoint(err.requestOptions)) {
      unawaited(_sessionManager.expire());
    }
    handler.next(err);
  }

  bool _isUnauthenticatedEndpoint(RequestOptions options) {
    return Uri.tryParse(options.path)?.path == ApiEndpoints.login;
  }
}
