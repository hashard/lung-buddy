import 'day_evaluator.dart';
import 'models.dart';

class StreakCalculator {
  static StreakInfo compute({
    required List<DayResult> days,
    required DateTime today,
    required int bestEver,
  }) {
    final byDate = {
      for (final r in days) DayEvaluator.dateOnly(r.date): r,
    };
    var cursor = DayEvaluator.dateOnly(today).subtract(const Duration(days: 1));
    var current = 0;
    while (true) {
      final r = byDate[cursor];
      if (r == null || r.status != DayStatus.won) break;
      current++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    final best = current > bestEver ? current : bestEver;
    return StreakInfo(current: current, best: best);
  }
}
