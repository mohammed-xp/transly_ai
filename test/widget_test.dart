import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/app.dart';
import 'package:transly_ai/core/theme/app_colors.dart';

void main() {
  testWidgets('TranslyApp builds and applies the design-system theme',
      (tester) async {
    await tester.pumpWidget(const TranslyApp());
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.theme!.colorScheme.primary, AppColors.primary);
    expect(app.darkTheme!.colorScheme.primary, AppColors.accentDark);
    expect(app.themeMode, ThemeMode.system);
  });
}
