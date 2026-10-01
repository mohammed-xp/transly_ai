import '../../../../core/errors/failure.dart';
import '../../domain/entities/password_strength.dart';
import '../../domain/entities/sign_up_form_errors.dart';

sealed class SignUpStatus {
  const SignUpStatus();
}

class SignUpInitial extends SignUpStatus {
  const SignUpInitial();
}

class SignUpSubmitting extends SignUpStatus {
  const SignUpSubmitting();
}

class SignUpSucceeded extends SignUpStatus {
  const SignUpSucceeded();
}

class SignUpFailed extends SignUpStatus {
  const SignUpFailed(this.failure);

  final Failure failure;
}

class SignUpState {
  const SignUpState({
    required this.name,
    required this.email,
    required this.password,
    required this.isPasswordVisible,
    required this.termsAccepted,
    required this.passwordStrength,
    required this.errors,
    required this.showFieldErrors,
    required this.status,
  });

  factory SignUpState.initial() => const SignUpState(
    name: '',
    email: '',
    password: '',
    isPasswordVisible: false,
    termsAccepted: false,
    passwordStrength: null,
    errors: SignUpFormErrors.none(),
    showFieldErrors: false,
    status: SignUpInitial(),
  );

  final String name;
  final String email;
  final String password;
  final bool isPasswordVisible;
  final bool termsAccepted;

  /// Null while the password is empty.
  final PasswordStrength? passwordStrength;

  /// Latest validation result. Only surfaced in the UI once
  /// [showFieldErrors] is true (i.e. after the first submit attempt).
  final SignUpFormErrors errors;
  final bool showFieldErrors;
  final SignUpStatus status;

  bool get isSubmitting => status is SignUpSubmitting;

  SignUpState copyWith({
    String? name,
    String? email,
    String? password,
    bool? isPasswordVisible,
    bool? termsAccepted,
    PasswordStrength? Function()? passwordStrength,
    SignUpFormErrors? errors,
    bool? showFieldErrors,
    SignUpStatus? status,
  }) {
    return SignUpState(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      passwordStrength: passwordStrength != null
          ? passwordStrength()
          : this.passwordStrength,
      errors: errors ?? this.errors,
      showFieldErrors: showFieldErrors ?? this.showFieldErrors,
      status: status ?? this.status,
    );
  }
}
