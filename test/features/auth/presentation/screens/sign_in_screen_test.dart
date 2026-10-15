import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:transly_ai/core/di/service_locator.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/core/router/app_routes.dart';
import 'package:transly_ai/core/session/session_manager.dart';
import 'package:transly_ai/core/theme/app_palette.dart';
import 'package:transly_ai/core/widgets/toast/app_toast_scope.dart';
import 'package:transly_ai/features/auth/domain/usecases/sign_in_with_email_usecase.dart';
import 'package:transly_ai/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:transly_ai/features/auth/domain/usecases/validate_sign_in_form_usecase.dart';
import 'package:transly_ai/features/auth/presentation/cubit/google_sign_in_cubit.dart';
import 'package:transly_ai/features/auth/presentation/cubit/sign_in_cubit.dart';
import 'package:transly_ai/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:transly_ai/l10n/app_localizations.dart';

import '../../../../helpers/fake_auth_repo.dart';
import '../../../../helpers/fake_logout_repo.dart';

void main() {
  setUp(() {
    final repo = FakeAuthRepo(const ApiResult.success(null));
    final session = SessionManager(FakeLogoutRepo());
    serviceLocator.registerFactory(
      () => SignInCubit(
        signIn: SignInWithEmailUseCase(repo, session),
        validate: const ValidateSignInFormUseCase(),
      ),
    );
    // The social row on this screen owns a Google sign-in cubit.
    serviceLocator.registerFactory(
      () => GoogleSignInCubit(SignInWithGoogleUseCase(repo, session)),
    );
  });

  tearDown(serviceLocator.reset);

  Future<void> pumpScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(402, 874) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: AppRoutes.signIn,
      routes: [
        GoRoute(
          path: AppRoutes.signIn,
          name: AppRoutes.signInName,
          builder: (_, _) => const SignInScreen(),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        theme: ThemeData(extensions: const [AppPalette.light]),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
        builder: (context, child) => AppToastScope(child: child!),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('keyboard next moves from the email to the password field', (
    tester,
  ) async {
    await pumpScreen(tester);
    await tester.tap(find.byType(TextField).at(0));
    await tester.pump();

    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();

    final password = tester.widget<TextField>(find.byType(TextField).at(1));
    expect(password.focusNode!.hasFocus, isTrue);
  });
}
