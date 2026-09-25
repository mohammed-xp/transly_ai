import '../../../../core/errors/failure.dart';
import '../../domain/entities/sign_in_form_errors.dart';

sealed class SignInStatus {
  const SignInStatus();
}

class SignInInitial extends SignInStatus {
  const SignInInitial();
}

class SignInSubmitting extends SignInStatus {
  const SignInSubmitting();
}

class SignInSucceeded extends SignInStatus {
  const SignInSucceeded();
}

class SignInFailed extends SignInStatus {
  const SignInFailed(this.failure);

  final Failure failure;
}

class SignInState {
  const SignInState({
    required this.email,
    required this.password,
    required this.isPasswordVisible,
    required this.errors,
    required this.showFieldErrors,
    required this.status,
  });

  factory SignInState.initial() => const SignInState(
    email: '',
    password: '',
    isPasswordVisible: false,
    errors: SignInFormErrors.none(),
    showFieldErrors: false,
    status: SignInInitial(),
  );

  final String email;
  final String password;
  final bool isPasswordVisible;

  /// Latest validation result. Only surfaced in the UI once
  /// [showFieldErrors] is true (i.e. after the first submit attempt).
  final SignInFormErrors errors;
  final bool showFieldErrors;
  final SignInStatus status;

  bool get isSubmitting => status is SignInSubmitting;

  SignInState copyWith({
    String? email,
    String? password,
    bool? isPasswordVisible,
    SignInFormErrors? errors,
    bool? showFieldErrors,
    SignInStatus? status,
  }) {
    return SignInState(
      email: email ?? this.email,
      password: password ?? this.password,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      errors: errors ?? this.errors,
      showFieldErrors: showFieldErrors ?? this.showFieldErrors,
      status: status ?? this.status,
    );
  }
}
