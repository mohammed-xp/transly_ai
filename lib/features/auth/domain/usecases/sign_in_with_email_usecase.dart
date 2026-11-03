import 'dart:async';

import '../../../../core/domain/entities/sign_in_method.dart';
import '../../../../core/domain/entities/user_entity.dart';
import '../../../../core/result/api_result.dart';
import '../../../../core/services/analytics_event.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/session/session_manager.dart';
import '../repos/auth_repo.dart';

/// Signs in with [email] and [password] and, on success, starts a new session.
class SignInWithEmailUseCase {
  const SignInWithEmailUseCase(
    this._repository,
    this._session,
    this._analytics,
  );

  final AuthRepo _repository;
  final SessionManager _session;
  final AnalyticsService _analytics;

  Future<ApiResult<UserEntity>> call({
    required String email,
    required String password,
  }) async {
    final result = await _repository.signInWithEmail(
      email: email,
      password: password,
    );
    if (result case ApiSuccess(data: final user)) {
      _session.markAuthenticated();
      unawaited(_analytics.setUserId(user.id));
      unawaited(_analytics.logEvent(const LoginEvent(SignInMethod.email)));
    }
    return result;
  }
}
