import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/l10n/language_badge.dart';

void main() {
  test('uses the mark from the ARB file of an app language', () {
    expect(languageBadge('ar'), 'ع');
    expect(languageBadge('en'), 'EN');
  });

  test('uses the upper-cased code for any other language', () {
    expect(languageBadge('de'), 'DE');
  });

  test('drops the region of a regional code', () {
    expect(languageBadge('zh-CN'), 'ZH');
  });
}
