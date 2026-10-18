import 'package:transly_ai/core/session/session_manager.dart';
import 'package:transly_ai/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:transly_ai/features/auth/domain/usecases/watch_session_status_usecase.dart';
import 'package:transly_ai/features/auth/presentation/cubit/session_cubit.dart';

import 'fake_logout_repo.dart';

SessionCubit buildSessionCubit({SessionManager? session}) {
  final manager = session ?? SessionManager(FakeLogoutRepo());
  return SessionCubit(
    watchSessionStatus: WatchSessionStatusUseCase(manager),
    signOut: SignOutUseCase(manager),
  );
}
