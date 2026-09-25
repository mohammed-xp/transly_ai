import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/theme/app_palette.dart';
import 'package:transly_ai/core/widgets/toast/app_toast.dart';
import 'package:transly_ai/core/widgets/toast/app_toast_scope.dart';

void main() {
  group('AppToastData.autoDismissAfter', () {
    test('is 3 seconds for a plain toast', () {
      const data = AppToastData(message: 'Copied');

      expect(data.autoDismissAfter, const Duration(seconds: 3));
    });

    test('is 5 seconds when the toast has an action', () {
      final data = AppToastData(
        message: 'Deleted',
        type: AppToastType.neutral,
        actionLabel: 'Undo',
        onAction: () {},
      );

      expect(data.autoDismissAfter, const Duration(seconds: 5));
    });

    test('is null for an error toast so it stays until dismissed', () {
      const data = AppToastData(message: 'Failed', type: AppToastType.error);

      expect(data.autoDismissAfter, isNull);
    });
  });

  group('AppToast', () {
    late BuildContext scopeContext;

    Future<void> pumpHost(WidgetTester tester) {
      return tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppPalette.light]),
          home: AppToastScope(
            child: Builder(
              builder: (context) {
                scopeContext = context;
                return const SizedBox.expand();
              },
            ),
          ),
        ),
      );
    }

    testWidgets('shows the message', (tester) async {
      await pumpHost(tester);

      AppToast.show(scopeContext, message: 'Copied');
      await tester.pump();

      expect(find.text('Copied'), findsOneWidget);
    });

    testWidgets('auto-dismisses a plain toast after 3 seconds', (
      tester,
    ) async {
      await pumpHost(tester);
      AppToast.show(scopeContext, message: 'Copied');
      await tester.pump();

      await tester.pump(const Duration(milliseconds: 2900));
      expect(find.text('Copied'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
      expect(find.text('Copied'), findsNothing);
    });

    testWidgets('keeps a toast with an action for 5 seconds', (tester) async {
      await pumpHost(tester);
      AppToast.show(
        scopeContext,
        message: 'Deleted',
        actionLabel: 'Undo',
        onAction: () {},
      );
      await tester.pump();

      await tester.pump(const Duration(seconds: 4));
      expect(find.text('Deleted'), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('Deleted'), findsNothing);
    });

    testWidgets('keeps an error toast visible until dismissed', (
      tester,
    ) async {
      await pumpHost(tester);
      AppToast.show(scopeContext, message: 'Failed', type: AppToastType.error);
      await tester.pump();

      await tester.pump(const Duration(seconds: 10));

      expect(find.text('Failed'), findsOneWidget);
    });

    testWidgets('dismisses on swipe down', (tester) async {
      await pumpHost(tester);
      AppToast.show(scopeContext, message: 'Failed', type: AppToastType.error);
      await tester.pumpAndSettle();

      await tester.drag(find.text('Failed'), const Offset(0, 300));
      await tester.pumpAndSettle();

      expect(find.text('Failed'), findsNothing);
    });

    testWidgets('runs the action when it is tapped', (tester) async {
      var retried = false;
      await pumpHost(tester);
      AppToast.show(
        scopeContext,
        message: 'Failed',
        type: AppToastType.error,
        actionLabel: 'Retry',
        onAction: () => retried = true,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Retry'));

      expect(retried, isTrue);
    });

    testWidgets('dismisses after the action is tapped', (tester) async {
      await pumpHost(tester);
      AppToast.show(
        scopeContext,
        message: 'Failed',
        type: AppToastType.error,
        actionLabel: 'Retry',
        onAction: () {},
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(find.text('Failed'), findsNothing);
    });

    testWidgets('replaces the visible toast with a new one', (tester) async {
      await pumpHost(tester);
      AppToast.show(scopeContext, message: 'First');
      await tester.pump();

      AppToast.show(scopeContext, message: 'Second');
      await tester.pump();

      expect(find.text('First'), findsNothing);
      expect(find.text('Second'), findsOneWidget);
    });

    testWidgets('hide removes the visible toast', (tester) async {
      await pumpHost(tester);
      AppToast.show(scopeContext, message: 'Failed', type: AppToastType.error);
      await tester.pump();

      AppToast.hide(scopeContext);
      await tester.pump();

      expect(find.text('Failed'), findsNothing);
    });
  });
}
