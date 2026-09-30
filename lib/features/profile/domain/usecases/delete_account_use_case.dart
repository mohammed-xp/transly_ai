import '../../../../core/result/api_result.dart';
import '../../../../core/session/session_manager.dart';
import '../repos/account_repo.dart';

/// Deletes the account on the backend and, only once that succeeded, ends the
/// session so the local user data is cleared too.
class DeleteAccountUseCase {
  const DeleteAccountUseCase(this._repository, this._session);

  final AccountRepo _repository;
  final SessionManager _session;

  Future<ApiResult<void>> call({required String password}) async {
    final result = await _repository.deleteAccount(password: password);
    if (result is ApiSuccess<void>) await _session.accountDeleted();
    return result;
  }
}
