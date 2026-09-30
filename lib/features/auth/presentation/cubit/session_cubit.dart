import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/session/session_manager.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/watch_session_status_usecase.dart';
import 'session_state.dart';

class SessionCubit extends Cubit<SessionState> {
  SessionCubit({
    required WatchSessionStatusUseCase watchSessionStatus,
    required SignOutUseCase signOut,
  }) : _signOut = signOut,
       super(const SessionActive()) {
    _subscription = watchSessionStatus().listen((status) {
      if (isClosed) return;
      emit(switch (status) {
        SessionStatus.authenticated => const SessionActive(),
        SessionStatus.expired => const SessionExpired(),
        SessionStatus.signedOut => const SessionSignedOut(),
        SessionStatus.accountDeleted => const SessionAccountDeleted(),
      });
    });
  }

  final SignOutUseCase _signOut;
  late final StreamSubscription<SessionStatus> _subscription;

  Future<void> signOut() => _signOut();

  @override
  Future<void> close() {
    unawaited(_subscription.cancel());
    return super.close();
  }
}
