import 'package:transly_ai/features/auth/data/models/user_login_model.dart';

import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/result/api_result.dart';
import '../../../../core/session/session_manager.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/remembered_account.dart';
import '../../domain/repos/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

/// Exceptions are caught at this boundary and mapped to typed [Failure]s
/// (CLAUDE.md §B-5). On successful sign-in, the backend's session token is
/// persisted via [SessionManager] so subsequent requests are authenticated.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthLocalDataSource local,
    required AuthRemoteDataSource remote,
    required SessionManager session,
  }) : _local = local,
       _remote = remote,
       _session = session;

  final AuthLocalDataSource _local;
  final AuthRemoteDataSource _remote;
  final SessionManager _session;

  @override
  Future<ApiResult<UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final UserLoginModel result = await _remote.signInWithEmail(
        email: email,
        password: password,
      );
      await _session.save(result.userTokenModel.accessToken);
      return ApiResult.success(result.userModel.toEntity());
    } catch (e) {
      return ApiResult.failure(_mapAuthError(e));
    }
  }

  Failure _mapAuthError(Object error) => switch (error) {
    AuthProviderException(:final code, :final message) => AuthFailure(
      _reasonForCode(code),
      message,
    ),
    RemoteConnectionException(:final message) => AuthFailure(
      AuthFailureReason.network,
      message,
    ),
    _ => AuthFailure(AuthFailureReason.unknown, error.toString()),
  };

  // Codes produced by ApiAuthRemoteDataSource (see its _codeForStatus): a 401
  // is invalid credentials, a 403 means the account is disabled, a 429 is
  // rate limiting, and anything else falls back to 'unknown'.
  AuthFailureReason _reasonForCode(String code) => switch (code) {
    'invalid-credential' => AuthFailureReason.invalidCredentials,
    'user-disabled' => AuthFailureReason.userDisabled,
    'too-many-requests' => AuthFailureReason.tooManyRequests,
    _ => AuthFailureReason.unknown,
  };

  @override
  Future<ApiResult<RememberedAccount>> loadRememberedAccount() async {
    try {
      final (isRemembered, email) = await _local.loadRememberedAccount();
      return ApiResult.success(
        RememberedAccount(isRemembered: isRemembered, email: email),
      );
    } catch (_) {
      return ApiResult.success(RememberedAccount.none());
    }
  }

  @override
  Future<ApiResult<void>> saveRememberedAccount({
    required bool remember,
    required String email,
  }) async {
    try {
      await _local.saveRememberedAccount(remember: remember, email: email);
      return const ApiResult.success(null);
    } catch (_) {
      // Failing to persist "remember me" must not fail the sign-in it follows.
      return const ApiResult.success(null);
    }
  }

  @override
  Future<ApiResult<bool>> hasActiveSession() async {
    try {
      return ApiResult.success(_session.token != null);
    } catch (e) {
      return ApiResult.failure(
        AuthFailure(AuthFailureReason.unknown, e.toString()),
      );
    }
  }

  @override
  Future<ApiResult<void>> signOut() async {
    try {
      await _session.clear();
      return const ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(
        AuthFailure(AuthFailureReason.unknown, e.toString()),
      );
    }
  }

  @override
  Stream<void> watchSessionExpired() => _session.onExpired;
}
