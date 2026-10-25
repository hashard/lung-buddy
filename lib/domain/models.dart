enum DayStatus { won, lost, inProgress, empty }

class DayResult {
  final DateTime date;
  final int smokeCount;
  final int? budget;
  final DayStatus status;

  const DayResult({
    required this.date,
    required this.smokeCount,
    required this.budget,
    required this.status,
  });
}

enum MascotMood { happy, chill, worried, celebrate }

class StreakInfo {
  final int current;
  final int best;

  const StreakInfo({required this.current, required this.best});
}

enum ChallengeKind {
  underYesterdayForDays,
  underBudgetForDays,
  underBaselineForDays,
  noSmokesBeforeNoonForDays,
  weekendUnderBudget,
}

class ChallengeDef {
  final String id;
  final String title;
  final String description;
  final ChallengeKind kind;
  final int targetDays;
  final String rewardId;

  const ChallengeDef({
    required this.id,
    required this.title,
    required this.description,
    required this.kind,
    required this.targetDays,
    required this.rewardId,
  });
}

enum ChallengeStatus { available, active, completed }

class ChallengeProgress {
  final String catalogId;
  final ChallengeStatus status;
  final int daysCompleted;
  final int targetDays;

  const ChallengeProgress({
    required this.catalogId,
    required this.status,
    required this.daysCompleted,
    required this.targetDays,
  });
}
