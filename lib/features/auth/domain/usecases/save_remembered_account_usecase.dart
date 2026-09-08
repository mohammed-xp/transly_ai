import '../../../../core/result/api_result.dart';
import '../repos/auth_repository.dart';

/// Persists (or clears, when [remember] is `false`) the "remember me" state.
class SaveRememberedAccountUseCase {
  const SaveRememberedAccountUseCase(this._repository);

  final AuthRepository _repository;

  Future<ApiResult<void>> call({
    required bool remember,
    required String email,
  }) {
    return _repository.saveRememberedAccount(remember: remember, email: email);
  }
}
