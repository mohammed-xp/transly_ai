import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/watch_session_expired_usecase.dart';
import 'session_state.dart';

/// Tracks whether the backend session is still valid, application-wide.
/// Depends only on use cases (CLAUDE.md §B-1). Transitions: [SessionActive]
/// to [SessionExpired] (driven by [WatchSessionExpiredUseCase]) or to
/// [SessionSignedOut] (driven by an explicit [signOut] call).
class SessionCubit extends Cubit<SessionState> {
  SessionCubit({
    required WatchSessionExpiredUseCase watchSessionExpired,
    required SignOutUseCase signOut,
  }) : _signOut = signOut,
       super(const SessionActive()) {
    _subscription = watchSessionExpired().listen((_) {
      if (isClosed) return;
      emit(const SessionExpired());
    });
  }

  final SignOutUseCase _signOut;
  late final StreamSubscription<void> _subscription;

  Future<void> signOut() async {
    await _signOut();
    if (isClosed) return;
    emit(const SessionSignedOut());
  }

  @override
  Future<void> close() {
    unawaited(_subscription.cancel());
    return super.close();
  }
}
