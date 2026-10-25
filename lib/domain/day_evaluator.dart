import 'models.dart';

class DayEvaluator {
  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static DayResult evaluate({
    required DateTime date,
    required int smokeCount,
    required int? budget,
    required DateTime now,
    bool hadAnyBudgetOrOpen = true,
  }) {
    final d = dateOnly(date);
    final today = dateOnly(now);
    if (!hadAnyBudgetOrOpen && smokeCount == 0 && budget == null) {
      return DayResult(
        date: d,
        smokeCount: 0,
        budget: null,
        status: DayStatus.empty,
      );
    }
    final b = budget;
    if (b == null) {
      return DayResult(
        date: d,
        smokeCount: smokeCount,
        budget: null,
        status: DayStatus.empty,
      );
    }
    final isToday = d == today;
    if (smokeCount > b) {
      return DayResult(
        date: d,
        smokeCount: smokeCount,
        budget: b,
        status: DayStatus.lost,
      );
    }
    if (isToday) {
      return DayResult(
        date: d,
        smokeCount: smokeCount,
        budget: b,
        status: DayStatus.inProgress,
      );
    }
    return DayResult(
      date: d,
      smokeCount: smokeCount,
      budget: b,
      status: DayStatus.won,
    );
  }
}
