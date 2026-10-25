import 'day_evaluator.dart';
import 'models.dart';

class ChallengeEngine {
  static ChallengeProgress evaluate({
    required ChallengeDef def,
    required DateTime startedOn,
    required List<DayResult> daysSinceStart,
    required int baseline,
    required List<DateTime> smokeTimestamps,
    required DateTime today,
  }) {
    final start = DayEvaluator.dateOnly(startedOn);
    final todayOnly = DayEvaluator.dateOnly(today);
    final byDate = {
      for (final r in daysSinceStart) DayEvaluator.dateOnly(r.date): r,
    };

    var completed = 0;
    var cursor = start;
    while (cursor.isBefore(todayOnly)) {
      final ok = _dayMeets(
        def: def,
        date: cursor,
        byDate: byDate,
        baseline: baseline,
        smokeTimestamps: smokeTimestamps,
      );
      if (!ok) {
        if (_isConsecutiveKind(def.kind)) {
          completed = 0;
        }
      } else {
        completed++;
        if (completed >= def.targetDays) {
          return ChallengeProgress(
            catalogId: def.id,
            status: ChallengeStatus.completed,
            daysCompleted: def.targetDays,
            targetDays: def.targetDays,
          );
        }
      }
      cursor = cursor.add(const Duration(days: 1));
    }

    return ChallengeProgress(
      catalogId: def.id,
      status: ChallengeStatus.active,
      daysCompleted: completed.clamp(0, def.targetDays),
      targetDays: def.targetDays,
    );
  }

  static bool _isConsecutiveKind(ChallengeKind kind) {
    return kind != ChallengeKind.weekendUnderBudget;
  }

  static bool _dayMeets({
    required ChallengeDef def,
    required DateTime date,
    required Map<DateTime, DayResult> byDate,
    required int baseline,
    required List<DateTime> smokeTimestamps,
  }) {
    final d = DayEvaluator.dateOnly(date);
    final result = byDate[d];

    switch (def.kind) {
      case ChallengeKind.underBudgetForDays:
        return result?.status == DayStatus.won;

      case ChallengeKind.underBaselineForDays:
        if (result == null || result.status != DayStatus.won) return false;
        return result.smokeCount < baseline;

      case ChallengeKind.underYesterdayForDays:
        if (result == null || result.status != DayStatus.won) return false;
        final yesterday = byDate[d.subtract(const Duration(days: 1))];
        if (yesterday == null) return false;
        return result.smokeCount <= yesterday.smokeCount - 2;

      case ChallengeKind.noSmokesBeforeNoonForDays:
        if (result == null || result.budget == null) return false;
        if (result.status == DayStatus.empty) return false;
        final hasMorningSmoke = smokeTimestamps.any((t) {
          final td = DayEvaluator.dateOnly(t);
          return td == d && t.hour < 12;
        });
        return !hasMorningSmoke && result.status == DayStatus.won;

      case ChallengeKind.weekendUnderBudget:
        if (d.weekday != DateTime.saturday && d.weekday != DateTime.sunday) {
          return false;
        }
        return result?.status == DayStatus.won;
    }
  }
}
