import '../../../../core/session/session_manager.dart';

class WatchSessionStatusUseCase {
  const WatchSessionStatusUseCase(this._session);

  final SessionManager _session;

  Stream<SessionStatus> call() => _session.stream;
}
