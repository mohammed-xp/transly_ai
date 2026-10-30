import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/features/profile/domain/entities/plan_usage_entity.dart';

void main() {
  final resetsAt = DateTime.utc(2026, 9, 29);

  PlanUsageEntity usage({
    String plan = PlanUsageEntity.freePlan,
    int limit = 5000,
    required int used,
    int? audioLimit,
    int? audioRemaining,
  }) => PlanUsageEntity(
    plan: plan,
    charactersLimit: limit,
    charactersUsed: used,
    resetsAt: resetsAt,
    audioSecondsLimit: audioLimit,
    audioSecondsRemaining: audioRemaining,
  );

  test('reads the used share of the quota as a fraction and percent', () {
    final u = usage(used: 3500);

    expect(u.usedFraction, 0.7);
    expect(u.usedPercent, 70);
  });

  test('rounds used percent down so a nearly-spent quota is not 100%', () {
    final u = usage(used: 4999);

    expect(u.usedPercent, 99);
  });

  test('caps usage at the limit when the backend reports more', () {
    final u = usage(used: 6000);

    expect(u.usedFraction, 1);
    expect(u.usedPercent, 100);
  });

  test('treats a zero limit as fully used instead of dividing by zero', () {
    final u = usage(limit: 0, used: 0);

    expect(u.usedFraction, 1);
    expect(u.usedPercent, 100);
  });

  test('characters are exhausted only once the whole quota is used', () {
    expect(usage(used: 4999).charactersExhausted, isFalse);
    expect(usage(used: 5000).charactersExhausted, isTrue);
  });

  test('splits the conversation seconds into used minutes of the limit', () {
    final u = usage(used: 0, audioLimit: 900, audioRemaining: 420);

    expect(u.hasAudioQuota, isTrue);
    expect(u.audioSecondsUsed, 480);
    expect(u.audioUsedFraction, closeTo(0.533, 0.001));
    expect(u.audioMinutesUsed, 8);
    expect(u.audioMinutesLimit, 15);
    expect(u.audioExhausted, isFalse);
  });

  test('rounds used minutes down so time left never reads as all used', () {
    final u = usage(used: 0, audioLimit: 900, audioRemaining: 1);

    expect(u.audioMinutesUsed, 14);
    expect(u.audioExhausted, isFalse);
  });

  test('rounds the minute limit up when it is not whole minutes', () {
    expect(
      usage(used: 0, audioLimit: 90, audioRemaining: 90).audioMinutesLimit,
      2,
    );
  });

  test('conversation is exhausted once no seconds are left', () {
    final u = usage(used: 0, audioLimit: 900, audioRemaining: 0);

    expect(u.audioExhausted, isTrue);
    expect(u.audioUsedFraction, 1);
    expect(u.audioMinutesUsed, 15);
  });

  test('caps conversation usage when the backend reports negative time', () {
    final u = usage(used: 0, audioLimit: 900, audioRemaining: -30);

    expect(u.audioSecondsUsed, 900);
    expect(u.audioUsedFraction, 1);
    expect(u.audioExhausted, isTrue);
  });

  test('reads a spent limit of part minutes as all of it used', () {
    final u = usage(used: 0, audioLimit: 90, audioRemaining: 0);

    expect(u.audioMinutesUsed, 2);
    expect(u.audioMinutesLimit, 2);
  });

  test('reads more seconds left than the limit as none used', () {
    final u = usage(used: 0, audioLimit: 900, audioRemaining: 1000);

    expect(u.audioSecondsUsed, 0);
    expect(u.audioExhausted, isFalse);
  });

  test('treats a zero conversation limit as a plan without conversation', () {
    final u = usage(used: 0, audioLimit: 0, audioRemaining: 0);

    expect(u.hasAudioQuota, isFalse);
    expect(u.audioUsedFraction, isNull);
    expect(u.audioExhausted, isFalse);
  });

  test('leaves the conversation quota unknown without a limit', () {
    expect(usage(used: 0, audioRemaining: 300).hasAudioQuota, isFalse);
  });

  test('conversation is available only while seconds are left', () {
    expect(
      usage(used: 0, audioLimit: 900, audioRemaining: 1).conversationAvailable,
      isTrue,
    );
    expect(
      usage(used: 0, audioLimit: 900, audioRemaining: 0).conversationAvailable,
      isFalse,
    );
    expect(usage(used: 0).conversationAvailable, isFalse);
  });

  test(
    'leaves the conversation quota unknown when the seconds are missing',
    () {
      final u = usage(used: 0, audioLimit: 900);

      expect(u.hasAudioQuota, isFalse);
      expect(u.audioSecondsUsed, isNull);
      expect(u.audioUsedFraction, isNull);
      expect(u.audioMinutesUsed, isNull);
      expect(u.audioMinutesLimit, isNull);
      expect(u.audioExhausted, isFalse);
    },
  );

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

  test('isPro is true for every plan but the free one', () {
    expect(usage(plan: 'pro_monthly', used: 0).isPro, isTrue);
    expect(usage(used: 0).isPro, isFalse);
  });

  test('isProPlan is false when no plan is known yet', () {
    expect(PlanUsageEntity.isProPlan(null), isFalse);
  });
}
