import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../../../core/l10n/localized_digits.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/plan_usage_entity.dart';

enum ResetUnit { minutes, hours }

/// Whole units left until the quota resets, rounded up so the reset always
/// lands *within* the stated time. Under an hour counts in minutes, never
/// fewer than one.
({ResetUnit unit, int value}) resetCountdown(Duration remaining) {
  final minutes = (remaining.inSeconds / 60).ceil();
  if (minutes < 60) {
    return (unit: ResetUnit.minutes, value: math.max(1, minutes));
  }
  return (unit: ResetUnit.hours, value: (minutes / 60).ceil());
}

String resetCountdownLabel(BuildContext context, PlanUsageEntity usage) {
  final l10n = AppLocalizations.of(context)!;
  final (:unit, :value) = resetCountdown(usage.timeUntilReset(DateTime.now()));
  final count = localizedDigits(context, value);
  return switch (unit) {
    ResetUnit.minutes => l10n.profileUsageResetsInMinutes(value, count),
    ResetUnit.hours => l10n.profileUsageResetsInHours(value, count),
  };
}
