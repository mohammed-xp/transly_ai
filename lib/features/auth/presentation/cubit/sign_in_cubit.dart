import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/sign_in_form_errors.dart';
import '../../domain/usecases/sign_in_with_email_usecase.dart';
import '../../domain/usecases/validate_sign_in_form_usecase.dart';
import 'sign_in_state.dart';

class SignInCubit extends Cubit<SignInState> {
  SignInCubit({
    required SignInWithEmailUseCase signIn,
    required ValidateSignInFormUseCase validate,
  }) : _signIn = signIn,
       _validate = validate,
       super(SignInState.initial());

  final SignInWithEmailUseCase _signIn;
  final ValidateSignInFormUseCase _validate;

  int _requestId = 0;

  void emailChanged(String email) {
    emit(
      state.copyWith(
        email: email,
        errors: _revalidate(email: email),
      ),
    );
  }

  void passwordChanged(String password) {
    emit(
      state.copyWith(
        password: password,
        errors: _revalidate(password: password),
      ),
    );
  }

  void passwordVisibilityToggled() {
    emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
  }

  SignInFormErrors _revalidate({String? email, String? password}) {
    if (!state.showFieldErrors) return state.errors;
    return _validate(
      email: email ?? state.email,
      password: password ?? state.password,
    );
  }

  Future<void> submit() async {
    if (state.isSubmitting) return;

    final email = state.email.trim();
    final password = state.password;
    final errors = _validate(email: email, password: password);
    if (!errors.isValid) {
      emit(state.copyWith(errors: errors, showFieldErrors: true));
      return;
    }

    final id = ++_requestId;
    emit(
      state.copyWith(
        errors: errors,
        showFieldErrors: true,
        status: const SignInSubmitting(),
      ),
    );

    final result = await _signIn(email: email, password: password);
    if (isClosed || id != _requestId) return;

    emit(
      state.copyWith(
        status: result.when(
          success: (_) => const SignInSucceeded(),
          failure: SignInFailed.new,
        ),
      ),
    );
  }
}
