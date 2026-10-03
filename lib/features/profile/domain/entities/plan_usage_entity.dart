/// The user's plan and how much of its character quota the current window
/// has consumed (`GET /api/v1/usage`).
class PlanUsageEntity {
  const PlanUsageEntity({
    required this.plan,
    required this.charactersLimit,
    required this.charactersUsed,
    required this.resetsAt,
  });

  static const String freePlan = 'free';

  final String plan;
  final int charactersLimit;
  final int charactersUsed;
  final DateTime resetsAt;

  /// Every plan other than the free one is a paid Pro plan. A null [plan]
  /// (none known yet) is not Pro.
  static bool isProPlan(String? plan) => plan != null && plan != freePlan;

  bool get isFree => plan == freePlan;

  bool get isPro => isProPlan(plan);

  double get usedFraction {
    if (charactersLimit <= 0) return 1;
    return (charactersUsed / charactersLimit).clamp(0.0, 1.0);
  }

  /// Rounded down so a nearly-spent quota never reads as 100% used while
  /// characters are still left.
  int get usedPercent => (usedFraction * 100).floor();

  int get remainingPercent => 100 - usedPercent;

  Duration timeUntilReset(DateTime now) {
    final remaining = resetsAt.difference(now);
    return remaining.isNegative ? Duration.zero : remaining;
  }
}
