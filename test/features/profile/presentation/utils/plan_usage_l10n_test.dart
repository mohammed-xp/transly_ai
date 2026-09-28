import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/features/profile/presentation/utils/plan_usage_l10n.dart';

void main() {
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
