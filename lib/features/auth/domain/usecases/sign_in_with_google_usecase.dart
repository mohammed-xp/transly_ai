import 'dart:async';

import '../../../../core/domain/entities/sign_in_method.dart';
import '../../../../core/domain/entities/user_entity.dart';
import '../../../../core/result/api_result.dart';
import '../../../../core/services/analytics_event.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/session/session_manager.dart';
import '../repos/auth_repo.dart';

class SignInWithGoogleUseCase {
  const SignInWithGoogleUseCase(
    this._repository,
    this._session,
    this._analytics,
  );

  final AuthRepo _repository;
  final SessionManager _session;
  final AnalyticsService _analytics;

  Future<ApiResult<UserEntity?>> call() async {
    final result = await _repository.signInWithGoogle();
    if (result case ApiSuccess(data: final user?)) {
      _session.markAuthenticated();
      unawaited(_analytics.setUserId(user.id));
      unawaited(_analytics.logEvent(const LoginEvent(SignInMethod.google)));
    }
    return result;
  }
}
