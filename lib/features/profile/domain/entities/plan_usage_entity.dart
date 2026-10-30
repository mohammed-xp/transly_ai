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

  bool get charactersExhausted => usedFraction >= 1;

  /// Null when the server sends no conversation seconds, or a zero limit:
  /// a plan without conversation time, not one that has spent it.
  int? get audioSecondsUsed {
    final limit = audioSecondsLimit;
    final remaining = audioSecondsRemaining;
    if (limit == null || limit <= 0 || remaining == null) return null;
    return (limit - remaining).clamp(0, limit);
  }

  bool get hasAudioQuota => audioSecondsUsed != null;

  double? get audioUsedFraction {
    final limit = audioSecondsLimit;
    final used = audioSecondsUsed;
    if (limit == null || used == null) return null;
    return used / limit;
  }

  bool get audioExhausted {
    final remaining = audioSecondsRemaining;
    return hasAudioQuota && remaining != null && remaining <= 0;
  }

  bool get conversationAvailable => hasAudioQuota && !audioExhausted;

  /// Rounded down, like [usedPercent], so the conversation never reads as
  /// fully used while seconds are still left; the whole limit once they are
  /// not.
  int? get audioMinutesUsed {
    final used = audioSecondsUsed;
    if (used == null) return null;
    return audioExhausted ? audioMinutesLimit : used ~/ 60;
  }

  /// Rounded up, so the used minutes stay below it while seconds are left.
  int? get audioMinutesLimit {
    final limit = audioSecondsLimit;
    if (limit == null || !hasAudioQuota) return null;
    return (limit / 60).ceil();
  }

  Duration timeUntilReset(DateTime now) {
    final remaining = resetsAt.difference(now);
    return remaining.isNegative ? Duration.zero : remaining;
  }
}
