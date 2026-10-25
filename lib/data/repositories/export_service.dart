import 'dart:convert';

import '../db.dart';

class ExportService {
  ExportService(this._db);

  final AppDatabase _db;

  Future<String> exportJson() async {
    final events = await _db.select(_db.smokeEvents).get();
    final budgets = await _db.select(_db.dailyBudgets).get();
    final settings = await _db.select(_db.settings).get();
    final challenges = await _db.select(_db.challengeRows).get();
    final rewards = await _db.select(_db.rewardRows).get();

    final payload = {
      'exportedAt': DateTime.now().toIso8601String(),
      'smokeEvents': events
          .map((e) => {'id': e.id, 'timestamp': e.timestamp.toIso8601String()})
          .toList(),
      'dailyBudgets':
          budgets.map((b) => {'date': b.date, 'limit': b.limit}).toList(),
      'settings': settings
          .map((s) => {
                'usualBaseline': s.usualBaseline,
                'defaultBudget': s.defaultBudget,
                'buddyName': s.buddyName,
                'bestStreak': s.bestStreak,
                'onboardingDone': s.onboardingDone,
              })
          .toList(),
      'challenges': challenges
          .map((c) => {
                'catalogId': c.catalogId,
                'status': c.status,
                'startedAt': c.startedAt?.toIso8601String(),
                'daysCompleted': c.daysCompleted,
              })
          .toList(),
      'rewards': rewards
          .map((r) => {
                'id': r.id,
                'unlockedAt': r.unlockedAt.toIso8601String(),
              })
          .toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  Future<void> wipeAll() async {
    await _db.transaction(() async {
      await _db.delete(_db.smokeEvents).go();
      await _db.delete(_db.dailyBudgets).go();
      await _db.delete(_db.challengeRows).go();
      await _db.delete(_db.rewardRows).go();
      await _db.delete(_db.settings).go();
    });
  }
}
