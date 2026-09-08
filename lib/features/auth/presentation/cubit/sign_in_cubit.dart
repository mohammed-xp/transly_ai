import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/sign_in_form_errors.dart';
import '../../domain/usecases/load_remembered_account_usecase.dart';
import '../../domain/usecases/save_remembered_account_usecase.dart';
import '../../domain/usecases/sign_in_with_email_usecase.dart';
import '../../domain/usecases/validate_sign_in_form_usecase.dart';
import 'sign_in_state.dart';

/// Orchestrates the sign-in screen: field edits, validation, submission, and
/// the "remember me" prefill/persist round-trip. Depends only on use cases
/// (CLAUDE.md §B-1).
class SignInCubit extends Cubit<SignInState> {
  SignInCubit({
    required SignInWithEmailUseCase signIn,
    required ValidateSignInFormUseCase validate,
    required LoadRememberedAccountUseCase loadRemembered,
    required SaveRememberedAccountUseCase saveRemembered,
  }) : _signIn = signIn,
       _validate = validate,
       _loadRemembered = loadRemembered,
       _saveRemembered = saveRemembered,
       super(SignInState.initial());

  final SignInWithEmailUseCase _signIn;
  final ValidateSignInFormUseCase _validate;
  final LoadRememberedAccountUseCase _loadRemembered;
  final SaveRememberedAccountUseCase _saveRemembered;

  /// Incremented on every submit attempt; a run only emits if it is still the
  /// latest (mirrors `TranslateCubit`'s staleness guard).
  int _requestId = 0;

  /// Prefills the form from a previous "remember me" — called once when the
  /// screen is created.
  ///
  /// Always resolves [SignInState.isPrefillResolved], even when there is
  /// nothing to prefill, so the view has a single unambiguous edge to sync its
  /// controllers on.
  Future<void> loadRememberedAccount() async {
    final result = await _loadRemembered();
    if (isClosed) return;
    result.when(
      success: (account) {
        // Storage is slow enough that the user may already be typing. Their
        // input always wins — overwriting it here would desync the visible
        // field from the state that submit() actually sends.
        if (!account.isRemembered || state.email.isNotEmpty) {
          emit(state.copyWith(isPrefillResolved: true));
          return;
        }
        emit(
          state.copyWith(
            email: account.email,
            rememberMe: true,
            isPrefillResolved: true,
          ),
        );
      },
      failure: (_) => emit(state.copyWith(isPrefillResolved: true)),
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
        errors: _revalidate(password: password),
      ),
    );
  }

  void rememberMeToggled(bool value) {
    emit(state.copyWith(rememberMe: value));
  }

  void passwordVisibilityToggled() {
    emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
  }

  /// Re-runs validation only after the first submit attempt — before that the
  /// form stays quiet while the user is still typing.
  SignInFormErrors _revalidate({String? email, String? password}) {
    if (!state.showFieldErrors) return state.errors;
    return _validate(
      email: email ?? state.email,
      password: password ?? state.password,
    );
  }

  Future<void> submit() async {
    // The keyboard's "done" action reaches here even while the button is
    // disabled, so concurrency is guarded on the state, not just in the UI.
    // (_requestId discards stale *results*; this stops duplicate *requests*,
    // which would otherwise trip the provider's rate limiter.)
    if (state.isSubmitting) return;

    // Surrounding whitespace from paste/autofill is insignificant — trimmed
    // once here so what is validated, sent, and persisted always agree.
    final email = state.email.trim();
    final password = state.password;
    final errors = _validate(email: email, password: password);
    if (!errors.isValid) {
      emit(state.copyWith(errors: errors, showFieldErrors: true));
      return;
    }

    final id = ++_requestId;
    final rememberMe = state.rememberMe;

    emit(
      state.copyWith(
        errors: errors,
        showFieldErrors: true,
        status: const SignInSubmitting(),
      ),
    );
    final result = await _signIn(email: email, password: password);
    if (isClosed || id != _requestId) return;

    await result.when(
      success: (_) async {
        // A "remember me" persistence failure must not block navigating on
        // (see `AuthRepositoryImpl.saveRememberedAccount`).
        await _saveRemembered(remember: rememberMe, email: email);
        if (isClosed || id != _requestId) return;
        emit(state.copyWith(status: SignInSucceeded()));
      },
      failure: (failure) async {
        emit(state.copyWith(status: SignInFailed(failure)));
      },
    );
  }
}
