import '../../../../core/result/api_result.dart';
import '../entities/remembered_account.dart';
import '../repos/auth_repository.dart';

/// Loads the "remember me" state saved from a previous sign-in.
class LoadRememberedAccountUseCase {
  const LoadRememberedAccountUseCase(this._repository);

  final AuthRepository _repository;

  Future<ApiResult<RememberedAccount>> call() {
    return _repository.loadRememberedAccount();
  }
}
