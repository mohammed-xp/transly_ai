import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Holds the backend JWT for the lifetime of the app. [token] is read
/// synchronously (from an in-memory cache) so the auth interceptor can attach
/// it to every request without an extra await; [restore] must complete before
/// the first request is made.
abstract class SessionManager {
  String? get token;

  /// Loads any previously persisted token into memory. Call once at startup.
  Future<void> restore();

  Future<void> save(String token);

  /// Clears the token without signaling expiry — used on an ordinary logout.
  Future<void> clear();

  /// Clears the token and signals [onExpired] — used when the backend rejects
  /// the token (401), so the app can route back to sign-in. Idempotent: a
  /// second call before the next [save] is a no-op, so concurrent in-flight
  /// requests that all 401 on the same stale token only trigger one
  /// sign-out, not one per request.
  Future<void> expire();

  /// Emits whenever [expire] is called.
  Stream<void> get onExpired;
}

class SecureSessionManager implements SessionManager {
  SecureSessionManager(this._storage);

  static const String _tokenKey = 'auth_access_token';

  final FlutterSecureStorage _storage;
  final StreamController<void> _expiredController =
      StreamController<void>.broadcast();

  String? _token;
  bool _expired = false;

  @override
  String? get token => _token;

  @override
  Stream<void> get onExpired => _expiredController.stream;

  @override
  Future<void> restore() async {
    try {
      _token = await _storage.read(key: _tokenKey);
    } catch (_) {
      // Platform storage unavailable (e.g. no secure-storage backend in a
      // test harness) — degrade to "no persisted session" rather than
      // failing app startup, mirroring `AuthRepositoryImpl.loadRememberedAccount`.
      _token = null;
    }
  }

  @override
  Future<void> save(String token) async {
    _token = token;
    _expired = false;
    await _storage.write(key: _tokenKey, value: token);
  }

  @override
  Future<void> clear() async {
    _token = null;
    await _storage.delete(key: _tokenKey);
  }

  @override
  Future<void> expire() async {
    if (_expired) return;
    _expired = true;
    await clear();
    _expiredController.add(null);
  }
}
