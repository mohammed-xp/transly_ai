import 'dart:async';

import '../domain/repos/logout_repo.dart';

enum SessionStatus { authenticated, expired, signedOut, accountDeleted }

class SessionManager {
  SessionManager(this._logoutRepo);

  final LogoutRepo _logoutRepo;
  final _controller = StreamController<SessionStatus>.broadcast();

  SessionStatus _status = SessionStatus.authenticated;
  bool _isEnding = false;

  Stream<SessionStatus> get stream => _controller.stream;

  SessionStatus get status => _status;

  void markAuthenticated() => _emit(SessionStatus.authenticated);

  /// Idempotent: requests that were already in flight when the session ended
  /// and come back 401 afterwards don't trigger a second logout.
  Future<void> expire() => _end(SessionStatus.expired);

  Future<void> signOut() => _end(SessionStatus.signedOut);

  Future<void> accountDeleted() => _end(SessionStatus.accountDeleted);

  Future<void> _end(SessionStatus status) async {
    if (_isEnding || _status != SessionStatus.authenticated) return;
    _isEnding = true;
    try {
      await _logoutRepo.logout();
      _emit(status);
    } finally {
      _isEnding = false;
    }
  }

  void _emit(SessionStatus status) {
    _status = status;
    _controller.add(status);
  }
}
