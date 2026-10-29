import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/challenge_catalog.dart';
import '../domain/challenge_engine.dart';
import '../domain/cosmetic_catalog.dart';
import '../domain/cosmetic_loadout.dart';
import '../domain/cosmetic_slot.dart';
import '../domain/cosmetic_unlocks.dart';
import '../domain/cost_math.dart';
import '../domain/day_evaluator.dart';
import '../domain/mascot_mood.dart';
import '../domain/models.dart';
import '../domain/streak_calculator.dart';
import '../l10n/copy.dart';
import '../services/buddy_widget_sync.dart';
import 'database_provider.dart';

class HomeVm {
  final int count;
  final int budget;
  final StreakInfo streak;
  final MascotMood mood;
  final String mascotLine;
  final String buddyName;
  final ChallengeProgress? activeChallenge;
  final bool todayOnTrack;
  final DayStatus todayStatus;
  final double todaySpend;
  final double packCost;
  final int cigsPerPack;
  final double costPerCig;
  final bool isPlus;
  final CosmeticLoadout loadout;

  const HomeVm({
    required this.count,
    required this.budget,
    required this.streak,
    required this.mood,
    required this.mascotLine,
    required this.buddyName,
    required this.activeChallenge,
    required this.todayOnTrack,
    required this.todayStatus,
    required this.todaySpend,
    required this.packCost,
    required this.cigsPerPack,
    required this.costPerCig,
    required this.isPlus,
    required this.loadout,
  });

  CosmeticDef get primaryCosmetic => loadout.ids.isEmpty
      ? CosmeticCatalog.none
      : CosmeticCatalog.byId(loadout.ids.first);
}

final homeVmProvider = FutureProvider.autoDispose<HomeVm>((ref) async {
  final smokeRepo = ref.watch(smokeRepositoryProvider);
  final settingsRepo = ref.watch(settingsRepositoryProvider);
  final challengeRepo = ref.watch(challengeRepositoryProvider);

  final now = DateTime.now();
  final today = DayEvaluator.dateOnly(now);
  final settings = await settingsRepo.requireSettings();
  final budget = await settingsRepo.budgetOrDefault(today);
  final count = await smokeRepo.countForDate(today);
  final costPerCig = CostMath.perCigarette(
    packCost: settings.packCost,
    cigsPerPack: settings.cigsPerPack,
  );
  final todaySpend = CostMath.spend(
    cigaretteCount: count,
    packCost: settings.packCost,
    cigsPerPack: settings.cigsPerPack,
  );

  final days = <DayResult>[];
  for (var i = 60; i >= 0; i--) {
    final date = today.subtract(Duration(days: i));
    final dayCount = await smokeRepo.countForDate(date);
    final dayBudget = await settingsRepo.budgetForDate(date);
    final effectiveBudget =
        dayBudget ?? (date == today ? budget : settings.defaultBudget);
    final hadData = dayBudget != null || dayCount > 0 || date == today;
    days.add(
      DayEvaluator.evaluate(
        date: date,
        smokeCount: dayCount,
        budget: hadData ? effectiveBudget : null,
        now: now,
        hadAnyBudgetOrOpen: hadData,
      ),
    );
  }

  var streak = StreakCalculator.compute(
    days: days,
    today: today,
    bestEver: settings.bestStreak,
  );
  if (streak.best > settings.bestStreak) {
    await settingsRepo.setBestStreak(streak.best);
  }

  final yesterdayDate = today.subtract(const Duration(days: 1));
  DayResult? yesterday;
  for (final d in days) {
    if (d.date == yesterdayDate) {
      yesterday = d;
      break;
    }
  }
  final yesterdayWon = yesterday?.status == DayStatus.won;

  final mood = MascotMoodLogic.fromToday(
    smokeCount: count,
    budget: budget,
    nowHour: now.hour,
    yesterdayWon: yesterdayWon,
  );

  ChallengeProgress? activeProgress;
  final active = await challengeRepo.activeChallenge();
  if (active != null && active.startedAt != null) {
    final def = ChallengeCatalog.byId(active.catalogId);
    if (def != null) {
      final start = DayEvaluator.dateOnly(active.startedAt!);
      final rangeStart = start.subtract(const Duration(days: 1));
      final events = await smokeRepo.eventsBetween(
        rangeStart,
        today.add(const Duration(days: 1)),
      );
      activeProgress = ChallengeEngine.evaluate(
        def: def,
        startedOn: start,
        daysSinceStart: days.where((d) => !d.date.isBefore(start)).toList(),
        baseline: settings.usualBaseline,
        smokeTimestamps: events.map((e) => e.timestamp).toList(),
        today: today,
      );
      await challengeRepo.updateDaysCompleted(
        def.id,
        activeProgress.daysCompleted,
      );
      if (activeProgress.status == ChallengeStatus.completed) {
        await challengeRepo.markCompleted(def.id, activeProgress.daysCompleted);
        await challengeRepo.unlockReward(def.rewardId);
      }
    }
  }

  final todayResult = days.last;
  final unlockedRewards = await challengeRepo.unlockedRewardIds();
  var loadout = await settingsRepo.loadout();
  var cleaned = loadout;
  var loadoutChanged = false;
  for (final slot in CosmeticSlot.values) {
    final id = loadout.idFor(slot);
    if (id == null) continue;
    final item = CosmeticCatalog.byId(id);
    final ok = CosmeticUnlocks.canUse(
      item: item,
      isPlus: settings.isPlus,
      bestStreak: streak.best,
      unlockedRewardIds: unlockedRewards,
    );
    if (!ok) {
      cleaned = cleaned.clear(slot);
      loadoutChanged = true;
    }
  }
  if (loadoutChanged) {
    await settingsRepo.setLoadout(cleaned);
    loadout = cleaned;
  }
  return HomeVm(
    count: count,
    budget: budget,
    streak: streak,
    mood: mood,
    mascotLine: Copy.mascotLine(mood, count: count, budget: budget),
    buddyName: settings.buddyName,
    activeChallenge: activeProgress?.status == ChallengeStatus.completed
        ? null
        : activeProgress,
    todayOnTrack: count <= budget,
    todayStatus: todayResult.status,
    todaySpend: todaySpend,
    packCost: settings.packCost,
    cigsPerPack: settings.cigsPerPack,
    costPerCig: costPerCig,
    isPlus: settings.isPlus,
    loadout: loadout,
  );
});

class SmokeActions {
  SmokeActions(this._ref);

  final Ref _ref;

  /// Returns true when the soft Plus nudge should open (3rd lifetime smoke).
  Future<bool> log() async {
    await _ref.read(smokeRepositoryProvider).logNow();
    _ref.invalidate(homeVmProvider);
    _ref.invalidate(weekMoneyProvider);
    _ref.invalidate(progressDaysProvider);
    await BuddyWidgetSync.syncFromRepos(
      settingsRepo: _ref.read(settingsRepositoryProvider),
      smokeRepo: _ref.read(smokeRepositoryProvider),
      challengeRepo: _ref.read(challengeRepositoryProvider),
    );

    final settings =
        await _ref.read(settingsRepositoryProvider).requireSettings();
    if (settings.isPlus || settings.plusNudgeShown) return false;
    final total = await _ref.read(smokeRepositoryProvider).totalCount();
    if (total < 3) return false;
    await _ref.read(settingsRepositoryProvider).setPlusNudgeShown(true);
    return true;
  }

  Future<bool> undo() async {
    final ok =
        await _ref.read(smokeRepositoryProvider).undoLastSameDay(DateTime.now());
    _ref.invalidate(homeVmProvider);
    _ref.invalidate(weekMoneyProvider);
    _ref.invalidate(progressDaysProvider);
    await BuddyWidgetSync.syncFromRepos(
      settingsRepo: _ref.read(settingsRepositoryProvider),
      smokeRepo: _ref.read(smokeRepositoryProvider),
      challengeRepo: _ref.read(challengeRepositoryProvider),
    );
    return ok;
  }
}

final smokeActionsProvider = Provider<SmokeActions>((ref) => SmokeActions(ref));

final progressDaysProvider =
    FutureProvider.autoDispose<List<DayResult>>((ref) async {
  final smokeRepo = ref.watch(smokeRepositoryProvider);
  final settingsRepo = ref.watch(settingsRepositoryProvider);
  final now = DateTime.now();
  final today = DayEvaluator.dateOnly(now);
  final settings = await settingsRepo.requireSettings();
  final days = <DayResult>[];
  for (var i = 29; i >= 0; i--) {
    final date = today.subtract(Duration(days: i));
    final dayCount = await smokeRepo.countForDate(date);
    final dayBudget = await settingsRepo.budgetForDate(date);
    final hadData = dayBudget != null || dayCount > 0 || date == today;
    final effective = dayBudget ?? settings.defaultBudget;
    days.add(
      DayEvaluator.evaluate(
        date: date,
        smokeCount: dayCount,
        budget: hadData ? effective : null,
        now: now,
        hadAnyBudgetOrOpen: hadData,
      ),
    );
  }
  return days;
});

/// Week-so-far (Mon → today): smoked vs budgeted cigs and cost.
final weekMoneyProvider =
    FutureProvider.autoDispose<WeekMoneySummary>((ref) async {
  final smokeRepo = ref.watch(smokeRepositoryProvider);
  final settingsRepo = ref.watch(settingsRepositoryProvider);
  final settings = await settingsRepo.requireSettings();
  final now = DateTime.now();
  final today = DayEvaluator.dateOnly(now);
  final start = CostMath.weekStart(today);
  final end = CostMath.weekEnd(today);

  var smoked = 0;
  var budgeted = 0;
  for (var d = start;
      !d.isAfter(today);
      d = d.add(const Duration(days: 1))) {
    smoked += await smokeRepo.countForDate(d);
    budgeted += await settingsRepo.budgetOrDefault(d);
  }

  return WeekMoneySummary(
    weekStart: start,
    weekEnd: end,
    smoked: smoked,
    budgeted: budgeted,
    costSmoked: CostMath.spend(
      cigaretteCount: smoked,
      packCost: settings.packCost,
      cigsPerPack: settings.cigsPerPack,
    ),
    costBudgeted: CostMath.spend(
      cigaretteCount: budgeted,
      packCost: settings.packCost,
      cigsPerPack: settings.cigsPerPack,
    ),
    packCost: settings.packCost,
    cigsPerPack: settings.cigsPerPack,
  );
});
