import 'dart:async';

import '../../../../core/result/api_result.dart';
import '../../../../core/services/analytics_event.dart';
import '../../../../core/services/analytics_service.dart';
import '../repos/auth_repo.dart';

/// Creates an account. Registration returns no tokens, so the user still has
/// to sign in afterwards.
class SignUpWithEmailUseCase {
  const SignUpWithEmailUseCase(this._repository, this._analytics);

  final AuthRepo _repository;
  final AnalyticsService _analytics;

  Future<ApiResult<void>> call({
    required String name,
    required String email,
    required String password,
  }) async {
    final result = await _repository.signUpWithEmail(
      name: name,
      email: email,
      password: password,
    );
    if (result is ApiSuccess) {
      unawaited(_analytics.logEvent(const SignUpEvent()));
    }
    return result;
  }
}
