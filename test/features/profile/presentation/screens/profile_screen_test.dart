import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/di/service_locator.dart';
import 'package:transly_ai/core/domain/usecases/get_cached_user_use_case.dart';
import 'package:transly_ai/core/theme/app_palette.dart';
import 'package:transly_ai/core/widgets/toast/app_toast_scope.dart';
import 'package:transly_ai/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:transly_ai/features/profile/presentation/screens/profile_screen.dart';
import 'package:transly_ai/l10n/app_localizations.dart';

import '../../../../helpers/fake_user_repo.dart';

void main() {
  setUp(() {
    serviceLocator.registerFactory(
      () => ProfileCubit(
        getCachedUser: GetCachedUserUseCase(FakeUserRepo(testUser)),
      ),
    );
  });

  tearDown(serviceLocator.reset);

  Future<void> pumpScreen(WidgetTester tester, Locale locale) {
    tester.view.physicalSize = const Size(402, 874) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    return tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [AppPalette.light]),
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => AppToastScope(child: child!),
        home: const ProfileScreen(),
      ),
    );
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

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });
}
