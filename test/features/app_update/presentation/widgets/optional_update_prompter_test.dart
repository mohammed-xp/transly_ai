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
import 'package:transly_ai/features/app_update/presentation/cubit/app_update_state.dart';
import 'package:transly_ai/features/app_update/presentation/widgets/optional_update_prompter.dart';
import 'package:transly_ai/features/app_update/presentation/widgets/optional_update_sheet.dart';
import 'package:transly_ai/l10n/app_localizations.dart';

import '../../../../helpers/fake_app_update_repo.dart';

void main() {
  late FakeAppUpdateRepo repo;
  late AppUpdateCubit cubit;

  setUp(() {
    repo = FakeAppUpdateRepo(
      checkResult: const ApiResult.success(testOptionalUpdate),
    );
    cubit = AppUpdateCubit(
      checkForUpdate: CheckForAppUpdateUseCase(repo),
      markPrompted: MarkAppUpdatePromptedUseCase(repo),
      openStore: OpenAppStoreUseCase(repo),
    );
  });

  tearDown(() => cubit.close());

  Future<void> pumpPrompter(WidgetTester tester, {Key? key}) async {
    tester.view.physicalSize = const Size(402, 874) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: MaterialApp(
          theme: ThemeData(extensions: const [AppPalette.light]),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => AppToastScope(child: child!),
          home: Scaffold(
            body: OptionalUpdatePrompter(key: key, child: const Text('Home')),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the sheet for an update found before it mounted', (
    tester,
  ) async {
    await cubit.checkForUpdate();

    await pumpPrompter(tester);

    expect(find.byType(OptionalUpdateSheet), findsOneWidget);
    expect(repo.markPromptedCalls, 1);
    expect(cubit.state, isA<AppUpdateNone>());
  });

  testWidgets('shows the sheet for an update found after it mounted', (
    tester,
  ) async {
    await pumpPrompter(tester);
    expect(find.byType(OptionalUpdateSheet), findsNothing);

    await cubit.checkForUpdate();
    await tester.pumpAndSettle();

    expect(find.byType(OptionalUpdateSheet), findsOneWidget);
  });

  testWidgets('does not show the sheet when there is no update', (
    tester,
  ) async {
    repo.checkResult = const ApiResult.success(null);
    await cubit.checkForUpdate();

    await pumpPrompter(tester);

    expect(find.byType(OptionalUpdateSheet), findsNothing);
    expect(repo.markPromptedCalls, 0);
  });

  testWidgets('does not show the sheet for a required update', (tester) async {
    repo.checkResult = const ApiResult.success(testRequiredUpdate);
    await cubit.checkForUpdate();

    await pumpPrompter(tester);

    expect(find.byType(OptionalUpdateSheet), findsNothing);
  });

  testWidgets('does not show the sheet again once it was shown', (
    tester,
  ) async {
    await cubit.checkForUpdate();
    await pumpPrompter(tester, key: const ValueKey('first'));
    await tester.tap(find.text('Later'));
    await tester.pumpAndSettle();

    await pumpPrompter(tester, key: const ValueKey('second'));

    expect(find.byType(OptionalUpdateSheet), findsNothing);
    expect(repo.markPromptedCalls, 1);
  });

  testWidgets('Update now closes the sheet and opens the store', (
    tester,
  ) async {
    await cubit.checkForUpdate();
    await pumpPrompter(tester);

    await tester.tap(find.text('Update now'));
    await tester.pumpAndSettle();

    expect(find.byType(OptionalUpdateSheet), findsNothing);
    expect(repo.openStoreCalls, 1);
  });
}
