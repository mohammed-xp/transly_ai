import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/delete_account_use_case.dart';
import 'delete_account_state.dart';

class DeleteAccountCubit extends Cubit<DeleteAccountState> {
  DeleteAccountCubit({required DeleteAccountUseCase deleteAccount})
    : _deleteAccount = deleteAccount,
      super(const DeleteAccountInitial());

  final DeleteAccountUseCase _deleteAccount;

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
}
