import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/features/profile/domain/entities/plan_usage_entity.dart';

void main() {
  final resetsAt = DateTime.utc(2026, 9, 29);

  PlanUsageEntity usage({
    String plan = PlanUsageEntity.freePlan,
    int limit = 5000,
    required int used,
  }) => PlanUsageEntity(
    plan: plan,
    charactersLimit: limit,
    charactersUsed: used,
    resetsAt: resetsAt,
  );

  test('splits the quota into used and remaining percent', () {
    final u = usage(used: 3500);

    expect(u.usedFraction, 0.7);
    expect(u.usedPercent, 70);
    expect(u.remainingPercent, 30);
  });

  test('rounds used percent down so a nearly-spent quota is not 100%', () {
    final u = usage(used: 4999);

    expect(u.usedPercent, 99);
    expect(u.remainingPercent, 1);
  });

  test('caps usage at the limit when the backend reports more', () {
    final u = usage(used: 6000);

    expect(u.usedFraction, 1);
    expect(u.usedPercent, 100);
    expect(u.remainingPercent, 0);
  });

  test('treats a zero limit as fully used instead of dividing by zero', () {
    final u = usage(limit: 0, used: 0);

    expect(u.usedFraction, 1);
    expect(u.usedPercent, 100);
  });

  test('timeUntilReset is the time left before resetsAt', () {
    final now = resetsAt.subtract(const Duration(hours: 6));

    expect(usage(used: 0).timeUntilReset(now), const Duration(hours: 6));
  });

  test('timeUntilReset is zero once resetsAt has passed', () {
    final now = resetsAt.add(const Duration(minutes: 5));

    expect(usage(used: 0).timeUntilReset(now), Duration.zero);
  });

  test('isFree is true only for the free plan', () {
    expect(usage(used: 0).isFree, isTrue);
    expect(usage(plan: 'pro_monthly', used: 0).isFree, isFalse);
  });
}
