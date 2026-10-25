import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/constants/app_links.dart';
import 'package:transly_ai/core/di/service_locator.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/core/theme/app_palette.dart';
import 'package:transly_ai/core/widgets/toast/app_toast_scope.dart';
import 'package:transly_ai/features/about/domain/entities/app_info_entity.dart';
import 'package:transly_ai/features/about/domain/repos/app_info_repo.dart';
import 'package:transly_ai/features/about/domain/usecases/get_app_info_usecase.dart';
import 'package:transly_ai/features/about/presentation/cubit/app_info_cubit.dart';
import 'package:transly_ai/features/about/presentation/screens/about_screen.dart';
import 'package:transly_ai/l10n/app_localizations.dart';

class _FakeAppInfoRepo implements AppInfoRepo {
  _FakeAppInfoRepo(this.result);

  final ApiResult<AppInfoEntity> result;

  @override
  Future<ApiResult<AppInfoEntity>> getAppInfo() async => result;
}

void main() {
  const installed = ApiResult<AppInfoEntity>.success(
    AppInfoEntity(version: '1.2.2'),
  );

  tearDown(serviceLocator.reset);

  Future<void> pumpScreen(
    WidgetTester tester, {
    ApiResult<AppInfoEntity> appInfo = installed,
    Locale locale = const Locale('en'),
  }) async {
    tester.view.physicalSize = const Size(402, 874) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    serviceLocator.registerFactory(
      () => AppInfoCubit(
        getAppInfo: GetAppInfoUseCase(_FakeAppInfoRepo(appInfo)),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [AppPalette.light]),
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => AppToastScope(child: child!),
        home: const AboutScreen(),
      ),
    );
    await tester.pump();
  }

  testWidgets('shows the installed version', (tester) async {
    await pumpScreen(tester);

    expect(find.text('Version 1.2.2'), findsOneWidget);
  });

  testWidgets('leaves the version out when it cannot be read', (tester) async {
    await pumpScreen(
      tester,
      appInfo: const ApiResult.failure(UnknownFailure()),
    );

    expect(find.textContaining('Version'), findsNothing);
    expect(find.text('Share with friends'), findsOneWidget);
  });

  testWidgets('lists the support, help and legal rows', (tester) async {
    await pumpScreen(tester);

    for (final label in [
      'Share with friends',
      'Contact us',
      AppLinks.supportEmailAddress,
      'Terms of use',
      'Privacy policy',
    ]) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    expect(find.text("What's new"), findsNothing);
    expect(find.text('Help center'), findsNothing);
    expect(find.text('Open-source licenses'), findsNothing);
  });

  testWidgets('writes the copyright year in Arabic digits', (tester) async {
    await pumpScreen(tester, locale: const Locale('ar'));

    expect(find.textContaining('© ٢٠'), findsOneWidget);
    expect(find.text('عن التطبيق'), findsOneWidget);
  });
}
