import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/theme/app_palette.dart';
import 'package:transly_ai/features/language_picker/domain/entities/offline_model_status.dart';
import 'package:transly_ai/features/language_picker/domain/usecases/get_cached_languages_usecase.dart';
import 'package:transly_ai/features/language_picker/domain/usecases/get_offline_packs_settings_usecase.dart';
import 'package:transly_ai/features/language_picker/domain/usecases/watch_offline_model_updates_usecase.dart';
import 'package:transly_ai/features/language_picker/presentation/cubit/auto_download_notice_cubit.dart';
import 'package:transly_ai/features/language_picker/presentation/widgets/auto_download_notice.dart';
import 'package:transly_ai/l10n/app_localizations.dart';

import '../../../../helpers/fake_languages_repo.dart';
import '../../../../helpers/fake_offline_models_repo.dart';

void main() {
  late FakeOfflineModelsRepo models;

  setUp(() => models = FakeOfflineModelsRepo());

  Future<void> pumpNotice(WidgetTester tester, Locale locale) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [AppPalette.light]),
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: BlocProvider(
            create: (_) => AutoDownloadNoticeCubit(
              watchOfflineModelUpdates: WatchOfflineModelUpdatesUseCase(models),
              getCachedLanguages: GetCachedLanguagesUseCase(
                FakeLanguagesRepo(cached: testLanguages),
              ),
              getSettings: GetOfflinePacksSettingsUseCase(models),
            ),
            child: const AutoDownloadNotice(),
          ),
        ),
      ),
    );
  }

  Future<void> report(
    WidgetTester tester,
    String code,
    OfflineModelStatus status,
  ) async {
    models.updates.add((code: code, status: status));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('shows nothing while no download runs', (tester) async {
    await pumpNotice(tester, const Locale('en'));

    expect(find.textContaining('Downloading'), findsNothing);
  });

  testWidgets('names the language downloading in the background', (
    tester,
  ) async {
    await pumpNotice(tester, const Locale('en'));

    await report(tester, 'ar', const OfflineModelDownloading(isAuto: true));

    expect(find.text('Downloading Arabic for offline use'), findsOneWidget);
    expect(find.text('Over Wi‑Fi'), findsOneWidget);
  });

  testWidgets('leaves out Wi-Fi when mobile data is allowed', (tester) async {
    models.settings = (autoDownload: true, wifiOnly: false);
    await pumpNotice(tester, const Locale('en'));

    await report(tester, 'ar', const OfflineModelDownloading(isAuto: true));

    expect(find.text('Over Wi‑Fi'), findsNothing);
  });

  testWidgets('hide removes the notice', (tester) async {
    await pumpNotice(tester, const Locale('en'));
    await report(tester, 'ar', const OfflineModelDownloading(isAuto: true));

    await tester.tap(find.byTooltip('Hide'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('Downloading'), findsNothing);
  });

  testWidgets('goes away once the download finishes', (tester) async {
    await pumpNotice(tester, const Locale('en'));
    await report(tester, 'ar', const OfflineModelDownloading(isAuto: true));

    await report(tester, 'ar', const OfflineModelDownloaded(isAuto: true));

    expect(find.textContaining('Downloading'), findsNothing);
  });

  testWidgets('lays out in Arabic without overflowing', (tester) async {
    await pumpNotice(tester, const Locale('ar'));

    await report(tester, 'ar', const OfflineModelDownloading(isAuto: true));

    expect(
      find.text('جارٍ تحميل العربية للاستخدام بدون إنترنت'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
