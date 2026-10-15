import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/constants/app_icons.dart';
import 'package:transly_ai/core/theme/app_palette.dart';
import 'package:transly_ai/core/widgets/app_back_button.dart';
import 'package:transly_ai/core/widgets/app_svg_icon.dart';
import 'package:transly_ai/l10n/app_localizations.dart';

import '../../helpers/svg_icon_finder.dart';

void main() {
  Future<void> pumpButton(WidgetTester tester, Locale locale) {
    return tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [AppPalette.light]),
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Center(child: AppBackButton(onTap: () {})),
      ),
    );
  }

  // The chevron mirrors itself via `matchTextDirection`; swapping the glyph
  // by hand as well flipped it twice, pointing it forward in Arabic.
  testWidgets('uses the self-mirroring back chevron in RTL', (tester) async {
    await pumpButton(tester, const Locale('ar'));

    final icon = tester.widget<AppSvgIcon>(findSvgIcon(AppIcons.back));
    expect(icon.matchTextDirection, isTrue);
  });

  testWidgets('uses the same back chevron in LTR', (tester) async {
    await pumpButton(tester, const Locale('en'));

    expect(findSvgIcon(AppIcons.back), findsOneWidget);
  });
}
