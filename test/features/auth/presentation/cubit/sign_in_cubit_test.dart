import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/core/session/session_manager.dart';
import 'package:transly_ai/features/auth/domain/entities/sign_in_form_errors.dart';
import 'package:transly_ai/features/auth/domain/usecases/sign_in_with_email_usecase.dart';
import 'package:transly_ai/features/auth/domain/usecases/validate_sign_in_form_usecase.dart';
import 'package:transly_ai/features/auth/presentation/cubit/sign_in_cubit.dart';
import 'package:transly_ai/features/auth/presentation/cubit/sign_in_state.dart';

import '../../../../helpers/fake_auth_repo.dart';
import '../../../../helpers/fake_logout_repo.dart';

void main() {
  SignInCubit buildCubit(FakeAuthRepo repo) => SignInCubit(
    signIn: SignInWithEmailUseCase(repo, SessionManager(FakeLogoutRepo())),
    validate: const ValidateSignInFormUseCase(),
  );

  void fillValidForm(SignInCubit cubit) {
    cubit
      ..emailChanged(' ahmed@example.com ')
      ..passwordChanged(' secret123 ');
  }

  Future<List<SignInStatus>> statusesOf(
    SignInCubit cubit,
    Future<void> Function() action,
  ) async {
    final statuses = <SignInStatus>[];
    final subscription = cubit.stream
        .map((state) => state.status)
        .distinct()
        .listen(statuses.add);
    await action();
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();
    return statuses;
  }

  test('starts empty, idle, with the password hidden and no errors shown', () {
    final cubit = buildCubit(FakeAuthRepo(const ApiResult.success(null)));
    addTearDown(cubit.close);

    expect(cubit.state.email, isEmpty);
    expect(cubit.state.password, isEmpty);
    expect(cubit.state.status, isA<SignInInitial>());
    expect(cubit.state.isPasswordVisible, isFalse);
    expect(cubit.state.showFieldErrors, isFalse);
  });

  test(
    'does not call the repo and shows the errors when the form is invalid',
    () async {
      final repo = FakeAuthRepo(const ApiResult.success(null));
      final cubit = buildCubit(repo);
      addTearDown(cubit.close);

      await cubit.submit();

      expect(repo.emailSignIns, isEmpty);
      expect(cubit.state.showFieldErrors, isTrue);
      expect(cubit.state.errors.email, EmailFieldError.empty);
      expect(cubit.state.errors.password, PasswordFieldError.empty);
    },
  );

  test('does not show errors while typing before the first submit', () {
    final cubit = buildCubit(FakeAuthRepo(const ApiResult.success(null)));
    addTearDown(cubit.close);

    cubit
      ..emailChanged('not-an-email')
      ..passwordChanged('123');

    expect(cubit.state.showFieldErrors, isFalse);
    expect(cubit.state.errors.isValid, isTrue);
  });

  test('re-validates as the user types after a failed submit', () async {
    final cubit = buildCubit(FakeAuthRepo(const ApiResult.success(null)));
    addTearDown(cubit.close);
    cubit
      ..emailChanged('not-an-email')
      ..passwordChanged('secret123');
    await cubit.submit();
    expect(cubit.state.errors.email, EmailFieldError.invalidFormat);

    cubit.emailChanged('ahmed@example.com');

    expect(cubit.state.errors.email, isNull);
  });

  test('emits Submitting then Succeeded, sending the trimmed email and the '
      'untrimmed password', () async {
    final repo = FakeAuthRepo(const ApiResult.success(null));
    final cubit = buildCubit(repo);
    addTearDown(cubit.close);
    fillValidForm(cubit);

    final statuses = await statusesOf(cubit, cubit.submit);

    expect(statuses, [isA<SignInSubmitting>(), isA<SignInSucceeded>()]);
    final signIn = repo.emailSignIns.single;
    expect(signIn.email, 'ahmed@example.com');
    expect(signIn.password, ' secret123 ');
  });

  test('emits Submitting then Failed with the failure', () async {
    final cubit = buildCubit(
      FakeAuthRepo(
        const ApiResult.success(null),
        emailResult: const ApiResult.failure(UnauthorizedFailure()),
      ),
    );
    addTearDown(cubit.close);
    fillValidForm(cubit);

    final statuses = await statusesOf(cubit, cubit.submit);

    expect(statuses, [isA<SignInSubmitting>(), isA<SignInFailed>()]);
    expect((statuses.last as SignInFailed).failure, isA<UnauthorizedFailure>());
  });

  test('ignores a second submit while one is in flight', () async {
    final repo = FakeAuthRepo(const ApiResult.success(null))
      ..gate = Completer<void>();
    final cubit = buildCubit(repo);
    addTearDown(cubit.close);
    fillValidForm(cubit);

    final first = cubit.submit();
    final second = cubit.submit();
    repo.gate!.complete();
    await Future.wait([first, second]);

    expect(repo.emailSignIns, hasLength(1));
  });

  test('does not emit once closed while a sign-in is in flight', () async {
    final repo = FakeAuthRepo(const ApiResult.success(null))
      ..gate = Completer<void>();
    final cubit = buildCubit(repo);
    fillValidForm(cubit);

    final submission = cubit.submit();
    final closing = cubit.close();
    repo.gate!.complete();

    await expectLater(submission, completes);
    await closing;
    expect(cubit.state.status, isA<SignInSubmitting>());
  });

  test('passwordVisibilityToggled flips the password visibility', () {
    final cubit = buildCubit(FakeAuthRepo(const ApiResult.success(null)));
    addTearDown(cubit.close);

    cubit.passwordVisibilityToggled();
    expect(cubit.state.isPasswordVisible, isTrue);

    cubit.passwordVisibilityToggled();
    expect(cubit.state.isPasswordVisible, isFalse);
  });
}
