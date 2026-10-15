import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/di/service_locator.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/core/theme/app_palette.dart';
import 'package:transly_ai/core/widgets/toast/app_toast_scope.dart';
import 'package:transly_ai/features/language_picker/domain/entities/offline_model_status.dart';
import 'package:transly_ai/features/language_picker/presentation/screens/offline_packs_screen.dart';
import 'package:transly_ai/l10n/app_localizations.dart';

import '../../../../helpers/fake_languages_repo.dart';
import '../../../../helpers/fake_offline_models_repo.dart';
import '../../../../helpers/offline_packs_cubit_factory.dart';

void main() {
  late FakeOfflineModelsRepo modelsRepo;

  setUp(() {
    modelsRepo = FakeOfflineModelsRepo(
      statuses: {
        'en': const OfflineModelBuiltIn(),
        'ar': const OfflineModelDownloaded(),
        'de': const OfflineModelNotDownloaded(),
      },
    );
    serviceLocator.registerFactory(
      () => buildOfflinePacksCubit(
        languages: FakeLanguagesRepo(cached: testLanguages),
        models: modelsRepo,
      ),
    );
  });

  tearDown(serviceLocator.reset);

  Future<void> pumpScreen(WidgetTester tester, Locale locale) async {
    tester.view.physicalSize = const Size(402, 874) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [AppPalette.light]),
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => AppToastScope(child: child!),
        home: const OfflinePacksScreen(),
      ),
    );
    // Resolves the statuses request.
    await tester.pump();
  }

  Finder removeButton() => find.byTooltip('Remove');

  testWidgets('lists the installed packs apart from the available ones', (
    tester,
  ) async {
    await pumpScreen(tester, const Locale('en'));

    expect(find.text('Offline packs'), findsOneWidget);
    expect(find.text('Installed'), findsOneWidget);
    expect(find.text('Available to download'), findsOneWidget);
    expect(find.text('العربية'), findsOneWidget);
    expect(find.text('Deutsch'), findsOneWidget);
    expect(find.text('Built in'), findsOneWidget);
  });

  testWidgets('leaves out the languages the device cannot translate', (
    tester,
  ) async {
    await pumpScreen(tester, const Locale('en'));

    expect(find.text('Français'), findsNothing);
  });

  testWidgets('hides the available section when everything is installed', (
    tester,
  ) async {
    modelsRepo.statuses['de'] = const OfflineModelDownloaded();

    await pumpScreen(tester, const Locale('en'));

    expect(find.text('Available to download'), findsNothing);
  });

  testWidgets('the download button downloads the language', (tester) async {
    await pumpScreen(tester, const Locale('en'));

    await tester.tap(find.byTooltip('Download for offline use'));
    await tester.pump();

    expect(modelsRepo.downloads, ['de']);
  });

  testWidgets('a finished download moves the language to installed', (
    tester,
  ) async {
    await pumpScreen(tester, const Locale('en'));

    modelsRepo.updates.add((
      code: 'de',
      status: const OfflineModelDownloaded(),
    ));
    await tester.pump();

    expect(find.text('Available to download'), findsNothing);
    expect(removeButton(), findsNWidgets(2));
  });

  testWidgets('removing a pack asks first', (tester) async {
    await pumpScreen(tester, const Locale('en'));

    await tester.tap(removeButton());
    await tester.pumpAndSettle();

    expect(modelsRepo.deletes, isEmpty);

    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();

    expect(modelsRepo.deletes, ['ar']);
  });

  testWidgets('cancelling the removal keeps the pack', (tester) async {
    await pumpScreen(tester, const Locale('en'));

    await tester.tap(removeButton());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(modelsRepo.deletes, isEmpty);
  });

  testWidgets('a failed download shows an error toast', (tester) async {
    modelsRepo.downloadResult = const ApiResult.failure(ModelDownloadFailure());
    await pumpScreen(tester, const Locale('en'));

    await tester.tap(find.byTooltip('Download for offline use'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(
      find.text(
        "Couldn't download the translation model. "
        'Check your connection and try again.',
      ),
      findsOneWidget,
    );

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('shows the failure with a retry action', (tester) async {
    modelsRepo.statusesResult = const ApiResult.failure(UnknownFailure());

    await pumpScreen(tester, const Locale('en'));

    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('Installed'), findsNothing);
  });

  testWidgets('retry loads the packs', (tester) async {
    modelsRepo.statusesResult = const ApiResult.failure(UnknownFailure());
    await pumpScreen(tester, const Locale('en'));

    modelsRepo.statusesResult = null;
    await tester.tap(find.text('Retry'));
    await tester.pump();

    expect(find.text('Installed'), findsOneWidget);
    expect(find.text('Retry'), findsNothing);
  });

  testWidgets('lays out in Arabic without overflowing', (tester) async {
    await pumpScreen(tester, const Locale('ar'));

    expect(find.text('حزم بدون إنترنت'), findsOneWidget);
    expect(find.text('المثبتة'), findsOneWidget);
    expect(find.text('متاحة للتحميل'), findsOneWidget);
    expect(find.text('التحميل التلقائي'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows the auto-download switches on by default', (tester) async {
    await pumpScreen(tester, const Locale('en'));

    expect(find.text('Auto-download'), findsOneWidget);
    expect(find.text('Download languages automatically'), findsOneWidget);
    expect(find.text('Wi‑Fi only'), findsOneWidget);
    final switches = tester.widgetList<Switch>(find.byType(Switch));
    expect(switches.map((s) => s.value), [true, true]);
  });

  testWidgets('turning auto-download off saves it', (tester) async {
    await pumpScreen(tester, const Locale('en'));

    await tester.tap(find.byType(Switch).first);
    await tester.pump();

    expect(modelsRepo.savedSettings, [(autoDownload: false, wifiOnly: true)]);
  });

  testWidgets('Wi-Fi only is disabled while auto-download is off', (
    tester,
  ) async {
    modelsRepo.settings = (autoDownload: false, wifiOnly: true);

    await pumpScreen(tester, const Locale('en'));

    final wifiOnly = tester.widgetList<Switch>(find.byType(Switch)).last;
    expect(wifiOnly.onChanged, isNull);
  });

  testWidgets('a setting that cannot be saved shows an error toast', (
    tester,
  ) async {
    modelsRepo.saveSettingsResult = const ApiResult.failure(UnknownFailure());
    await pumpScreen(tester, const Locale('en'));

    await tester.tap(find.byType(Switch).last);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(
      find.text("Couldn't save the setting. Please try again."),
      findsOneWidget,
    );

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('marks an auto-downloaded pack', (tester) async {
    modelsRepo.statuses['ar'] = const OfflineModelDownloaded(isAuto: true);

    await pumpScreen(tester, const Locale('en'));

    expect(find.textContaining('Downloaded automatically'), findsOneWidget);
  });

  testWidgets('shows a running auto-download among the installed packs', (
    tester,
  ) async {
    modelsRepo.statuses['de'] = const OfflineModelDownloading(isAuto: true);

    await pumpScreen(tester, const Locale('en'));

    expect(find.text('Downloading…'), findsOneWidget);
    expect(find.text('Auto'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text('Available to download'), findsNothing);
  });

  testWidgets('the built-in language cannot be removed', (tester) async {
    modelsRepo.statuses['ar'] = const OfflineModelNotDownloaded();

    await pumpScreen(tester, const Locale('en'));

    expect(find.text('English'), findsOneWidget);
    expect(removeButton(), findsNothing);
  });
}
