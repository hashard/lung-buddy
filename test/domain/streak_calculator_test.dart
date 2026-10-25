import 'package:flutter_test/flutter_test.dart';
import 'package:lung_buddy/domain/models.dart';
import 'package:lung_buddy/domain/streak_calculator.dart';

void main() {
  DateTime d(int day) => DateTime(2026, 10, day);

  DayResult won(int day) => DayResult(
        date: d(day),
        smokeCount: 2,
        budget: 10,
        status: DayStatus.won,
      );
  DayResult lost(int day) => DayResult(
        date: d(day),
        smokeCount: 12,
        budget: 10,
        status: DayStatus.lost,
      );
  DayResult empty(int day) => DayResult(
        date: d(day),
        smokeCount: 0,
        budget: null,
        status: DayStatus.empty,
      );
  DayResult progress(int day) => DayResult(
        date: d(day),
        smokeCount: 2,
        budget: 10,
        status: DayStatus.inProgress,
      );

  test('current streak counts consecutive completed wins ending yesterday', () {
    final info = StreakCalculator.compute(
      days: [won(20), won(21), won(22), progress(23)],
      today: d(23),
      bestEver: 5,
    );
    expect(info.current, 3);
    expect(info.best, 5);
  });

  test('empty day breaks streak', () {
    final info = StreakCalculator.compute(
      days: [won(20), empty(21), won(22)],
      today: d(23),
      bestEver: 2,
    );
    expect(info.current, 1);
  });

  test('lost day breaks streak', () {
    final info = StreakCalculator.compute(
      days: [won(21), lost(22), progress(23)],
      today: d(23),
      bestEver: 10,
    );
    expect(info.current, 0);
  });

  test('updates best when current exceeds bestEver', () {
    final info = StreakCalculator.compute(
      days: [won(21), won(22)],
      today: d(23),
      bestEver: 1,
    );
    expect(info.current, 2);
    expect(info.best, 2);
  });
}
