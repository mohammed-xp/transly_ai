import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:transly_ai/core/di/injection.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/core/router/app_routes.dart';
import 'package:transly_ai/core/theme/app_theme.dart';
import 'package:transly_ai/features/auth/data/models/user_model.dart';
import 'package:transly_ai/features/auth/domain/entities/user_entity.dart';
import 'package:transly_ai/features/auth/domain/entities/remembered_account.dart';
import 'package:transly_ai/features/auth/domain/repos/auth_repository.dart';
import 'package:transly_ai/features/auth/domain/usecases/load_remembered_account_usecase.dart';
import 'package:transly_ai/features/auth/domain/usecases/save_remembered_account_usecase.dart';
import 'package:transly_ai/features/auth/domain/usecases/sign_in_with_email_usecase.dart';
import 'package:transly_ai/features/auth/domain/usecases/validate_sign_in_form_usecase.dart';
import 'package:transly_ai/features/auth/presentation/cubit/sign_in_cubit.dart';
import 'package:transly_ai/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:transly_ai/l10n/app_localizations.dart';

/// In-memory repository; real use cases wrap it so the screen is driven
/// through its real cubit (no mocking framework), matching the convention in
/// `sign_in_cubit_test.dart`.
class _FakeAuthRepository implements AuthRepository {
  Failure? signInFailure;
  RememberedAccount rememberedAccount = RememberedAccount.none();

  @override
  Future<ApiResult<UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final failure = signInFailure;
    if (failure != null) return ApiResult.failure(failure);
    return ApiResult.success( UserModel(
      id: 'uid-1',
      email: 'ahmed@example.com',
      username: 'ahmed',
      createdAt: DateTime.utc(2023),
    ).toEntity());
  }

  @override
  Future<ApiResult<RememberedAccount>> loadRememberedAccount() async =>
      ApiResult.success(rememberedAccount);

  @override
  Future<ApiResult<void>> saveRememberedAccount({
    required bool remember,
    required String email,
  }) async => const ApiResult.success(null);

  @override
  Stream<void> watchSessionExpired() => const Stream.empty();

  @override
  Future<ApiResult<bool>> hasActiveSession() => throw UnimplementedError();

  @override
  Future<ApiResult<void>> signOut() => throw UnimplementedError();
}

/// `SignInScreen` resolves its cubit from `get_it`, so the fake is wired in
/// there rather than by swapping the widget out.
void _registerCubit(_FakeAuthRepository repo) {
  sl.registerFactory(
    () => SignInCubit(
      signIn: SignInWithEmailUseCase(repo),
      validate: const ValidateSignInFormUseCase(),
      loadRemembered: LoadRememberedAccountUseCase(repo),
      saveRemembered: SaveRememberedAccountUseCase(repo),
    ),
  );
}

Widget _harness({
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
}) {
  final router = GoRouter(
    initialLocation: AppRoutes.signIn,
    routes: [
      GoRoute(
        path: AppRoutes.signIn,
        name: AppRoutes.signInName,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: AppRoutes.translate,
        name: AppRoutes.translateName,
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('translate-stub'))),
      ),
    ],
  );

  return MaterialApp.router(
    routerConfig: router,
    locale: locale,
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: themeMode,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
  );
}

Future<void> _withSurface(
  WidgetTester tester,
  Size size,
  Future<void> Function() body,
) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await body();
}

/// The screen renders exactly two text fields, in visual order.
Finder get _emailField => find.byType(TextField).at(0);
Finder get _passwordField => find.byType(TextField).at(1);

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final ar = lookupAppLocalizations(const Locale('ar'));

  tearDown(sl.reset);

  group('SignInScreen', () {
    testWidgets('renders localized copy in English', (tester) async {
      _registerCubit(_FakeAuthRepository());
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      expect(find.text(en.signInTitle), findsOneWidget);
      expect(find.text(en.signInSubtitle), findsOneWidget);
      expect(find.text(en.signInSubmit), findsOneWidget);
      expect(find.text(en.signInRememberMe), findsOneWidget);
      expect(find.text(en.signInForgotPassword), findsOneWidget);
      expect(find.text(en.signInOrContinueWith), findsOneWidget);
      expect(find.text(en.signInCreateAccount), findsOneWidget);
    });

    testWidgets('renders Arabic copy with RTL directionality', (tester) async {
      _registerCubit(_FakeAuthRepository());
      await tester.pumpWidget(_harness(locale: const Locale('ar')));
      await tester.pumpAndSettle();

      expect(find.text(ar.signInTitle), findsOneWidget);
      expect(find.text(ar.signInSubmit), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.text(ar.signInTitle))),
        TextDirection.rtl,
      );
    });

    testWidgets(
      'submitting an empty form shows field errors and does not navigate',
      (tester) async {
        _registerCubit(_FakeAuthRepository());
        await tester.pumpWidget(_harness());
        await tester.pumpAndSettle();

        await tester.tap(find.text(en.signInSubmit));
        await tester.pumpAndSettle();

        expect(find.text(en.authErrorEmailRequired), findsOneWidget);
        expect(find.text(en.authErrorPasswordRequired), findsOneWidget);
        expect(find.text('translate-stub'), findsNothing);
      },
    );

    testWidgets('a valid sign-in navigates on to Translate', (tester) async {
      _registerCubit(_FakeAuthRepository());
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      await tester.enterText(_emailField, 'ahmed@example.com');
      await tester.enterText(_passwordField, 'secret1');
      await tester.tap(find.text(en.signInSubmit));
      await tester.pumpAndSettle();

      expect(find.text('translate-stub'), findsOneWidget);
    });

    testWidgets('a failed sign-in surfaces the mapped message and stays put', (
      tester,
    ) async {
      _registerCubit(
        _FakeAuthRepository()
          ..signInFailure = const AuthFailure(
            AuthFailureReason.invalidCredentials,
          ),
      );
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      await tester.enterText(_emailField, 'ahmed@example.com');
      await tester.enterText(_passwordField, 'wrong-pass');
      await tester.tap(find.text(en.signInSubmit));
      await tester.pump(); // let the SnackBar appear
      await tester.pump();

      expect(find.text(en.authErrorInvalidCredentials), findsOneWidget);
      expect(find.text('translate-stub'), findsNothing);
    });

    // The app-wide inputDecorationTheme sets filled + enabledBorder/
    // focusedBorder. AuthTextField paints its own fill, border and focus ring
    // on the container around the field, so the themed decoration must be
    // fully neutralised — otherwise the theme's outline is drawn inside the
    // container's and the edge reads as doubled/embossed.
    testWidgets('the field paints no decoration of its own', (tester) async {
      _registerCubit(_FakeAuthRepository());
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      for (final finder in [_emailField, _passwordField]) {
        final decoration = tester.widget<TextField>(finder).decoration!;
        expect(decoration.filled, isFalse);
        expect(decoration.border, InputBorder.none);
        expect(decoration.enabledBorder, InputBorder.none);
        expect(decoration.focusedBorder, InputBorder.none);
        expect(decoration.errorBorder, InputBorder.none);
        expect(decoration.focusedErrorBorder, InputBorder.none);
      }
    });

    testWidgets('a remembered account prefills the email field', (
      tester,
    ) async {
      _registerCubit(
        _FakeAuthRepository()
          ..rememberedAccount = const RememberedAccount(
            isRemembered: true,
            email: 'remembered@example.com',
          ),
      );
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      expect(
        tester.widget<TextField>(_emailField).controller!.text,
        'remembered@example.com',
      );
    });

    // The screen stacks a Spacer inside IntrinsicHeight inside a scroll view,
    // and the remember-me row puts two labels in one spaceBetween Row — both
    // are overflow-prone, so they are pinned at real phone sizes, both themes,
    // both locales, and with the keyboard open. English is covered as well as
    // Arabic because the test font is monospaced-square, which makes Latin
    // copy the wider of the two and the stricter constraint on that Row.
    for (final size in const [Size(402, 874), Size(360, 640), Size(320, 568)]) {
      for (final mode in const [ThemeMode.light, ThemeMode.dark]) {
        for (final locale in const [Locale('ar'), Locale('en')]) {
          testWidgets(
            'lays out without overflow at $size ($mode, ${locale.languageCode})',
            (tester) async {
              await _withSurface(tester, size, () async {
                _registerCubit(_FakeAuthRepository());
                await tester.pumpWidget(
                  _harness(locale: locale, themeMode: mode),
                );
                await tester.pumpAndSettle();

                expect(tester.takeException(), isNull);
              });
            },
          );
        }
      }
    }

    testWidgets('the remember-me row survives a large text scale', (
      tester,
    ) async {
      await _withSurface(tester, const Size(320, 568), () async {
        _registerCubit(_FakeAuthRepository());
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.6)),
            child: _harness(),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
    });

    testWidgets('lays out without overflow while the keyboard is open', (
      tester,
    ) async {
      await _withSurface(tester, const Size(360, 640), () async {
        tester.view.viewInsets = const FakeViewPadding(bottom: 320);
        addTearDown(tester.view.resetViewInsets);

        _registerCubit(_FakeAuthRepository());
        await tester.pumpWidget(_harness());
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
    });
  });
}
