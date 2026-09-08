import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/features/auth/domain/entities/user_entity.dart';
import 'package:transly_ai/features/auth/domain/entities/remembered_account.dart';
import 'package:transly_ai/features/auth/domain/entities/sign_in_form_errors.dart';
import 'package:transly_ai/features/auth/domain/repos/auth_repository.dart';
import 'package:transly_ai/features/auth/domain/usecases/load_remembered_account_usecase.dart';
import 'package:transly_ai/features/auth/domain/usecases/save_remembered_account_usecase.dart';
import 'package:transly_ai/features/auth/domain/usecases/sign_in_with_email_usecase.dart';
import 'package:transly_ai/features/auth/domain/usecases/validate_sign_in_form_usecase.dart';
import 'package:transly_ai/features/auth/presentation/cubit/sign_in_cubit.dart';
import 'package:transly_ai/features/auth/presentation/cubit/sign_in_state.dart';

/// Deterministic in-memory repository. Real use cases wrap it so the cubit is
/// exercised through its real dependencies (no mocking framework) — same
/// convention as `translate_cubit_test.dart`'s `_FakeTranslationRepository`.
class _FakeAuthRepository implements AuthRepository {
  Failure? signInFailure;
  bool userToReturn = true;
  int signInCallCount = 0;

  /// Recorded so tests can assert what the cubit actually sent (trimming,
  /// field ordering) rather than only that a call happened.
  String? lastSignInEmail;
  String? lastSignInPassword;

  /// Gates the sign-in response so a test can hold a request in flight.
  Completer<void>? signInGate;

  RememberedAccount rememberedAccount = RememberedAccount.none();

  /// Gates the remember-me lookup so a test can interleave user typing.
  Completer<void>? loadGate;

  bool? lastSavedRemember;
  String? lastSavedEmail;
  int saveCallCount = 0;

  @override
  Future<ApiResult<UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    signInCallCount++;
    lastSignInEmail = email;
    lastSignInPassword = password;
    if (signInGate != null) await signInGate!.future;
    final failure = signInFailure;
    if (failure != null) return ApiResult.failure(failure);
    return ApiResult.success( UserEntity(
            id: 'uid-1',
            email: 'ahmed@example.com',
            username: 'ahmed',
            createdAt: DateTime.utc(2023),
          ));
  }

  @override
  Future<ApiResult<RememberedAccount>> loadRememberedAccount() async {
    if (loadGate != null) await loadGate!.future;
    return ApiResult.success(rememberedAccount);
  }

  @override
  Future<ApiResult<void>> saveRememberedAccount({
    required bool remember,
    required String email,
  }) async {
    saveCallCount++;
    lastSavedRemember = remember;
    lastSavedEmail = email;
    return const ApiResult.success(null);
  }

  @override
  Stream<void> watchSessionExpired() => const Stream.empty();

  @override
  Future<ApiResult<bool>> hasActiveSession() => throw UnimplementedError();

  @override
  Future<ApiResult<void>> signOut() => throw UnimplementedError();
}

SignInCubit _buildCubit(_FakeAuthRepository repo) {
  return SignInCubit(
    signIn: SignInWithEmailUseCase(repo),
    validate: const ValidateSignInFormUseCase(),
    loadRemembered: LoadRememberedAccountUseCase(repo),
    saveRemembered: SaveRememberedAccountUseCase(repo),
  );
}

void main() {
  group('SignInCubit', () {
    test('starts idle with empty fields and no visible errors', () {
      final cubit = _buildCubit(_FakeAuthRepository());
      addTearDown(cubit.close);

      expect(cubit.state.status, isA<SignInIdle>());
      expect(cubit.state.email, isEmpty);
      expect(cubit.state.password, isEmpty);
      expect(cubit.state.showFieldErrors, isFalse);
    });

    test('submit with an invalid form does not call the repository', () async {
      final repo = _FakeAuthRepository();
      final cubit = _buildCubit(repo);
      addTearDown(cubit.close);

      await cubit.submit();

      expect(repo.signInCallCount, 0);
      expect(cubit.state.showFieldErrors, isTrue);
      expect(cubit.state.errors.isValid, isFalse);
      expect(cubit.state.status, isA<SignInIdle>());
    });

    test(
      'submit with a valid form succeeds and persists remember-me',
      () async {
        final repo = _FakeAuthRepository();
        final cubit = _buildCubit(repo);
        addTearDown(cubit.close);

        cubit.emailChanged('ahmed@example.com');
        cubit.passwordChanged('secret1');
        cubit.rememberMeToggled(true);

        await cubit.submit();

        expect(repo.signInCallCount, 1);
        final status = cubit.state.status;
        expect(status, isA<SignInSucceeded>());
        expect(repo.saveCallCount, 1);
        expect(repo.lastSavedRemember, isTrue);
        expect(repo.lastSavedEmail, 'ahmed@example.com');
      },
    );

    test('submit persists remember-me as false when unchecked', () async {
      final repo = _FakeAuthRepository();
      final cubit = _buildCubit(repo);
      addTearDown(cubit.close);

      cubit.emailChanged('ahmed@example.com');
      cubit.passwordChanged('secret1');

      await cubit.submit();

      expect(repo.lastSavedRemember, isFalse);
    });

    test(
      'a failing sign-in emits SignInFailed with the repository failure',
      () async {
        final repo = _FakeAuthRepository()
          ..signInFailure = const AuthFailure(
            AuthFailureReason.invalidCredentials,
          );
        final cubit = _buildCubit(repo);
        addTearDown(cubit.close);

        cubit.emailChanged('ahmed@example.com');
        cubit.passwordChanged('wrong-pass');

        await cubit.submit();

        final status = cubit.state.status;
        expect(status, isA<SignInFailed>());
        expect(
          ((status as SignInFailed).failure as AuthFailure).reason,
          AuthFailureReason.invalidCredentials,
        );
        expect(
          repo.saveCallCount,
          0,
          reason: 'a failed sign-in must not persist remember-me',
        );
      },
    );

    test(
      'loadRememberedAccount prefills the email and remember-me flag',
      () async {
        final repo = _FakeAuthRepository()
          ..rememberedAccount = const RememberedAccount(
            isRemembered: true,
            email: 'ahmed@example.com',
          );
        final cubit = _buildCubit(repo);
        addTearDown(cubit.close);

        await cubit.loadRememberedAccount();

        expect(cubit.state.email, 'ahmed@example.com');
        expect(cubit.state.rememberMe, isTrue);
      },
    );

    test(
      'loadRememberedAccount is a no-op when nothing was remembered',
      () async {
        final cubit = _buildCubit(_FakeAuthRepository());
        addTearDown(cubit.close);

        await cubit.loadRememberedAccount();

        expect(cubit.state.email, isEmpty);
        expect(cubit.state.rememberMe, isFalse);
      },
    );

    test('field errors only appear after the first submit attempt', () {
      final cubit = _buildCubit(_FakeAuthRepository());
      addTearDown(cubit.close);

      cubit.emailChanged('not-an-email');

      expect(cubit.state.showFieldErrors, isFalse);
      expect(
        cubit.state.errors.isValid,
        isTrue,
        reason: 'errors are not surfaced before the first submit',
      );
    });

    test('field errors re-validate live once shown', () async {
      final cubit = _buildCubit(_FakeAuthRepository());
      addTearDown(cubit.close);

      await cubit.submit(); // first attempt: empty fields, surfaces errors
      expect(cubit.state.showFieldErrors, isTrue);

      cubit.emailChanged('ahmed@example.com');

      expect(cubit.state.errors.email, isNull);
    });

    test('passwordVisibilityToggled flips isPasswordVisible', () {
      final cubit = _buildCubit(_FakeAuthRepository());
      addTearDown(cubit.close);

      cubit.passwordVisibilityToggled();

      expect(cubit.state.isPasswordVisible, isTrue);
    });
  });

  group('SignInCubit — concurrency', () {
    test(
      'a second submit while one is in flight does not fire a second request',
      () async {
        final repo = _FakeAuthRepository()..signInGate = Completer<void>();
        final cubit = _buildCubit(repo);
        addTearDown(cubit.close);

        cubit.emailChanged('ahmed@example.com');
        cubit.passwordChanged('secret1');

        final first = cubit.submit();
        await pumpEventQueue();
        expect(cubit.state.isSubmitting, isTrue);

        // The keyboard's "done" action reaches submit() even though the button
        // is disabled — the guard has to live in the cubit.
        await cubit.submit();

        expect(repo.signInCallCount, 1);

        repo.signInGate!.complete();
        await first;
        expect(cubit.state.status, isA<SignInSucceeded>());
      },
    );
  });

  group('SignInCubit — remembered-account prefill', () {
    test(
      'resolves isPrefillResolved even when nothing was remembered',
      () async {
        final cubit = _buildCubit(_FakeAuthRepository());
        addTearDown(cubit.close);
        expect(cubit.state.isPrefillResolved, isFalse);

        await cubit.loadRememberedAccount();

        // The view keys its one-time controller sync off this edge, so it must
        // flip regardless of what the lookup found.
        expect(cubit.state.isPrefillResolved, isTrue);
      },
    );

    test('does not overwrite an email the user already typed', () async {
      final repo = _FakeAuthRepository()
        ..loadGate = Completer<void>()
        ..rememberedAccount = const RememberedAccount(
          isRemembered: true,
          email: 'remembered@example.com',
        );
      final cubit = _buildCubit(repo);
      addTearDown(cubit.close);

      final loading = cubit.loadRememberedAccount();
      // Storage is slow; the user starts typing before it resolves.
      cubit.emailChanged('typed@example.com');
      repo.loadGate!.complete();
      await loading;

      expect(cubit.state.email, 'typed@example.com');
      expect(cubit.state.isPrefillResolved, isTrue);
    });
  });

  group('SignInCubit — email trimming', () {
    test('submits and persists the trimmed email', () async {
      final repo = _FakeAuthRepository();
      final cubit = _buildCubit(repo);
      addTearDown(cubit.close);

      cubit.emailChanged('  ahmed@example.com  ');
      cubit.passwordChanged('secret1');
      cubit.rememberMeToggled(true);

      await cubit.submit();

      expect(repo.lastSignInEmail, 'ahmed@example.com');
      expect(repo.lastSignInPassword, 'secret1');
      expect(repo.lastSavedEmail, 'ahmed@example.com');
      expect(cubit.state.status, isA<SignInSucceeded>());
    });

    test(
      'an email that is only whitespace is still rejected as empty',
      () async {
        final repo = _FakeAuthRepository();
        final cubit = _buildCubit(repo);
        addTearDown(cubit.close);

        cubit.emailChanged('   ');
        cubit.passwordChanged('secret1');

        await cubit.submit();

        expect(repo.signInCallCount, 0);
        expect(cubit.state.errors.email, EmailFieldError.empty);
      },
    );
  });
}
