import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:transly_ai/core/router/app_routes.dart';
import 'package:transly_ai/core/theme/app_theme.dart';
import 'package:transly_ai/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:transly_ai/l10n/app_localizations.dart';

/// Minimal harness: the onboarding route plus a Translate stub, driven by the
/// given [locale]/[themeMode] so we can assert per-locale copy, RTL behavior,
/// and both theme variants.
Widget _harness(Locale locale, {ThemeMode themeMode = ThemeMode.light}) {
  final router = GoRouter(
    initialLocation: AppRoutes.onboarding,
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        name: AppRoutes.onboardingName,
        builder: (context, state) => const OnboardingScreen(),
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

/// Sets a physical surface size for the test window and restores it after.
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

void main() {
  group('OnboardingScreen', () {
    testWidgets('renders localized copy in English', (tester) async {
      await tester.pumpWidget(_harness(const Locale('en')));
      await tester.pumpAndSettle();

      final en = lookupAppLocalizations(const Locale('en'));
      expect(find.text(en.onboardingGetStarted), findsOneWidget);
      expect(find.text(en.onboardingCaption), findsOneWidget);
      expect(find.text(en.onboardingSignIn), findsOneWidget);
      expect(find.text('English'), findsOneWidget); // a language chip
    });

    testWidgets('renders Arabic copy with RTL directionality', (tester) async {
      await tester.pumpWidget(_harness(const Locale('ar')));
      await tester.pumpAndSettle();

      final ar = lookupAppLocalizations(const Locale('ar'));
      expect(find.text(ar.onboardingGetStarted), findsOneWidget);
      expect(find.text(ar.onboardingSignIn), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.byType(OnboardingScreen))),
        TextDirection.rtl,
      );
    });

    testWidgets('Get Started navigates to Translate', (tester) async {
      await tester.pumpWidget(_harness(const Locale('en')));
      await tester.pumpAndSettle();

      final en = lookupAppLocalizations(const Locale('en'));
      await tester.tap(find.text(en.onboardingGetStarted));
      await tester.pumpAndSettle();

      expect(find.text('translate-stub'), findsOneWidget);
    });

    testWidgets('renders in dark theme without errors', (tester) async {
      await tester.pumpWidget(
        _harness(const Locale('en'), themeMode: ThemeMode.dark),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final en = lookupAppLocalizations(const Locale('en'));
      expect(find.text(en.onboardingGetStarted), findsOneWidget);
    });

    // The hero uses a Spacer between the chips and the anchored content group;
    // this guards against vertical overflow on real phone sizes (and the short
    // end of the range) in both themes.
    for (final size in const [Size(402, 874), Size(360, 640)]) {
      for (final mode in const [ThemeMode.light, ThemeMode.dark]) {
        testWidgets('lays out without overflow at $size ($mode)',
            (tester) async {
          await _withSurface(tester, size, () async {
            await tester.pumpWidget(
              _harness(const Locale('ar'), themeMode: mode),
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
          });
        });
      }
    }
  });
}
