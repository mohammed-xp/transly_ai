import '../../../../core/result/api_result.dart';
import '../../../../core/session/session_manager.dart';
import '../repos/account_repo.dart';

/// Deletes the account after a fresh Google sign-in and, only once the
/// backend deleted it, ends the session. A success carrying `false` means the
/// user closed the account picker.
class DeleteAccountWithGoogleUseCase {
  const DeleteAccountWithGoogleUseCase(this._repository, this._session);

  final AccountRepo _repository;
  final SessionManager _session;

  Future<ApiResult<bool>> call() async {
    final result = await _repository.deleteAccountWithGoogle();
    if (result is ApiSuccess<bool> && result.data) {
      await _session.accountDeleted();
    }
    return result;
  }
}
