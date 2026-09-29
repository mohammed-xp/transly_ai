import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/theme/app_palette.dart';
import 'package:transly_ai/features/app_update/domain/entities/app_update_entity.dart';
import 'package:transly_ai/features/app_update/presentation/widgets/optional_update_sheet.dart';
import 'package:transly_ai/l10n/app_localizations.dart';

import '../../../../helpers/fake_app_update_repo.dart';

void main() {
  Future<void> pumpApp(
    WidgetTester tester,
    Widget home, {
    Locale locale = const Locale('en'),
  }) async {
    tester.view.physicalSize = const Size(402, 874) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [AppPalette.light]),
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: home),
      ),
    );
  }

  Future<void> pumpSheet(
    WidgetTester tester, {
    AppUpdateEntity update = testOptionalUpdate,
    VoidCallback? onUpdate,
    VoidCallback? onLater,
    Locale locale = const Locale('en'),
  }) {
    return pumpApp(
      tester,
      OptionalUpdateSheet(
        update: update,
        onUpdate: onUpdate ?? () {},
        onLater: onLater ?? () {},
      ),
      locale: locale,
    );
  }

  testWidgets('shows the title, latest version, notes and both actions', (
    tester,
  ) async {
    await pumpSheet(tester);

    expect(find.text('New'), findsOneWidget);
    expect(find.text('A new update is available'), findsOneWidget);
    expect(find.text('v2.4.0'), findsOneWidget);
    expect(find.text("What's new"), findsOneWidget);
    for (final note in testOptionalUpdate.releaseNotes) {
      expect(find.text(note), findsOneWidget);
    }
    expect(find.text('Update now'), findsOneWidget);
    expect(find.text('Later'), findsOneWidget);
  });

  testWidgets('renders the Arabic copy', (tester) async {
    await pumpSheet(tester, locale: const Locale('ar'));

    expect(find.text('جديد'), findsOneWidget);
    expect(find.text('تحديث جديد متاح'), findsOneWidget);
    expect(find.text('ما الجديد'), findsOneWidget);
    expect(find.text('تحديث الآن'), findsOneWidget);
    expect(find.text('لاحقًا'), findsOneWidget);
  });

  testWidgets('hides "What\'s new" when the release has no notes', (
    tester,
  ) async {
    await pumpSheet(
      tester,
      update: const AppUpdateEntity(
        installedVersion: '2.1.0',
        latestVersion: '2.4.0',
        releaseNotes: [],
        isRequired: false,
      ),
    );

    expect(find.text("What's new"), findsNothing);
    expect(find.text('Update now'), findsOneWidget);
  });

  testWidgets('Update now calls onUpdate', (tester) async {
    var updates = 0;
    await pumpSheet(tester, onUpdate: () => updates++);

    await tester.tap(find.text('Update now'));

    expect(updates, 1);
  });

  testWidgets('Later calls onLater', (tester) async {
    var laters = 0;
    await pumpSheet(tester, onLater: () => laters++);

    await tester.tap(find.text('Later'));

    expect(laters, 1);
  });

  group('showOptionalUpdateSheet', () {
    Future<void> openSheet(WidgetTester tester, VoidCallback onUpdate) async {
      await pumpApp(
        tester,
        Builder(
          builder: (context) => TextButton(
            onPressed: () => showOptionalUpdateSheet(
              context,
              update: testOptionalUpdate,
              onUpdate: onUpdate,
            ),
            child: const Text('open'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    testWidgets('Update now closes the sheet, then runs onUpdate', (
      tester,
    ) async {
      var updates = 0;
      await openSheet(tester, () => updates++);

      await tester.tap(find.text('Update now'));
      await tester.pumpAndSettle();

      expect(find.byType(OptionalUpdateSheet), findsNothing);
      expect(updates, 1);
    });

    testWidgets('Later closes the sheet without running onUpdate', (
      tester,
    ) async {
      var updates = 0;
      await openSheet(tester, () => updates++);

      await tester.tap(find.text('Later'));
      await tester.pumpAndSettle();

      expect(find.byType(OptionalUpdateSheet), findsNothing);
      expect(updates, 0);
    });
  });
}
