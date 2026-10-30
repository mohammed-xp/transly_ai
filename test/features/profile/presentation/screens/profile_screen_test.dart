import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderParagraph;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/di/service_locator.dart';
import 'package:transly_ai/core/domain/entities/sign_in_method.dart';
import 'package:transly_ai/core/domain/usecases/get_cached_user_use_case.dart';
import 'package:transly_ai/core/domain/usecases/get_sign_in_method_use_case.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/core/theme/app_palette.dart';
import 'package:transly_ai/core/widgets/sheet_close_button.dart';
import 'package:transly_ai/core/widgets/toast/app_toast_scope.dart';
import 'package:transly_ai/features/app_language/domain/entities/app_language.dart';
import 'package:transly_ai/features/app_language/domain/usecases/get_app_language_usecase.dart';
import 'package:transly_ai/features/app_language/domain/usecases/set_app_language_usecase.dart';
import 'package:transly_ai/features/app_language/presentation/cubit/app_language_cubit.dart';
import 'package:transly_ai/features/app_theme/domain/entities/app_theme_mode.dart';
import 'package:transly_ai/features/app_theme/domain/usecases/get_app_theme_mode_usecase.dart';
import 'package:transly_ai/features/app_theme/domain/usecases/set_app_theme_mode_usecase.dart';
import 'package:transly_ai/features/app_theme/presentation/cubit/app_theme_cubit.dart';
import 'package:transly_ai/features/language_picker/domain/entities/offline_model_status.dart';
import 'package:transly_ai/features/profile/domain/entities/plan_usage_entity.dart';
import 'package:transly_ai/features/profile/domain/usecases/get_plan_usage_usecase.dart';
import 'package:transly_ai/features/profile/presentation/cubit/plan_usage_cubit.dart';
import 'package:transly_ai/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:transly_ai/features/profile/presentation/screens/profile_screen.dart';
import 'package:transly_ai/l10n/app_localizations.dart';

import '../../../../helpers/fake_app_language_repo.dart';
import '../../../../helpers/fake_app_theme_repo.dart';
import '../../../../helpers/fake_languages_repo.dart';
import '../../../../helpers/fake_offline_models_repo.dart';
import '../../../../helpers/fake_plan_usage_repo.dart';
import '../../../../helpers/fake_user_repo.dart';
import '../../../../helpers/offline_packs_cubit_factory.dart';
import '../../../../helpers/session_cubit_factory.dart';

void main() {
  late FakePlanUsageRepo usageRepo;
  late FakeAppLanguageRepo languageRepo;
  late FakeAppThemeRepo themeRepo;
  late SignInMethod signInMethod;
  late FakeOfflineModelsRepo modelsRepo;

  setUp(() {
    usageRepo = FakePlanUsageRepo(
      ApiResult.success(testFreeUsageWithConversation),
    );
    languageRepo = FakeAppLanguageRepo();
    themeRepo = FakeAppThemeRepo();
    signInMethod = SignInMethod.email;
    modelsRepo = FakeOfflineModelsRepo(
      statuses: {
        'en': const OfflineModelBuiltIn(),
        'de': const OfflineModelDownloaded(),
        'fr': const OfflineModelNotDownloaded(),
      },
    );
    serviceLocator
      ..registerFactory(() {
        final userRepo = FakeUserRepo(testUser, signInMethod);
        return ProfileCubit(
          getCachedUser: GetCachedUserUseCase(userRepo),
          getSignInMethod: GetSignInMethodUseCase(userRepo),
        );
      })
      ..registerFactory(
        () => PlanUsageCubit(getPlanUsage: GetPlanUsageUseCase(usageRepo)),
      )
      ..registerFactory(
        () => buildOfflinePacksCubit(
          languages: FakeLanguagesRepo(cached: testLanguages),
          models: modelsRepo,
        ),
      );
  });

  tearDown(serviceLocator.reset);

  Future<void> pumpScreen(
    WidgetTester tester,
    Locale locale, {
    double width = 402,
  }) async {
    tester.view.physicalSize = Size(width, 874) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => buildSessionCubit()),
          BlocProvider(
            create: (_) => AppLanguageCubit(
              getLanguage: GetAppLanguageUseCase(languageRepo),
              setLanguage: SetAppLanguageUseCase(languageRepo),
            ),
          ),
          BlocProvider(
            create: (_) => AppThemeCubit(
              getThemeMode: GetAppThemeModeUseCase(themeRepo),
              setThemeMode: SetAppThemeModeUseCase(themeRepo),
            ),
          ),
        ],
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

  testWidgets('names email as the sign-in method of an email session', (
    tester,
  ) async {
    await pumpScreen(tester, const Locale('en'));

    expect(find.text('Email'), findsNWidgets(2));
    expect(find.text('Google'), findsNothing);
  });

  testWidgets('names Google as the sign-in method of a Google session', (
    tester,
  ) async {
    signInMethod = SignInMethod.google;

    await pumpScreen(tester, const Locale('en'));

    expect(find.text('Google'), findsOneWidget);
  });

  testWidgets('lays out in Arabic without overflowing', (tester) async {
    await pumpScreen(tester, const Locale('ar'));

    expect(find.text('الملف الشخصي'), findsOneWidget);
    expect(find.text('حذف الحساب'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('hides actions that have no backend yet', (tester) async {
    await pumpScreen(tester, const Locale('en'));

    expect(find.text('Edit'), findsNothing);
    expect(find.text('Upgrade to Pro'), findsNothing);
  });

  PlanUsageEntity freeUsage({
    int charactersUsed = 3500,
    int? audioSecondsRemaining = 420,
  }) => PlanUsageEntity(
    plan: PlanUsageEntity.freePlan,
    charactersLimit: 5000,
    charactersUsed: charactersUsed,
    resetsAt: DateTime.utc(2026, 9, 29),
    audioSecondsLimit: audioSecondsRemaining == null ? null : 900,
    audioSecondsRemaining: audioSecondsRemaining,
  );

  Finder richText(String text) => find.text(text, findRichText: true);

  testWidgets('shows the translation and conversation quotas', (tester) async {
    await pumpScreen(tester, const Locale('en'));

    expect(find.text('Free plan'), findsOneWidget);
    expect(find.text('Conversation'), findsOneWidget);
    expect(richText('70% used'), findsOneWidget);
    expect(richText('8 of 15 minutes'), findsOneWidget);
    expect(find.text('Used up'), findsNothing);
  });

  testWidgets('writes the quotas in Arabic-Indic digits in Arabic', (
    tester,
  ) async {
    await pumpScreen(tester, const Locale('ar'));

    expect(find.text('الخطة المجانية'), findsOneWidget);
    expect(find.text('المحادثة'), findsOneWidget);
    expect(richText('٧٠٪ مستخدم'), findsOneWidget);
    expect(richText('٨ من ١٥ دقيقة'), findsOneWidget);
  });

  testWidgets('hides the conversation quota when the server omits it', (
    tester,
  ) async {
    usageRepo.result = ApiResult.success(
      freeUsage(audioSecondsRemaining: null),
    );

    await pumpScreen(tester, const Locale('en'));

    expect(richText('70% used'), findsOneWidget);
    expect(find.text('Conversation'), findsNothing);
  });

  testWidgets('marks spent conversation time while translation is left', (
    tester,
  ) async {
    usageRepo.result = ApiResult.success(freeUsage(audioSecondsRemaining: 0));

    await pumpScreen(tester, const Locale('en'));

    expect(find.text('Used up'), findsOneWidget);
    expect(richText('15 of 15 minutes'), findsOneWidget);
    expect(
      find.text('Paused until it renews · translation is still available'),
      findsOneWidget,
    );
  });

  testWidgets('marks spent translation while conversation time is left', (
    tester,
  ) async {
    usageRepo.result = ApiResult.success(freeUsage(charactersUsed: 5000));

    await pumpScreen(tester, const Locale('en'));

    expect(find.text('Used up'), findsOneWidget);
    expect(richText('100% used'), findsOneWidget);
    expect(
      find.text('Paused until it renews · conversation is still available'),
      findsOneWidget,
    );
  });

  testWidgets('pauses spent translation alone when conversation is unknown', (
    tester,
  ) async {
    usageRepo.result = ApiResult.success(
      freeUsage(charactersUsed: 5000, audioSecondsRemaining: null),
    );

    await pumpScreen(tester, const Locale('en'));

    expect(find.text('Used up'), findsOneWidget);
    expect(find.text('Paused until it renews'), findsOneWidget);
  });

  testWidgets('bolds only the used amount of each quota', (tester) async {
    await pumpScreen(tester, const Locale('en'));

    List<String> boldIn(String text) {
      final bold = <String>[];
      tester.widget<RichText>(richText(text)).text.visitChildren((span) {
        if (span is TextSpan &&
            span.text != null &&
            span.style?.fontWeight == FontWeight.w700) {
          bold.add(span.text!);
        }
        return true;
      });
      return bold;
    }

    expect(boldIn('70% used'), ['70%']);
    expect(boldIn('8 of 15 minutes'), ['8']);
  });

  testWidgets('keeps a spent label whole beside its badge when there is room', (
    tester,
  ) async {
    usageRepo.result = ApiResult.success(freeUsage(audioSecondsRemaining: 0));

    await pumpScreen(tester, const Locale('en'), width: 700);

    final label = tester.renderObject<RenderParagraph>(
      find.textContaining('Conversation', findRichText: true),
    );
    expect(label.didExceedMaxLines, isFalse);
    expect(find.text('Used up'), findsOneWidget);
  });

  testWidgets('pauses both quotas without pointing to the other', (
    tester,
  ) async {
    usageRepo.result = ApiResult.success(
      freeUsage(charactersUsed: 5000, audioSecondsRemaining: 0),
    );

    await pumpScreen(tester, const Locale('en'));

    expect(find.text('Used up'), findsNWidgets(2));
    expect(find.text('Paused until it renews'), findsNWidgets(2));
  });

  testWidgets('lays out a spent quota in Arabic without overflowing', (
    tester,
  ) async {
    usageRepo.result = ApiResult.success(freeUsage(audioSecondsRemaining: 0));

    await pumpScreen(tester, const Locale('ar'));

    expect(find.text('نفدت'), findsOneWidget);
    expect(
      find.text('متوقفة حتى التجديد · الترجمة ما زالت متاحة'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
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
    await tester.tap(find.byType(SheetCloseButton));
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
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(
      find.text("Couldn't change the language. Please try again."),
      findsOneWidget,
    );
    expect(find.text('Device language'), findsOneWidget);
  });

  testWidgets('the appearance row offers light, dark and automatic', (
    tester,
  ) async {
    await pumpScreen(tester, const Locale('en'));

    expect(find.text('Preferences'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
    expect(find.text('Auto'), findsOneWidget);
  });

  testWidgets('picking an appearance saves it straight away', (tester) async {
    await pumpScreen(tester, const Locale('en'));

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(themeRepo.saved, AppThemeMode.dark);
  });

  testWidgets('lays out the appearance row in Arabic without overflowing', (
    tester,
  ) async {
    await pumpScreen(tester, const Locale('ar'));

    expect(find.text('المظهر'), findsOneWidget);
    expect(find.text('تلقائي'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows an error toast when the appearance cannot be saved', (
    tester,
  ) async {
    themeRepo.saveResult = const ApiResult.failure(UnknownFailure());
    await pumpScreen(tester, const Locale('en'));

    await tester.tap(find.text('Dark'));
    await tester.pump();

    expect(
      find.text("Couldn't change the appearance. Please try again."),
      findsOneWidget,
    );
    expect(themeRepo.saved, AppThemeMode.system);

    await dismissToast(tester);
  });

  testWidgets('the offline packs row counts the downloaded packs', (
    tester,
  ) async {
    await pumpScreen(tester, const Locale('en'));

    // The section title and the plan card's quota row.
    expect(find.text('Translation'), findsNWidgets(2));
    expect(find.text('Offline packs'), findsOneWidget);
    expect(find.text('1 installed'), findsOneWidget);
  });

  testWidgets('the offline packs row says none are installed', (tester) async {
    modelsRepo.statuses = {'en': const OfflineModelBuiltIn()};

    await pumpScreen(tester, const Locale('en'));

    expect(find.text('None installed'), findsOneWidget);
  });

  testWidgets('the offline packs row hides the count when it is unknown', (
    tester,
  ) async {
    modelsRepo.statusesResult = const ApiResult.failure(UnknownFailure());

    await pumpScreen(tester, const Locale('en'));

    expect(find.text('Offline packs'), findsOneWidget);
    expect(find.textContaining('installed'), findsNothing);
  });

  testWidgets('writes the offline packs count in Arabic-Indic digits', (
    tester,
  ) async {
    await pumpScreen(tester, const Locale('ar'));

    expect(find.text('حزم بدون إنترنت'), findsOneWidget);
    expect(find.text('١ مثبتة'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
