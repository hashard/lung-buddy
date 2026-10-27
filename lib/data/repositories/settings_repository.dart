import 'package:drift/drift.dart';
import 'package:intl/intl.dart';

import '../../domain/day_evaluator.dart';
import '../db.dart';

class SettingsRepository {
  SettingsRepository(this._db);

  final AppDatabase _db;
  static final _dateFmt = DateFormat('yyyy-MM-dd');

  static String dateKey(DateTime d) => _dateFmt.format(DayEvaluator.dateOnly(d));

  Future<Setting?> getSettings() {
    return (_db.select(_db.settings)..where((t) => t.id.equals(1)))
        .getSingleOrNull();
  }

  Future<Setting> requireSettings() async {
    final existing = await getSettings();
    if (existing != null) return existing;
    await _db.into(_db.settings).insert(
          SettingsCompanion.insert(
            id: const Value(1),
            usualBaseline: 10,
            defaultBudget: 10,
            packCost: const Value(40.0),
            cigsPerPack: const Value(20),
          ),
        );
    return (await getSettings())!;
  }

  Future<void> completeOnboarding({
    required int usualBaseline,
    required int defaultBudget,
    required String buddyName,
    required double packCost,
    required int cigsPerPack,
  }) async {
    await _db.into(_db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            id: const Value(1),
            usualBaseline: usualBaseline,
            defaultBudget: defaultBudget,
            onboardingDone: const Value(true),
            buddyName: Value(buddyName),
            packCost: Value(packCost),
            cigsPerPack: Value(cigsPerPack),
          ),
        );
    await setBudgetForDate(DateTime.now(), defaultBudget);
  }

  Future<void> setBestStreak(int best) async {
    await (_db.update(_db.settings)..where((t) => t.id.equals(1))).write(
      SettingsCompanion(bestStreak: Value(best)),
    );
  }

  Future<void> setDefaultBudget(int budget) async {
    await (_db.update(_db.settings)..where((t) => t.id.equals(1))).write(
      SettingsCompanion(defaultBudget: Value(budget)),
    );
  }

  Future<void> setUsualBaseline(int baseline) async {
    await (_db.update(_db.settings)..where((t) => t.id.equals(1))).write(
      SettingsCompanion(usualBaseline: Value(baseline)),
    );
  }

  Future<void> setPackPricing({
    required double packCost,
    required int cigsPerPack,
  }) async {
    await (_db.update(_db.settings)..where((t) => t.id.equals(1))).write(
      SettingsCompanion(
        packCost: Value(packCost),
        cigsPerPack: Value(cigsPerPack),
      ),
    );
  }

  Future<void> setPlus(bool value) async {
    await (_db.update(_db.settings)..where((t) => t.id.equals(1))).write(
      SettingsCompanion(isPlus: Value(value)),
    );
  }

  Future<void> setEquippedCosmetic(String cosmeticId) async {
    await (_db.update(_db.settings)..where((t) => t.id.equals(1))).write(
      SettingsCompanion(equippedCosmeticId: Value(cosmeticId)),
    );
  }

  Future<void> setReminders({
    required bool enabled,
    required int hour,
  }) async {
    await (_db.update(_db.settings)..where((t) => t.id.equals(1))).write(
      SettingsCompanion(
        remindersEnabled: Value(enabled),
        reminderHour: Value(hour.clamp(0, 23)),
      ),
    );
  }

  Future<void> setPlusNudgeShown(bool value) async {
    await (_db.update(_db.settings)..where((t) => t.id.equals(1))).write(
      SettingsCompanion(plusNudgeShown: Value(value)),
    );
  }

  Future<void> setBudgetForDate(DateTime date, int limit) async {
    await _db.into(_db.dailyBudgets).insertOnConflictUpdate(
          DailyBudgetsCompanion.insert(
            date: dateKey(date),
            limit: limit,
          ),
        );
  }

  Future<int?> budgetForDate(DateTime date) async {
    final row = await (_db.select(_db.dailyBudgets)
          ..where((t) => t.date.equals(dateKey(date))))
        .getSingleOrNull();
    return row?.limit;
  }

  Future<int> budgetOrDefault(DateTime date) async {
    final specific = await budgetForDate(date);
    if (specific != null) return specific;
    final s = await requireSettings();
    return s.defaultBudget;
  }

  Future<List<DailyBudget>> allBudgets() {
    return _db.select(_db.dailyBudgets).get();
  }

  Future<void> resetOnboardingFlag() async {
    await (_db.update(_db.settings)..where((t) => t.id.equals(1))).write(
      const SettingsCompanion(onboardingDone: Value(false)),
    );
  }
}
