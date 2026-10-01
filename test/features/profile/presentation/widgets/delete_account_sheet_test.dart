import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/di/service_locator.dart';
import 'package:transly_ai/core/domain/usecases/get_cached_user_use_case.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/core/session/session_manager.dart';
import 'package:transly_ai/core/theme/app_palette.dart';
import 'package:transly_ai/core/widgets/toast/app_toast_scope.dart';
import 'package:transly_ai/features/app_language/domain/usecases/get_app_language_usecase.dart';
import 'package:transly_ai/features/app_language/domain/usecases/set_app_language_usecase.dart';
import 'package:transly_ai/features/app_language/presentation/cubit/app_language_cubit.dart';
import 'package:transly_ai/features/profile/domain/usecases/delete_account_use_case.dart';
import 'package:transly_ai/features/profile/domain/usecases/get_plan_usage_usecase.dart';
import 'package:transly_ai/features/profile/presentation/cubit/delete_account_cubit.dart';
import 'package:transly_ai/features/profile/presentation/cubit/plan_usage_cubit.dart';
import 'package:transly_ai/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:transly_ai/features/profile/presentation/screens/profile_screen.dart';
import 'package:transly_ai/l10n/app_localizations.dart';

import '../../../../helpers/fake_account_repo.dart';
import '../../../../helpers/fake_app_language_repo.dart';
import '../../../../helpers/fake_logout_repo.dart';
import '../../../../helpers/fake_plan_usage_repo.dart';
import '../../../../helpers/fake_user_repo.dart';

void main() {
  late FakeAccountRepo accountRepo;

  setUp(() {
    accountRepo = FakeAccountRepo(
      const ApiResult.failure(ClientFailure(statusCode: 400)),
    );
    serviceLocator
      ..registerFactory(
        () => ProfileCubit(
          getCachedUser: GetCachedUserUseCase(FakeUserRepo(testUser)),
        ),
      )
      ..registerFactory(
        () => PlanUsageCubit(
          getPlanUsage: GetPlanUsageUseCase(
            FakePlanUsageRepo(ApiResult.success(testFreeUsage)),
          ),
        ),
      )
      ..registerFactory(
        () => DeleteAccountCubit(
          deleteAccount: DeleteAccountUseCase(
            accountRepo,
            SessionManager(FakeLogoutRepo()),
          ),
        ),
      );
  });

  tearDown(serviceLocator.reset);

  Future<void> openSheet(WidgetTester tester, Locale locale) async {
    tester.view.physicalSize = const Size(402, 874) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final languageRepo = FakeAppLanguageRepo();
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
    await tester.pump();

    final deleteLink = find.text(
      locale.languageCode == 'ar' ? 'حذف الحساب' : 'Delete account',
    );
    await tester.ensureVisible(deleteLink);
    await tester.tap(deleteLink);
    await tester.pumpAndSettle();
  }

  testWidgets('opens the confirmation sheet from the profile screen', (
    tester,
  ) async {
    await openSheet(tester, const Locale('en'));

    expect(find.text('Delete your account?'), findsOneWidget);
    expect(find.text('Delete permanently'), findsOneWidget);
  });

  testWidgets('does not delete until a password is entered', (tester) async {
    await openSheet(tester, const Locale('en'));

    await tester.tap(find.text('Delete permanently'));
    await tester.pump();

    expect(accountRepo.passwords, isEmpty);
  });

  testWidgets('sends the entered password when confirming', (tester) async {
    await openSheet(tester, const Locale('en'));

    await tester.enterText(find.byType(TextField), 'secret123');
    await tester.pump();
    await tester.tap(find.text('Delete permanently'));
    await tester.pump();

    expect(accountRepo.passwords, ['secret123']);
  });

  testWidgets('shows a wrong password under the field', (tester) async {
    await openSheet(tester, const Locale('en'));

    await tester.enterText(find.byType(TextField), 'wrong');
    await tester.pump();
    await tester.tap(find.text('Delete permanently'));
    await tester.pump();

    expect(find.text('Incorrect password'), findsOneWidget);
    expect(find.text('Delete your account?'), findsOneWidget);
  });

  testWidgets('shows a wrong password in Arabic without overflowing', (
    tester,
  ) async {
    await openSheet(tester, const Locale('ar'));

    await tester.enterText(find.byType(TextField), 'wrong');
    await tester.pump();
    await tester.tap(find.text('حذف نهائي'));
    await tester.pump();

    expect(find.text('كلمة المرور غير صحيحة'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cancel closes the sheet without deleting', (tester) async {
    await openSheet(tester, const Locale('en'));

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Delete your account?'), findsNothing);
    expect(accountRepo.passwords, isEmpty);
  });
}
