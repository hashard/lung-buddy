import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'db.g.dart';

class SmokeEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get timestamp => dateTime()();
}

class DailyBudgets extends Table {
  TextColumn get date => text()();
  IntColumn get limit => integer()();

  @override
  Set<Column> get primaryKey => {date};
}

class Settings extends Table {
  IntColumn get id => integer()();
  IntColumn get usualBaseline => integer()();
  IntColumn get defaultBudget => integer()();
  BoolColumn get onboardingDone =>
      boolean().withDefault(const Constant(false))();
  TextColumn get buddyName =>
      text().withDefault(const Constant('Buddy'))();
  IntColumn get bestStreak => integer().withDefault(const Constant(0))();
  RealColumn get packCost => real().withDefault(const Constant(40.0))();
  IntColumn get cigsPerPack => integer().withDefault(const Constant(20))();
  BoolColumn get isPlus => boolean().withDefault(const Constant(false))();
  TextColumn get equippedCosmeticId =>
      text().withDefault(const Constant('none'))();
  BoolColumn get remindersEnabled =>
      boolean().withDefault(const Constant(false))();
  IntColumn get reminderHour => integer().withDefault(const Constant(20))();
  /// Soft Plus sheet after the 3rd lifetime smoke — shown at most once.
  BoolColumn get plusNudgeShown =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class ChallengeRows extends Table {
  TextColumn get catalogId => text()();
  TextColumn get status => text()();
  DateTimeColumn get startedAt => dateTime().nullable()();
  IntColumn get daysCompleted => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {catalogId};
}

class RewardRows extends Table {
  TextColumn get id => text()();
  DateTimeColumn get unlockedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [SmokeEvents, DailyBudgets, Settings, ChallengeRows, RewardRows],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_open());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(settings, settings.packCost);
            await m.addColumn(settings, settings.cigsPerPack);
          }
          if (from < 3) {
            await m.addColumn(settings, settings.isPlus);
            await m.addColumn(settings, settings.equippedCosmeticId);
          }
          if (from < 4) {
            await m.addColumn(settings, settings.remindersEnabled);
            await m.addColumn(settings, settings.reminderHour);
          }
          if (from < 5) {
            await m.addColumn(settings, settings.plusNudgeShown);
          }
        },
      );
}

LazyDatabase _open() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'lung_buddy.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
