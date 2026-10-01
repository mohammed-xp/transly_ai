import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:transly_ai/core/di/service_locator.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/core/router/app_routes.dart';
import 'package:transly_ai/core/theme/app_palette.dart';
import 'package:transly_ai/core/widgets/gradient_button.dart';
import 'package:transly_ai/core/widgets/toast/app_toast_scope.dart';
import 'package:transly_ai/features/auth/domain/usecases/evaluate_password_strength_usecase.dart';
import 'package:transly_ai/features/auth/domain/usecases/sign_up_with_email_usecase.dart';
import 'package:transly_ai/features/auth/domain/usecases/validate_sign_up_form_usecase.dart';
import 'package:transly_ai/features/auth/presentation/cubit/sign_up_cubit.dart';
import 'package:transly_ai/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:transly_ai/features/auth/presentation/widgets/terms_agreement.dart';
import 'package:transly_ai/l10n/app_localizations.dart';

import '../../../../helpers/fake_auth_repo.dart';

void main() {
  late FakeAuthRepo repo;

  setUp(() {
    repo = FakeAuthRepo(const ApiResult.success(null));
    serviceLocator.registerFactory(
      () => SignUpCubit(
        signUp: SignUpWithEmailUseCase(repo),
        validate: const ValidateSignUpFormUseCase(),
        evaluatePasswordStrength: const EvaluatePasswordStrengthUseCase(),
      ),
    );
  });

  tearDown(serviceLocator.reset);

  Future<void> pumpScreen(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    AppPalette palette = AppPalette.light,
  }) async {
    tester.view.physicalSize = const Size(402, 874) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: AppRoutes.signUp,
      routes: [
        GoRoute(
          path: AppRoutes.signUp,
          name: AppRoutes.signUpName,
          builder: (_, _) => const SignUpScreen(),
        ),
        GoRoute(
          path: AppRoutes.signIn,
          name: AppRoutes.signInName,
          builder: (_, _) => const Scaffold(body: Text('sign-in-page')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        theme: ThemeData(
          brightness: palette == AppPalette.light
              ? Brightness.light
              : Brightness.dark,
          extensions: [palette],
        ),
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
        builder: (context, child) => AppToastScope(child: child!),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> fillValidForm(WidgetTester tester) async {
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Ahmed Salem');
    await tester.enterText(fields.at(1), 'ahmed@example.com');
    await tester.enterText(fields.at(2), 'secret123');
    await tester.tap(find.byType(TermsAgreement));
    await tester.pump();
  }

  Future<void> submit(WidgetTester tester) async {
    await tester.ensureVisible(find.byType(GradientButton));
    await tester.tap(find.byType(GradientButton));
    await tester.pump();
    await tester.pump();
  }

  testWidgets('lays out in English without overflowing', (tester) async {
    await pumpScreen(tester);

    expect(find.text('Create your account'), findsOneWidget);
    expect(find.text('Already have an account?'), findsOneWidget);
  });

  testWidgets('lays out in Arabic dark mode without overflowing', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      locale: const Locale('ar'),
      palette: AppPalette.dark,
    );

    expect(find.text('أنشئ حسابك'), findsOneWidget);
  });

  testWidgets('shows field and terms errors when submitted empty', (
    tester,
  ) async {
    await pumpScreen(tester);

    await submit(tester);

    expect(find.text('Enter your name.'), findsOneWidget);
    expect(find.text('Enter your email address.'), findsOneWidget);
    expect(find.text('Enter your password.'), findsOneWidget);
    expect(
      find.text('Please accept the Terms of Service and Privacy Policy.'),
      findsOneWidget,
    );
    expect(repo.signUps, isEmpty);
  });

  testWidgets('shows the strength meter once a password is typed', (
    tester,
  ) async {
    await pumpScreen(tester);
    expect(find.text('Strong'), findsNothing);

    await tester.enterText(find.byType(TextField).at(2), 'Password1');
    await tester.pump();

    expect(find.text('Strong'), findsOneWidget);
  });

  testWidgets('goes to sign-in with a confirmation after signing up', (
    tester,
  ) async {
    await pumpScreen(tester);
    await fillValidForm(tester);

    await submit(tester);
    // Long enough for the route transition, short of the toast's 3s timeout.
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('sign-in-page'), findsOneWidget);
    expect(find.text('Account created. Sign in to continue.'), findsOneWidget);

    await tester.pumpAndSettle();
  });

  testWidgets('shows a taken-email toast on a 409', (tester) async {
    repo.signUpResult = const ApiResult.failure(ClientFailure(statusCode: 409));
    await pumpScreen(tester);
    await fillValidForm(tester);

    await submit(tester);

    expect(
      find.text('An account with this email already exists.'),
      findsOneWidget,
    );
    expect(find.text('sign-in-page'), findsNothing);
  });
}
