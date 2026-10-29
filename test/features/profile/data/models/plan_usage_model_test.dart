import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/features/profile/data/models/plan_usage_model.dart';

void main() {
  test('parses the backend UsageResponseDto into an entity', () {
    final model = PlanUsageModel.fromJson({
      'plan': 'free',
      'charactersLimit': 5000,
      'charactersUsed': 3500,
      'charactersRemaining': 1500,
      'resetsAt': '2026-09-29T00:00:00+00:00',
    });

    final entity = model.toEntity();

    expect(entity.plan, 'free');
    expect(entity.charactersLimit, 5000);
    expect(entity.charactersUsed, 3500);
    expect(entity.resetsAt, DateTime.utc(2026, 9, 29));
  });

  test('reads the conversation seconds when the server sends them', () {
    final entity = PlanUsageModel.fromJson({
      'plan': 'free',
      'charactersLimit': 1500,
      'charactersUsed': 120,
      'audioSecondsLimit': 300,
      'audioSecondsUsed': 42,
      'audioSecondsRemaining': 258,
      'resetsAt': '2026-10-29T00:00:00+00:00',
    }).toEntity();

    expect(entity.audioSecondsLimit, 300);
    expect(entity.audioSecondsRemaining, 258);
  });

  test('leaves the conversation seconds unknown when they are missing', () {
    final entity = PlanUsageModel.fromJson({
      'plan': 'free',
      'charactersLimit': 1500,
      'charactersUsed': 120,
      'resetsAt': '2026-10-29T00:00:00+00:00',
    }).toEntity();

    expect(entity.audioSecondsRemaining, isNull);
  });

  test('throws when a required field is missing', () {
    expect(
      () => PlanUsageModel.fromJson({'plan': 'free'}),
      throwsA(isA<TypeError>()),
    );
  });
}
