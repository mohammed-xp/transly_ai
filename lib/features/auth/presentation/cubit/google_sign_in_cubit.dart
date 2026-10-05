import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/sign_in_with_google_usecase.dart';
import 'google_sign_in_state.dart';

class GoogleSignInCubit extends Cubit<GoogleSignInState> {
  GoogleSignInCubit(this._signInWithGoogle)
    : super(const GoogleSignInInitial());

  final SignInWithGoogleUseCase _signInWithGoogle;

  Future<void> signIn() async {
    if (state is GoogleSignInLoading) return;
    emit(const GoogleSignInLoading());

    final result = await _signInWithGoogle();
    if (isClosed) return;

    emit(
      result.when(
        // No user means the account picker was closed: back to idle, silently.
        success: (user) => user == null
            ? const GoogleSignInInitial()
            : const GoogleSignInSucceeded(),
        failure: GoogleSignInFailed.new,
      ),
    );
  }
}
