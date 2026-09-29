import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/core/theme/app_palette.dart';
import 'package:transly_ai/core/widgets/toast/app_toast_scope.dart';
import 'package:transly_ai/features/app_update/domain/usecases/check_for_app_update_usecase.dart';
import 'package:transly_ai/features/app_update/domain/usecases/mark_app_update_prompted_usecase.dart';
import 'package:transly_ai/features/app_update/domain/usecases/open_app_store_usecase.dart';
import 'package:transly_ai/features/app_update/presentation/cubit/app_update_cubit.dart';
import 'package:transly_ai/features/app_update/presentation/screens/force_update_screen.dart';
import 'package:transly_ai/features/app_update/presentation/widgets/app_update_gate.dart';
import 'package:transly_ai/l10n/app_localizations.dart';

import '../../../../helpers/fake_app_update_repo.dart';

void main() {
  const appContent = 'App content';

  Future<AppUpdateCubit> pumpGate(
    WidgetTester tester,
    FakeAppUpdateRepo repo,
  ) async {
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
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) =>
              AppToastScope(child: AppUpdateGate(child: child!)),
          home: const Scaffold(body: Text(appContent)),
        ),
      ),
    );
    return cubit;
  }

  testWidgets('shows the app while the check is running', (tester) async {
    await pumpGate(tester, FakeAppUpdateRepo());

    expect(find.text(appContent), findsOneWidget);
    expect(find.byType(ForceUpdateScreen), findsNothing);
  });

  testWidgets('replaces the app with ForceUpdateScreen for a required update', (
    tester,
  ) async {
    final cubit = await pumpGate(
      tester,
      FakeAppUpdateRepo(
        checkResult: const ApiResult.success(testRequiredUpdate),
      ),
    );

    await cubit.checkForUpdate();
    await tester.pump();

    expect(find.byType(ForceUpdateScreen), findsOneWidget);
    expect(find.text(appContent), findsNothing);
  });

  testWidgets('keeps the app for an optional update', (tester) async {
    final cubit = await pumpGate(
      tester,
      FakeAppUpdateRepo(
        checkResult: const ApiResult.success(testOptionalUpdate),
      ),
    );

    await cubit.checkForUpdate();
    await tester.pump();

    expect(find.text(appContent), findsOneWidget);
    expect(find.byType(ForceUpdateScreen), findsNothing);
  });
}
