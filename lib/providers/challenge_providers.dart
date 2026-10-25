import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/challenge_catalog.dart';
import '../domain/challenge_engine.dart';
import '../domain/day_evaluator.dart';
import '../domain/models.dart';
import 'database_provider.dart';
import 'home_providers.dart';

class ChallengeListItem {
  final ChallengeDef def;
  final ChallengeStatus status;
  final int daysCompleted;

  const ChallengeListItem({
    required this.def,
    required this.status,
    required this.daysCompleted,
  });
}

final challengeListProvider =
    FutureProvider.autoDispose<List<ChallengeListItem>>((ref) async {
  final challengeRepo = ref.watch(challengeRepositoryProvider);
  final smokeRepo = ref.watch(smokeRepositoryProvider);
  final settingsRepo = ref.watch(settingsRepositoryProvider);
  final rows = await challengeRepo.allRows();
  final byId = {for (final r in rows) r.catalogId: r};
  final settings = await settingsRepo.requireSettings();
  final now = DateTime.now();
  final today = DayEvaluator.dateOnly(now);

  final days = <DayResult>[];
  for (var i = 60; i >= 0; i--) {
    final date = today.subtract(Duration(days: i));
    final dayCount = await smokeRepo.countForDate(date);
    final dayBudget = await settingsRepo.budgetForDate(date);
    final hadData = dayBudget != null || dayCount > 0 || date == today;
    days.add(
      DayEvaluator.evaluate(
        date: date,
        smokeCount: dayCount,
        budget: hadData ? (dayBudget ?? settings.defaultBudget) : null,
        now: now,
        hadAnyBudgetOrOpen: hadData,
      ),
    );
  }

  final items = <ChallengeListItem>[];
  for (final def in ChallengeCatalog.packs) {
    final row = byId[def.id];
    if (row == null) {
      items.add(ChallengeListItem(
        def: def,
        status: ChallengeStatus.available,
        daysCompleted: 0,
      ));
      continue;
    }
    if (row.status == 'completed') {
      items.add(ChallengeListItem(
        def: def,
        status: ChallengeStatus.completed,
        daysCompleted: row.daysCompleted,
      ));
      continue;
    }
    if (row.startedAt == null) {
      items.add(ChallengeListItem(
        def: def,
        status: ChallengeStatus.available,
        daysCompleted: 0,
      ));
      continue;
    }
    final start = DayEvaluator.dateOnly(row.startedAt!);
    final events = await smokeRepo.eventsBetween(
      start.subtract(const Duration(days: 1)),
      today.add(const Duration(days: 1)),
    );
    final progress = ChallengeEngine.evaluate(
      def: def,
      startedOn: start,
      daysSinceStart: days.where((d) => !d.date.isBefore(start)).toList(),
      baseline: settings.usualBaseline,
      smokeTimestamps: events.map((e) => e.timestamp).toList(),
      today: today,
    );
    if (progress.status == ChallengeStatus.completed) {
      await challengeRepo.markCompleted(def.id, progress.daysCompleted);
      await challengeRepo.unlockReward(def.rewardId);
    }
    items.add(ChallengeListItem(
      def: def,
      status: progress.status,
      daysCompleted: progress.daysCompleted,
    ));
  }
  return items;
});

class ChallengeActions {
  ChallengeActions(this._ref);

  final Ref _ref;

  Future<void> start(String catalogId) async {
    await _ref.read(challengeRepositoryProvider).start(catalogId, DateTime.now());
    _ref.invalidate(challengeListProvider);
    _ref.invalidate(homeVmProvider);
  }

  Future<void> abandon(String catalogId) async {
    await _ref.read(challengeRepositoryProvider).abandon(catalogId);
    _ref.invalidate(challengeListProvider);
    _ref.invalidate(homeVmProvider);
  }
}

final challengeActionsProvider =
    Provider<ChallengeActions>((ref) => ChallengeActions(ref));
