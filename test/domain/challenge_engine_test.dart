import 'package:flutter_test/flutter_test.dart';
import 'package:lung_buddy/domain/challenge_catalog.dart';
import 'package:lung_buddy/domain/challenge_engine.dart';
import 'package:lung_buddy/domain/models.dart';

void main() {
  DateTime d(int day) => DateTime(2026, 10, day);

  DayResult won(int day, {int count = 2, int budget = 10}) => DayResult(
        date: d(day),
        smokeCount: count,
        budget: budget,
        status: DayStatus.won,
      );

  DayResult lost(int day) => DayResult(
        date: d(day),
        smokeCount: 12,
        budget: 10,
        status: DayStatus.lost,
      );

  final underBudget = ChallengeCatalog.byId('under_budget_5')!;

  test('underBudgetForDays increments on won days', () {
    final progress = ChallengeEngine.evaluate(
      def: underBudget,
      startedOn: d(18),
      daysSinceStart: [won(18), won(19), won(20)],
      baseline: 15,
      smokeTimestamps: const [],
      today: d(21),
    );
    expect(progress.status, ChallengeStatus.active);
    expect(progress.daysCompleted, 3);
  });

  test('underBudgetForDays resets on loss', () {
    final progress = ChallengeEngine.evaluate(
      def: underBudget,
      startedOn: d(18),
      daysSinceStart: [won(18), won(19), lost(20), won(21)],
      baseline: 15,
      smokeTimestamps: const [],
      today: d(22),
    );
    expect(progress.status, ChallengeStatus.active);
    expect(progress.daysCompleted, 1);
  });

  test('underBudgetForDays completes at target', () {
    final progress = ChallengeEngine.evaluate(
      def: underBudget,
      startedOn: d(10),
      daysSinceStart: [
        won(10),
        won(11),
        won(12),
        won(13),
        won(14),
      ],
      baseline: 15,
      smokeTimestamps: const [],
      today: d(15),
    );
    expect(progress.status, ChallengeStatus.completed);
    expect(progress.daysCompleted, 5);
  });
}
