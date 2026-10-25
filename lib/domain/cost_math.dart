import 'day_evaluator.dart';

class CostMath {
  static double perCigarette({
    required double packCost,
    required int cigsPerPack,
  }) {
    if (cigsPerPack <= 0) return 0;
    return packCost / cigsPerPack;
  }

  static double spend({
    required int cigaretteCount,
    required double packCost,
    required int cigsPerPack,
  }) {
    return cigaretteCount *
        perCigarette(packCost: packCost, cigsPerPack: cigsPerPack);
  }

  /// Monday of the calendar week containing [day] (local).
  static DateTime weekStart(DateTime day) {
    final d = DayEvaluator.dateOnly(day);
    return d.subtract(Duration(days: d.weekday - DateTime.monday));
  }

  static DateTime weekEnd(DateTime day) =>
      weekStart(day).add(const Duration(days: 6));
}

class WeekMoneySummary {
  final DateTime weekStart;
  final DateTime weekEnd;
  final int smoked;
  final int budgeted;
  final double costSmoked;
  final double costBudgeted;
  final double packCost;
  final int cigsPerPack;

  const WeekMoneySummary({
    required this.weekStart,
    required this.weekEnd,
    required this.smoked,
    required this.budgeted,
    required this.costSmoked,
    required this.costBudgeted,
    required this.packCost,
    required this.cigsPerPack,
  });

  int get cigDiff => smoked - budgeted;

  double get costDiff => costSmoked - costBudgeted;

  bool get overBudget => cigDiff > 0;
}
