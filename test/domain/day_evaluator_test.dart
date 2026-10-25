import 'package:flutter_test/flutter_test.dart';
import 'package:lung_buddy/domain/day_evaluator.dart';
import 'package:lung_buddy/domain/models.dart';

void main() {
  final day = DateTime(2026, 10, 23);

  test('under budget is day won when day is complete', () {
    final r = DayEvaluator.evaluate(
      date: day,
      smokeCount: 4,
      budget: 10,
      now: DateTime(2026, 10, 24, 0, 1),
    );
    expect(r.status, DayStatus.won);
    expect(r.smokeCount, 4);
  });

  test('over budget is lost when day is complete', () {
    final r = DayEvaluator.evaluate(
      date: day,
      smokeCount: 12,
      budget: 10,
      now: DateTime(2026, 10, 24),
    );
    expect(r.status, DayStatus.lost);
  });

  test('today under budget is inProgress, not won yet', () {
    final r = DayEvaluator.evaluate(
      date: day,
      smokeCount: 3,
      budget: 10,
      now: DateTime(2026, 10, 23, 15),
    );
    expect(r.status, DayStatus.inProgress);
  });

  test('today over budget is lost even before midnight', () {
    final r = DayEvaluator.evaluate(
      date: day,
      smokeCount: 11,
      budget: 10,
      now: DateTime(2026, 10, 23, 15),
    );
    expect(r.status, DayStatus.lost);
  });

  test('no budget and no events is empty (breaks streak later)', () {
    final r = DayEvaluator.evaluate(
      date: day,
      smokeCount: 0,
      budget: null,
      now: DateTime(2026, 10, 24),
      hadAnyBudgetOrOpen: false,
    );
    expect(r.status, DayStatus.empty);
  });
}
