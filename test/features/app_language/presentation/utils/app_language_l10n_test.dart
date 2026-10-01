import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/features/app_language/domain/entities/app_language.dart';
import 'package:transly_ai/features/app_language/presentation/utils/app_language_l10n.dart';
import 'package:transly_ai/l10n/app_localizations.dart';

void main() {
  Future<BuildContext> contextIn(WidgetTester tester, Locale locale) async {
    late BuildContext result;
    await tester.pumpWidget(
      Localizations(
        locale: locale,
        delegates: AppLocalizations.localizationsDelegates,
        child: Builder(
          builder: (context) {
            result = context;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    return result;
  }

  test('offers one language per supported locale', () {
    expect(appLanguageCodes(), [
      for (final locale in AppLocalizations.supportedLocales)
        locale.languageCode,
    ]);
  });

  test('reads native names and badges from each language\'s own file', () {
    expect(nativeLanguageName('ar'), 'العربية');
    expect(nativeLanguageName('en'), 'English');
    expect(appLanguageBadge('ar'), 'ع');
    expect(appLanguageBadge('en'), 'EN');
  });

  test('maps the device language to no locale', () {
    expect(appLanguageLocale(AppLanguage.device), isNull);
    expect(appLanguageLocale(const AppLanguage('ar')), const Locale('ar'));
  });

  testWidgets('resolves the device language like MaterialApp does', (
    tester,
  ) async {
    tester.platformDispatcher.localesTestValue = const [Locale('ar', 'EG')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    final context = await contextIn(tester, const Locale('en'));

    expect(deviceResolvedLanguageCode(context), 'ar');
  });

  testWidgets('an unsupported device language resolves to the first locale', (
    tester,
  ) async {
    tester.platformDispatcher.localesTestValue = const [Locale('xx')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    final context = await contextIn(tester, const Locale('en'));

    expect(
      deviceResolvedLanguageCode(context),
      AppLocalizations.supportedLocales.first.languageCode,
    );
  });

  testWidgets('the secondary name is the language in the UI language', (
    tester,
  ) async {
    final context = await contextIn(tester, const Locale('ar'));

    expect(secondaryLanguageName(context, 'en'), 'الإنجليزية');
  });

  testWidgets('the UI language itself gets its English name', (tester) async {
    final context = await contextIn(tester, const Locale('ar'));

    expect(secondaryLanguageName(context, 'ar'), 'Arabic');
  });

  testWidgets('no secondary name when every name repeats the title', (
    tester,
  ) async {
    final context = await contextIn(tester, const Locale('en'));

    expect(secondaryLanguageName(context, 'en'), isNull);
  });
}
