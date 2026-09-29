import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/core/theme/app_palette.dart';
import 'package:transly_ai/core/widgets/toast/app_toast_scope.dart';
import 'package:transly_ai/features/app_update/domain/usecases/check_for_app_update_usecase.dart';
import 'package:transly_ai/features/app_update/domain/usecases/mark_app_update_prompted_usecase.dart';
import 'package:transly_ai/features/app_update/domain/usecases/open_app_store_usecase.dart';
import 'package:transly_ai/features/app_update/presentation/cubit/app_update_cubit.dart';
import 'package:transly_ai/features/app_update/presentation/screens/force_update_screen.dart';
import 'package:transly_ai/l10n/app_localizations.dart';

import '../../../../helpers/fake_app_update_repo.dart';

void main() {
  late FakeAppUpdateRepo repo;

  setUp(() => repo = FakeAppUpdateRepo());

  Future<void> pumpScreen(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
  }) async {
    tester.view.physicalSize = const Size(402, 874) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final cubit = AppUpdateCubit(
      checkForUpdate: CheckForAppUpdateUseCase(repo),
      markPrompted: MarkAppUpdatePromptedUseCase(repo),
      openStore: OpenAppStoreUseCase(repo),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: MaterialApp(
          theme: ThemeData(extensions: const [AppPalette.light]),
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => AppToastScope(child: child!),
          home: const ForceUpdateScreen(update: testRequiredUpdate),
        ),
      ),
    );
  }

  testWidgets('shows the title, explanation and both versions', (tester) async {
    await pumpScreen(tester);

    expect(find.text('Update required'), findsOneWidget);
    expect(
      find.text(
        'This version is no longer supported. '
        'Update Transly to keep translating.',
      ),
      findsOneWidget,
    );
    expect(find.text('Your version'), findsOneWidget);
    expect(find.text('2.1.0'), findsOneWidget);
    expect(find.text('Latest'), findsOneWidget);
    expect(find.text('2.4.0'), findsOneWidget);
  });

  testWidgets('renders the Arabic copy', (tester) async {
    await pumpScreen(tester, locale: const Locale('ar'));

    expect(find.text('يلزم تحديث التطبيق'), findsOneWidget);
    expect(find.text('إصدارك'), findsOneWidget);
    expect(find.text('الأحدث'), findsOneWidget);
    expect(find.text('التحديث من Google Play'), findsOneWidget);
  });

  testWidgets(
    'names Google Play on Android',
    (tester) async {
      await pumpScreen(tester);

      expect(find.text('Update from Google Play'), findsOneWidget);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );

  testWidgets(
    'names the App Store on iOS',
    (tester) async {
      await pumpScreen(tester);

      expect(find.text('Update from the App Store'), findsOneWidget);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );

  testWidgets('the update button opens the store', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text('Update from Google Play'));
    await tester.pumpAndSettle();

    expect(repo.openStoreCalls, 1);
    expect(
      find.text("Couldn't open the store. Please try again."),
      findsNothing,
    );
  });

  testWidgets('shows a toast when the store cannot be opened', (tester) async {
    repo.openStoreResult = const ApiResult.failure(UnknownFailure());
    await pumpScreen(tester);

    await tester.tap(find.text('Update from Google Play'));
    await tester.pumpAndSettle();

    expect(
      find.text("Couldn't open the store. Please try again."),
      findsOneWidget,
    );
  });
}
