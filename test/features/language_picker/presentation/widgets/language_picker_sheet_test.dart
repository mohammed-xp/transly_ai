import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/di/service_locator.dart';
import 'package:transly_ai/core/domain/entities/language_entity.dart';
import 'package:transly_ai/core/domain/entities/language_side.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/core/theme/app_palette.dart';
import 'package:transly_ai/features/language_picker/domain/entities/language_pair.dart';
import 'package:transly_ai/features/language_picker/domain/usecases/add_recent_language_usecase.dart';
import 'package:transly_ai/features/language_picker/domain/usecases/get_cached_languages_usecase.dart';
import 'package:transly_ai/features/language_picker/domain/usecases/get_recent_languages_usecase.dart';
import 'package:transly_ai/features/language_picker/domain/usecases/select_language_usecase.dart';
import 'package:transly_ai/features/language_picker/domain/usecases/sync_languages_usecase.dart';
import 'package:transly_ai/features/language_picker/presentation/cubit/language_picker_cubit.dart';
import 'package:transly_ai/features/language_picker/presentation/widgets/language_picker_sheet.dart';
import 'package:transly_ai/l10n/app_localizations.dart';

import '../../../../helpers/fake_languages_repo.dart';

void main() {
  const initialPair = (
    from: LanguageEntity.defaultSource,
    to: LanguageEntity.defaultTarget,
  );

  late FakeLanguagesRepo languagesRepo;
  late bool sheetClosed;
  LanguagePair? result;

  setUp(() {
    languagesRepo = FakeLanguagesRepo(cached: testLanguages);
    sheetClosed = false;
    result = null;
    serviceLocator
        .registerFactoryParam<LanguagePickerCubit, LanguagePair, void>(
          (pair, _) => LanguagePickerCubit(
            initialPair: pair,
            getCachedLanguages: GetCachedLanguagesUseCase(languagesRepo),
            syncLanguages: SyncLanguagesUseCase(languagesRepo),
            getRecentLanguages: GetRecentLanguagesUseCase(languagesRepo),
            addRecentLanguage: AddRecentLanguageUseCase(languagesRepo),
            selectLanguage: const SelectLanguageUseCase(),
          ),
        );
  });

  tearDown(serviceLocator.reset);

  Future<void> openSheet(WidgetTester tester) async {
    tester.view.physicalSize = const Size(402, 874) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [AppPalette.light]),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await showLanguagePickerSheet(
                  context,
                  initialSide: LanguageSide.target,
                  initialPair: initialPair,
                );
                sheetClosed = true;
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Future<void> closeSheet(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
  }

  testWidgets('lists the cached languages by their native names', (
    tester,
  ) async {
    await openSheet(tester);

    expect(find.text('Choose language'), findsOneWidget);
    expect(find.text('All languages · 4'), findsOneWidget);
    expect(find.text('Deutsch'), findsOneWidget);
    expect(languagesRepo.syncCalls, 0);
  });

  testWidgets('fetches the languages when none are cached', (tester) async {
    languagesRepo.cached = const [];

    await openSheet(tester);

    expect(languagesRepo.syncCalls, 1);
    expect(find.text('Deutsch'), findsOneWidget);
  });

  testWidgets('stays open after a language is picked', (tester) async {
    await openSheet(tester);

    await tester.tap(find.text('Deutsch'));
    await tester.pumpAndSettle();

    expect(find.text('Choose language'), findsOneWidget);
    expect(sheetClosed, isFalse);
  });

  testWidgets('returns the picked pair once closed', (tester) async {
    await openSheet(tester);

    await tester.tap(find.text('Deutsch'));
    await tester.pumpAndSettle();
    await closeSheet(tester);

    expect(result, (from: LanguageEntity.defaultSource, to: testGerman));
  });

  testWidgets('returns the picked pair when dismissed by a tap outside', (
    tester,
  ) async {
    await openSheet(tester);

    await tester.tap(find.text('Deutsch'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(result, (from: LanguageEntity.defaultSource, to: testGerman));
  });

  testWidgets('returns the opening pair when nothing was picked', (
    tester,
  ) async {
    await openSheet(tester);

    await closeSheet(tester);

    expect(result, initialPair);
  });

  testWidgets('a picked language shows up under Recent', (tester) async {
    await openSheet(tester);
    expect(find.text('Recent'), findsNothing);

    await tester.tap(find.text('Deutsch'));
    await tester.pumpAndSettle();

    expect(find.text('Recent'), findsOneWidget);
    expect(languagesRepo.recents, [testGerman]);
  });

  testWidgets('switching the side picks for the source language', (
    tester,
  ) async {
    await openSheet(tester);

    await tester.tap(find.text('FROM'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Français'));
    await tester.pumpAndSettle();
    await closeSheet(tester);

    expect(result, (from: testFrench, to: LanguageEntity.defaultTarget));
  });

  testWidgets('tags the other side\'s language and swaps when it is picked', (
    tester,
  ) async {
    await openSheet(tester);

    expect(find.text('Source language'), findsOneWidget);
    await tester.tap(find.text('Swap'));
    await tester.pumpAndSettle();
    await closeSheet(tester);

    expect(result, (
      from: LanguageEntity.defaultTarget,
      to: LanguageEntity.defaultSource,
    ));
  });

  testWidgets('searching narrows the list', (tester) async {
    await openSheet(tester);

    await tester.enterText(find.byType(TextField), 'fren');
    await tester.pumpAndSettle();

    expect(find.text('Français'), findsOneWidget);
    expect(find.text('Deutsch'), findsNothing);
  });

  testWidgets('says so when the search matches nothing', (tester) async {
    await openSheet(tester);

    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pumpAndSettle();

    expect(find.text('No language matches your search.'), findsOneWidget);
  });

  testWidgets('offers a retry when the languages fail to load', (tester) async {
    languagesRepo
      ..cached = const []
      ..syncResult = const ApiResult.failure(NetworkFailure());
    await openSheet(tester);
    expect(find.text('Deutsch'), findsNothing);

    languagesRepo.syncResult = const ApiResult.success(testLanguages);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Deutsch'), findsOneWidget);
  });
}
