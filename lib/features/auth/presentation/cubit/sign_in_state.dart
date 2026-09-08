import '../../../../core/errors/failure.dart';
import '../../domain/entities/sign_in_form_errors.dart';

sealed class SignInStatus {
  const SignInStatus();
}

class SignInIdle extends SignInStatus {
  const SignInIdle();
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
    required this.rememberMe,
    required this.isPasswordVisible,
    required this.errors,
    required this.showFieldErrors,
    required this.status,
    required this.isPrefillResolved,
  });

  factory SignInState.initial() => const SignInState(
    email: '',
    password: '',
    rememberMe: false,
    isPasswordVisible: false,
    errors: SignInFormErrors.none(),
    showFieldErrors: false,
    status: SignInIdle(),
    isPrefillResolved: false,
  );

  final String email;
  final String password;
  final bool rememberMe;
  final bool isPasswordVisible;

  /// Flips to `true` once the "remember me" lookup has finished, whatever it
  /// found. The view keys its one-time controller prefill off this edge rather
  /// than off "the first emit", which any unrelated emit could otherwise
  /// consume before the lookup resolves.
  final bool isPrefillResolved;

  /// Latest validation result. Only surfaced in the UI once
  /// [showFieldErrors] is true (i.e. after the first submit attempt).
  final SignInFormErrors errors;
  final bool showFieldErrors;
  final SignInStatus status;

  bool get isSubmitting => status is SignInSubmitting;

  SignInState copyWith({
    String? email,
    String? password,
    bool? rememberMe,
    bool? isPasswordVisible,
    SignInFormErrors? errors,
    bool? showFieldErrors,
    SignInStatus? status,
    bool? isPrefillResolved,
  }) {
    return SignInState(
      email: email ?? this.email,
      password: password ?? this.password,
      rememberMe: rememberMe ?? this.rememberMe,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      errors: errors ?? this.errors,
      showFieldErrors: showFieldErrors ?? this.showFieldErrors,
      status: status ?? this.status,
      isPrefillResolved: isPrefillResolved ?? this.isPrefillResolved,
    );
  }
}
