import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/features/auth/domain/entities/password_strength.dart';
import 'package:transly_ai/features/auth/domain/entities/sign_up_form_errors.dart';
import 'package:transly_ai/features/auth/domain/usecases/evaluate_password_strength_usecase.dart';
import 'package:transly_ai/features/auth/domain/usecases/sign_up_with_email_usecase.dart';
import 'package:transly_ai/features/auth/domain/usecases/validate_sign_up_form_usecase.dart';
import 'package:transly_ai/features/auth/presentation/cubit/sign_up_cubit.dart';
import 'package:transly_ai/features/auth/presentation/cubit/sign_up_state.dart';

import '../../../../helpers/fake_auth_repo.dart';

void main() {
  SignUpCubit buildCubit(FakeAuthRepo repo) => SignUpCubit(
    signUp: SignUpWithEmailUseCase(repo),
    validate: const ValidateSignUpFormUseCase(),
    evaluatePasswordStrength: const EvaluatePasswordStrengthUseCase(),
  );

  void fillValidForm(SignUpCubit cubit) {
    cubit
      ..nameChanged(' Ahmed Salem ')
      ..emailChanged(' ahmed@example.com ')
      ..passwordChanged('secret123')
      ..termsToggled();
  }

  Future<List<SignUpStatus>> statusesOf(
    SignUpCubit cubit,
    Future<void> Function() action,
  ) async {
    final statuses = <SignUpStatus>[];
    final subscription = cubit.stream
        .map((state) => state.status)
        .distinct()
        .listen(statuses.add);
    await action();
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();
    return statuses;
  }

  test('starts empty, with terms unaccepted and no strength', () {
    final cubit = buildCubit(FakeAuthRepo(const ApiResult.success(null)));
    addTearDown(cubit.close);

    expect(cubit.state.status, isA<SignUpInitial>());
    expect(cubit.state.termsAccepted, isFalse);
    expect(cubit.state.passwordStrength, isNull);
  });

  test('does not call the repo when the form is invalid', () async {
    final repo = FakeAuthRepo(const ApiResult.success(null));
    final cubit = buildCubit(repo);
    addTearDown(cubit.close);

    await cubit.submit();

    expect(repo.signUps, isEmpty);
    expect(cubit.state.showFieldErrors, isTrue);
    expect(cubit.state.errors.name, NameFieldError.empty);
  });

  test('blocks submission until the terms are accepted', () async {
    final repo = FakeAuthRepo(const ApiResult.success(null));
    final cubit = buildCubit(repo);
    addTearDown(cubit.close);
    cubit
      ..nameChanged('Ahmed Salem')
      ..emailChanged('ahmed@example.com')
      ..passwordChanged('secret123');

    await cubit.submit();

    expect(repo.signUps, isEmpty);
    expect(cubit.state.errors.termsNotAccepted, isTrue);
  });

  test('clears the terms error once accepted after a submit', () async {
    final cubit = buildCubit(FakeAuthRepo(const ApiResult.success(null)));
    addTearDown(cubit.close);
    await cubit.submit();

    cubit.termsToggled();

    expect(cubit.state.errors.termsNotAccepted, isFalse);
  });

  test('emits Submitting then Succeeded and sends trimmed values', () async {
    final repo = FakeAuthRepo(const ApiResult.success(null));
    final cubit = buildCubit(repo);
    addTearDown(cubit.close);
    fillValidForm(cubit);

    final statuses = await statusesOf(cubit, cubit.submit);

    expect(statuses, [isA<SignUpSubmitting>(), isA<SignUpSucceeded>()]);
    final signUp = repo.signUps.single;
    expect(signUp.name, 'Ahmed Salem');
    expect(signUp.email, 'ahmed@example.com');
    expect(signUp.password, 'secret123');
  });

  test('emits Submitting then Failed with the failure', () async {
    final cubit = buildCubit(
      FakeAuthRepo(const ApiResult.failure(ClientFailure(statusCode: 409))),
    );
    addTearDown(cubit.close);
    fillValidForm(cubit);

    final statuses = await statusesOf(cubit, cubit.submit);

    expect(statuses, [isA<SignUpSubmitting>(), isA<SignUpFailed>()]);
    expect(
      (statuses.last as SignUpFailed).failure,
      isA<ClientFailure>().having((f) => f.statusCode, 'statusCode', 409),
    );
  });

  test('updates the password strength as the password changes', () {
    final cubit = buildCubit(FakeAuthRepo(const ApiResult.success(null)));
    addTearDown(cubit.close);

    cubit.passwordChanged('Password1!long');
    expect(cubit.state.passwordStrength, PasswordStrength.veryStrong);

    cubit.passwordChanged('');
    expect(cubit.state.passwordStrength, isNull);
  });

  test('ignores a second submit while one is in flight', () async {
    final repo = FakeAuthRepo(const ApiResult.success(null))
      ..gate = Completer<void>();
    final cubit = buildCubit(repo);
    addTearDown(cubit.close);
    fillValidForm(cubit);

    final first = cubit.submit();
    await cubit.submit();
    repo.gate!.complete();
    await first;

    expect(repo.signUps, hasLength(1));
  });

  test('does not emit once closed while a sign-up is in flight', () async {
    final repo = FakeAuthRepo(const ApiResult.success(null))
      ..gate = Completer<void>();
    final cubit = buildCubit(repo);
    fillValidForm(cubit);

    final submission = cubit.submit();
    final closing = cubit.close();
    repo.gate!.complete();

    await expectLater(submission, completes);
    await closing;
  });
}
