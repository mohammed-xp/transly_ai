import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/di/service_locator.dart';
import 'package:transly_ai/core/domain/usecases/get_cached_user_use_case.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/core/theme/app_palette.dart';
import 'package:transly_ai/core/widgets/toast/app_toast_scope.dart';
import 'package:transly_ai/features/app_language/domain/entities/app_language.dart';
import 'package:transly_ai/features/app_language/domain/usecases/get_app_language_usecase.dart';
import 'package:transly_ai/features/app_language/domain/usecases/set_app_language_usecase.dart';
import 'package:transly_ai/features/app_language/presentation/cubit/app_language_cubit.dart';
import 'package:transly_ai/features/profile/domain/entities/plan_usage_entity.dart';
import 'package:transly_ai/features/profile/domain/usecases/get_plan_usage_usecase.dart';
import 'package:transly_ai/features/profile/presentation/cubit/plan_usage_cubit.dart';
import 'package:transly_ai/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:transly_ai/features/profile/presentation/screens/profile_screen.dart';
import 'package:transly_ai/l10n/app_localizations.dart';

import '../../../../helpers/fake_app_language_repo.dart';
import '../../../../helpers/fake_plan_usage_repo.dart';
import '../../../../helpers/fake_user_repo.dart';

void main() {
  late FakePlanUsageRepo usageRepo;
  late FakeAppLanguageRepo languageRepo;

  setUp(() {
    usageRepo = FakePlanUsageRepo(ApiResult.success(testFreeUsage));
    languageRepo = FakeAppLanguageRepo();
    serviceLocator
      ..registerFactory(
        () => ProfileCubit(
          getCachedUser: GetCachedUserUseCase(FakeUserRepo(testUser)),
        ),
      )
      ..registerFactory(
        () => PlanUsageCubit(getPlanUsage: GetPlanUsageUseCase(usageRepo)),
      );
  });

  tearDown(serviceLocator.reset);

  Future<void> pumpScreen(WidgetTester tester, Locale locale) async {
    tester.view.physicalSize = const Size(402, 874) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      BlocProvider(
        create: (_) => AppLanguageCubit(
          getLanguage: GetAppLanguageUseCase(languageRepo),
          setLanguage: SetAppLanguageUseCase(languageRepo),
        ),
        child: MaterialApp(
          theme: ThemeData(extensions: const [AppPalette.light]),
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => AppToastScope(child: child!),
          home: const ProfileScreen(),
        ),
      ),
    );
    // Resolves the plan-usage request.
    await tester.pump();
  }

  Future<void> dismissToast(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the cached user in the identity block and account rows', (
    tester,
  ) async {
    await pumpScreen(tester, const Locale('en'));

    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    expect(find.text('Ahmed Hassan'), findsNWidgets(2));
    expect(find.text('ahmed.hassan@gmail.com'), findsNWidgets(2));
    expect(find.text('Sign out'), findsOneWidget);
  });

  testWidgets('lays out in Arabic without overflowing', (tester) async {
    await pumpScreen(tester, const Locale('ar'));

    expect(find.text('الملف الشخصي'), findsOneWidget);
    expect(find.text('حذف الحساب'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('announces "coming soon" for actions without a backend', (
    tester,
  ) async {
    await pumpScreen(tester, const Locale('en'));

    await tester.tap(find.text('Edit'));
    await tester.pump();

    expect(find.text('Coming soon'), findsOneWidget);

    await dismissToast(tester);
  });

  testWidgets('shows today\'s usage on the free-plan card', (tester) async {
    await pumpScreen(tester, const Locale('en'));

    expect(find.text('Free plan'), findsOneWidget);
    expect(find.text('70%'), findsOneWidget);
    expect(find.text("Today's usage"), findsOneWidget);
    expect(find.text('30% left'), findsOneWidget);
    expect(find.text('Upgrade to Pro'), findsOneWidget);
  });

  testWidgets('writes the usage in Arabic-Indic digits in Arabic', (
    tester,
  ) async {
    await pumpScreen(tester, const Locale('ar'));

    expect(find.text('الخطة المجانية'), findsOneWidget);
    expect(find.text('٧٠٪'), findsOneWidget);
    expect(find.text('متبقٍ ٣٠٪'), findsOneWidget);
  });

  testWidgets('upgrade announces "coming soon" until the paywall exists', (
    tester,
  ) async {
    await pumpScreen(tester, const Locale('en'));

    await tester.tap(find.text('Upgrade to Pro'));
    await tester.pump();

    expect(find.text('Coming soon'), findsOneWidget);

    await dismissToast(tester);
  });

  testWidgets('hides the plan card for a paid plan', (tester) async {
    usageRepo.result = ApiResult.success(
      PlanUsageEntity(
        plan: 'pro_monthly',
        charactersLimit: 300000,
        charactersUsed: 1200,
        resetsAt: DateTime.utc(2026, 10, 26),
      ),
    );

    await pumpScreen(tester, const Locale('en'));

    expect(find.text('Free plan'), findsNothing);
    expect(find.text('Upgrade to Pro'), findsNothing);
    expect(find.text('Account'), findsOneWidget);
  });

  testWidgets('shows the failure with a retry action when usage fails', (
    tester,
  ) async {
    usageRepo.result = const ApiResult.failure(NetworkFailure());

    await pumpScreen(tester, const Locale('en'));

    expect(
      find.text('No internet connection. Check your network and try again.'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('Free plan'), findsNothing);
  });

  testWidgets('retry reloads the usage', (tester) async {
    usageRepo.result = const ApiResult.failure(NetworkFailure());
    await pumpScreen(tester, const Locale('en'));

    usageRepo.result = ApiResult.success(testFreeUsage);
    await tester.tap(find.text('Retry'));
    await tester.pump();

    expect(usageRepo.calls, 2);
    expect(find.text('Free plan'), findsOneWidget);
    expect(find.text('Retry'), findsNothing);
  });

  testWidgets('the app-language row shows the device language by default', (
    tester,
  ) async {
    await pumpScreen(tester, const Locale('en'));

    expect(find.text('App language'), findsOneWidget);
    expect(find.text('Device language'), findsOneWidget);
  });

  testWidgets('the sheet marks the current language and the device default', (
    tester,
  ) async {
    await pumpScreen(tester, const Locale('en'));

    await tester.tap(find.text('App language'));
    await tester.pumpAndSettle();

    expect(find.text('All languages'), findsOneWidget);
    expect(find.text('Automatic · English'), findsOneWidget);
    expect(find.text('العربية'), findsOneWidget);
    expect(find.text('Arabic'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('picking a language and saving applies it', (tester) async {
    await pumpScreen(tester, const Locale('en'));

    await tester.tap(find.text('App language'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('العربية'));
    await tester.pump();

    expect(languageRepo.saveCalls, 0);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(languageRepo.saved, const AppLanguage('ar'));
    expect(find.text('العربية'), findsOneWidget);
    expect(find.text('Device language'), findsNothing);
  });

  testWidgets('closing the sheet discards the picked language', (tester) async {
    await pumpScreen(tester, const Locale('en'));

    await tester.tap(find.text('App language'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    expect(languageRepo.saveCalls, 0);
    expect(find.text('Device language'), findsOneWidget);
  });

  testWidgets('lays out the sheet in Arabic without overflowing', (
    tester,
  ) async {
    await pumpScreen(tester, const Locale('ar'));

    await tester.tap(find.text('لغة التطبيق'));
    await tester.pumpAndSettle();

    expect(find.text('كل اللغات'), findsOneWidget);
    expect(find.text('الإنجليزية'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows an error toast when the language cannot be saved', (
    tester,
  ) async {
    languageRepo.saveResult = const ApiResult.failure(UnknownFailure());
    await pumpScreen(tester, const Locale('en'));

    await tester.tap(find.text('App language'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(
      find.text("Couldn't change the language. Please try again."),
      findsOneWidget,
    );
    expect(find.text('Device language'), findsOneWidget);
  });
}
