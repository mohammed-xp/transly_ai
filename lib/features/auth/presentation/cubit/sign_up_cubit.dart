import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/sign_up_form_errors.dart';
import '../../domain/usecases/evaluate_password_strength_usecase.dart';
import '../../domain/usecases/sign_up_with_email_usecase.dart';
import '../../domain/usecases/validate_sign_up_form_usecase.dart';
import 'sign_up_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit({
    required SignUpWithEmailUseCase signUp,
    required ValidateSignUpFormUseCase validate,
    required EvaluatePasswordStrengthUseCase evaluatePasswordStrength,
  }) : _signUp = signUp,
       _validate = validate,
       _evaluatePasswordStrength = evaluatePasswordStrength,
       super(SignUpState.initial());

  final SignUpWithEmailUseCase _signUp;
  final ValidateSignUpFormUseCase _validate;
  final EvaluatePasswordStrengthUseCase _evaluatePasswordStrength;

  int _requestId = 0;

  void nameChanged(String name) {
    emit(
      state.copyWith(
        name: name,
        errors: _revalidate(name: name),
      ),
    );
  }

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
        passwordStrength: () => _evaluatePasswordStrength(password),
        errors: _revalidate(password: password),
      ),
    );
  }

  void passwordVisibilityToggled() {
    emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
  }

  void termsToggled() {
    final termsAccepted = !state.termsAccepted;
    emit(
      state.copyWith(
        termsAccepted: termsAccepted,
        errors: _revalidate(termsAccepted: termsAccepted),
      ),
    );
  }

  SignUpFormErrors _revalidate({
    String? name,
    String? email,
    String? password,
    bool? termsAccepted,
  }) {
    if (!state.showFieldErrors) return state.errors;
    return _validate(
      name: name ?? state.name,
      email: email ?? state.email,
      password: password ?? state.password,
      termsAccepted: termsAccepted ?? state.termsAccepted,
    );
  }

  Future<void> submit() async {
    if (state.isSubmitting) return;

    final name = state.name.trim();
    final email = state.email.trim();
    final password = state.password;
    final errors = _validate(
      name: name,
      email: email,
      password: password,
      termsAccepted: state.termsAccepted,
    );
    if (!errors.isValid) {
      emit(state.copyWith(errors: errors, showFieldErrors: true));
      return;
    }

    final id = ++_requestId;
    emit(
      state.copyWith(
        errors: errors,
        showFieldErrors: true,
        status: const SignUpSubmitting(),
      ),
    );

    final result = await _signUp(name: name, email: email, password: password);
    if (isClosed || id != _requestId) return;

    emit(
      state.copyWith(
        status: result.when(
          success: (_) => const SignUpSucceeded(),
          failure: SignUpFailed.new,
        ),
      ),
    );
  }
}
