import 'models.dart';

class ChallengeCatalog {
  static const packs = <ChallengeDef>[
    ChallengeDef(
      id: 'under_yesterday_3',
      title: 'Two under yesterday',
      description: 'Beat yesterday by 2+ smokes, three days in a row.',
      kind: ChallengeKind.underYesterdayForDays,
      targetDays: 3,
      rewardId: 'top_hat',
    ),
    ChallengeDef(
      id: 'under_budget_5',
      title: 'Budget boss',
      description: 'Stay at or under budget for 5 days.',
      kind: ChallengeKind.underBudgetForDays,
      targetDays: 5,
      rewardId: 'scarf_sunset',
    ),
    ChallengeDef(
      id: 'under_baseline_7',
      title: 'Below usual',
      description: 'Stay under your usual baseline for 7 days.',
      kind: ChallengeKind.underBaselineForDays,
      targetDays: 7,
      rewardId: 'shades',
    ),
    ChallengeDef(
      id: 'morning_clear_3',
      title: 'Clear mornings',
      description: 'No smokes before noon for 3 days.',
      kind: ChallengeKind.noSmokesBeforeNoonForDays,
      targetDays: 3,
      rewardId: 'sun_visors',
    ),
    ChallengeDef(
      id: 'weekend_budget',
      title: 'Chill weekend',
      description: 'Stay under budget Saturday and Sunday.',
      kind: ChallengeKind.weekendUnderBudget,
      targetDays: 2,
      rewardId: 'couch_hat',
    ),
    ChallengeDef(
      id: 'under_budget_7',
      title: 'Smoke-lite week',
      description: 'Stay at or under budget for 7 days.',
      kind: ChallengeKind.underBudgetForDays,
      targetDays: 7,
      rewardId: 'mustache',
    ),
    ChallengeDef(
      id: 'under_yesterday_5',
      title: 'Cut by two',
      description: 'Beat yesterday by 2+ smokes, five days in a row.',
      kind: ChallengeKind.underYesterdayForDays,
      targetDays: 5,
      rewardId: 'pirate_bandana',
    ),
    ChallengeDef(
      id: 'under_budget_3',
      title: 'Midweek mercy',
      description: 'Stay under budget for 3 days.',
      kind: ChallengeKind.underBudgetForDays,
      targetDays: 3,
      rewardId: 'frog_hat',
    ),
    ChallengeDef(
      id: 'morning_clear_5',
      title: 'Night owl trim',
      description: 'No smokes before noon for 5 days.',
      kind: ChallengeKind.noSmokesBeforeNoonForDays,
      targetDays: 5,
      rewardId: 'sleepy_cap',
    ),
    ChallengeDef(
      id: 'under_baseline_3',
      title: 'Soft launch',
      description: 'Stay under your usual baseline for 3 days.',
      kind: ChallengeKind.underBaselineForDays,
      targetDays: 3,
      rewardId: 'heart_specs',
    ),
    ChallengeDef(
      id: 'under_budget_10',
      title: 'Ten-day tidy',
      description: 'Stay at or under budget for 10 days.',
      kind: ChallengeKind.underBudgetForDays,
      targetDays: 10,
      rewardId: 'leaf_pin',
    ),
  ];

  static ChallengeDef? byId(String id) {
    for (final p in packs) {
      if (p.id == id) return p;
    }
    return null;
  }

  static ChallengeDef? byReward(String rewardId) {
    for (final p in packs) {
      if (p.rewardId == rewardId) return p;
    }
    return null;
  }
}
