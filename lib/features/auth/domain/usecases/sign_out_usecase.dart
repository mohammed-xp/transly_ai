import '../../../../core/session/session_manager.dart';

class SignOutUseCase {
  const SignOutUseCase(this._session);

  final SessionManager _session;

  Future<void> call() => _session.signOut();
}
