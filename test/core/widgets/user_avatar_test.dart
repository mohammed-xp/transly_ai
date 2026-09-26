import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/theme/app_palette.dart';
import 'package:transly_ai/core/widgets/user_avatar.dart';

void main() {
  Future<void> pumpAvatar(WidgetTester tester, String? name) {
    return tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [AppPalette.light]),
        home: Center(child: UserAvatar(name: name, size: 44, ringWidth: 2)),
      ),
    );
  }

  testWidgets('shows the uppercased first letter of a Latin name', (
    tester,
  ) async {
    await pumpAvatar(tester, 'ahmed');

    expect(find.text('A'), findsOneWidget);
  });

  testWidgets('shows the first letter of an Arabic name', (tester) async {
    await pumpAvatar(tester, 'أحمد');

    expect(find.text('أ'), findsOneWidget);
  });

  testWidgets('ignores leading whitespace', (tester) async {
    await pumpAvatar(tester, '  sara');

    expect(find.text('S'), findsOneWidget);
  });

  testWidgets('falls back to a person icon for a blank name', (tester) async {
    await pumpAvatar(tester, '   ');

    expect(find.byIcon(Icons.person_rounded), findsOneWidget);
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('falls back to a person icon when there is no name', (
    tester,
  ) async {
    await pumpAvatar(tester, null);

    expect(find.byIcon(Icons.person_rounded), findsOneWidget);
  });
}
