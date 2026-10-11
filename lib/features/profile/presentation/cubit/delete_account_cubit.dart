import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/delete_account_use_case.dart';
import '../../domain/usecases/delete_account_with_google_use_case.dart';
import 'delete_account_state.dart';

class DeleteAccountCubit extends Cubit<DeleteAccountState> {
  DeleteAccountCubit({
    required DeleteAccountUseCase deleteAccount,
    required DeleteAccountWithGoogleUseCase deleteAccountWithGoogle,
  }) : _deleteAccount = deleteAccount,
       _deleteAccountWithGoogle = deleteAccountWithGoogle,
       super(const DeleteAccountInitial());

  final DeleteAccountUseCase _deleteAccount;
  final DeleteAccountWithGoogleUseCase _deleteAccountWithGoogle;

  Future<void> deleteAccount(String password) async {
    if (state.isBusy) return;
    emit(const DeleteAccountInProgress());
    final result = await _deleteAccount(password: password);
    if (isClosed) return;
    emit(
      result.when<DeleteAccountState>(
        success: (_) => const DeleteAccountSucceeded(),
        failure: DeleteAccountFailed.new,
      ),
    );
  }

  Future<void> deleteAccountWithGoogle() async {
    if (state.isBusy) return;
    emit(const DeleteAccountInProgress());
    final result = await _deleteAccountWithGoogle();
    if (isClosed) return;
    emit(
      result.when<DeleteAccountState>(
        // Not deleted means the account picker was closed: back to idle.
        success: (deleted) => deleted
            ? const DeleteAccountSucceeded()
            : const DeleteAccountInitial(),
        failure: DeleteAccountFailed.new,
      ),
    );
  }
}
