import 'package:drift/drift.dart';

import '../../domain/day_evaluator.dart';
import '../db.dart';

class SmokeRepository {
  SmokeRepository(this._db);

  final AppDatabase _db;

  Future<void> logNow([DateTime? at]) async {
    await _db.into(_db.smokeEvents).insert(
          SmokeEventsCompanion.insert(timestamp: at ?? DateTime.now()),
        );
  }

  Future<bool> undoLastSameDay(DateTime now) async {
    final start = DayEvaluator.dateOnly(now);
    final end = start.add(const Duration(days: 1));
    final rows = await (_db.select(_db.smokeEvents)
          ..where((t) => t.timestamp.isBiggerOrEqualValue(start))
          ..where((t) => t.timestamp.isSmallerThanValue(end))
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)])
          ..limit(1))
        .get();
    if (rows.isEmpty) return false;
    await (_db.delete(_db.smokeEvents)..where((t) => t.id.equals(rows.first.id)))
        .go();
    return true;
  }

  Future<int> countForDate(DateTime date) async {
    final start = DayEvaluator.dateOnly(date);
    final end = start.add(const Duration(days: 1));
    final rows = await (_db.select(_db.smokeEvents)
          ..where((t) => t.timestamp.isBiggerOrEqualValue(start))
          ..where((t) => t.timestamp.isSmallerThanValue(end)))
        .get();
    return rows.length;
  }

  Future<List<SmokeEvent>> eventsBetween(DateTime start, DateTime end) {
    return (_db.select(_db.smokeEvents)
          ..where((t) => t.timestamp.isBiggerOrEqualValue(start))
          ..where((t) => t.timestamp.isSmallerThanValue(end))
          ..orderBy([(t) => OrderingTerm.asc(t.timestamp)]))
        .get();
  }

  Future<List<SmokeEvent>> allEvents() {
    return (_db.select(_db.smokeEvents)
          ..orderBy([(t) => OrderingTerm.asc(t.timestamp)]))
        .get();
  }

  Future<int> totalCount() async {
    final count = countAll();
    final query = _db.selectOnly(_db.smokeEvents)..addColumns([count]);
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }
}
