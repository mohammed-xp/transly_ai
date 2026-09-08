import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/theme/app_theme.dart';
import 'package:transly_ai/core/widgets/coming_soon_panel.dart';

void main() {
  group('ComingSoonPanel', () {
    testWidgets('renders the icon, title and message with no Scaffold '
        'ancestor', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          // Bare Material, not Scaffold — the panel is designed to sit inside
          // a shell that already provides its own Scaffold, so it must not
          // require one of its own.
          home: const Material(
            child: ComingSoonPanel(
              icon: Icons.mic_none_rounded,
              title: 'Voice mode',
              message: 'Coming soon.',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.mic_none_rounded), findsOneWidget);
      expect(find.text('Voice mode'), findsOneWidget);
      expect(find.text('Coming soon.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
