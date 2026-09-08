import 'package:transly_ai/features/auth/domain/entities/user_entity.dart';

import '../../../../core/result/api_result.dart';
import '../entities/remembered_account.dart';

abstract class AuthRepository {
  Future<ApiResult<UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<ApiResult<RememberedAccount>> loadRememberedAccount();

  Future<ApiResult<void>> saveRememberedAccount({
    required bool remember,
    required String email,
  });

  /// Whether a persisted session token exists right now, so the app can skip
  /// sign-in on launch.
  Future<ApiResult<bool>> hasActiveSession();

  /// Clears the persisted session token without signaling expiry — an
  /// ordinary, user-initiated sign-out.
  Future<ApiResult<void>> signOut();

  /// Emits whenever the backend rejects the session token (HTTP 401) on any
  /// request — not just sign-in — so the app can route back to sign-in.
  Stream<void> watchSessionExpired();
}
