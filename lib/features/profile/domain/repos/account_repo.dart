import '../../../../core/result/api_result.dart';

abstract class AccountRepo {
  Future<ApiResult<void>> deleteAccount({required String password});

  /// Confirms with a fresh Google sign-in instead of a password. Succeeds
  /// with `false` when the user closed the Google account picker: nothing
  /// was deleted.
  Future<ApiResult<bool>> deleteAccountWithGoogle();
}
