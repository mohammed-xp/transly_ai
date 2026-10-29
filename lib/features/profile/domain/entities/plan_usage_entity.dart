/// The user's plan and how much of its character quota the current window
/// has consumed (`GET /api/v1/usage`), with the conversation seconds left.
class PlanUsageEntity {
  const PlanUsageEntity({
    required this.plan,
    required this.charactersLimit,
    required this.charactersUsed,
    required this.resetsAt,
    this.audioSecondsLimit,
    this.audioSecondsRemaining,
  });

  static const String freePlan = 'free';

  final String plan;
  final int charactersLimit;
  final int charactersUsed;
  final DateTime resetsAt;

  /// Conversation-mode seconds in the window; null when the server doesn't
  /// report them.
  final int? audioSecondsLimit;
  final int? audioSecondsRemaining;

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
