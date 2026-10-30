import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/features/profile/presentation/utils/plan_usage_l10n.dart';
import 'package:transly_ai/l10n/app_localizations.dart';

void main() {
  group('Arabic conversation minutes', () {
    final ar = lookupAppLocalizations(const Locale('ar'));
    String minutes(int limit) =>
        ar.profileUsageMinutes(limit, 'X', limit.toString());

    test('a one-minute limit takes the singular', () {
      expect(minutes(1), 'X من دقيقة');
    });

    test('a two-minute limit takes the dual', () {
      expect(minutes(2), 'X من دقيقتين');
    });

    test('three to ten minutes take the plural', () {
      expect(minutes(3), 'X من 3 دقائق');
      expect(minutes(10), 'X من 10 دقائق');
    });

    test('eleven minutes and more take the singular noun', () {
      expect(minutes(11), 'X من 11 دقيقة');
      expect(minutes(100), 'X من 100 دقيقة');
    });
  });

  test('counts in hours once an hour or more is left, rounding up', () {
    expect(resetCountdown(const Duration(hours: 5, minutes: 10)), (
      unit: ResetUnit.hours,
      value: 6,
    ));
  });

  test('a whole number of hours is not rounded up', () {
    expect(resetCountdown(const Duration(hours: 6)), (
      unit: ResetUnit.hours,
      value: 6,
    ));
  });

  test('a partial last minute rounds up to a full hour', () {
    expect(resetCountdown(const Duration(minutes: 59, seconds: 30)), (
      unit: ResetUnit.hours,
      value: 1,
    ));
  });

  test('counts in minutes when less than an hour is left', () {
    expect(resetCountdown(const Duration(minutes: 45)), (
      unit: ResetUnit.minutes,
      value: 45,
    ));
  });

  test('never counts down below one minute', () {
    expect(resetCountdown(Duration.zero), (unit: ResetUnit.minutes, value: 1));
    expect(resetCountdown(const Duration(seconds: 20)), (
      unit: ResetUnit.minutes,
      value: 1,
    ));
  });
}
