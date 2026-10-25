import 'package:drift/drift.dart';

import '../db.dart';

class ChallengeRepository {
  ChallengeRepository(this._db);

  final AppDatabase _db;

  Future<ChallengeRow?> activeChallenge() {
    return (_db.select(_db.challengeRows)
          ..where((t) => t.status.equals('active')))
        .getSingleOrNull();
  }

  Future<List<ChallengeRow>> allRows() {
    return _db.select(_db.challengeRows).get();
  }

  Future<void> start(String catalogId, DateTime startedAt) async {
    final active = await activeChallenge();
    if (active != null) {
      throw StateError('Another challenge is already active');
    }
    await _db.into(_db.challengeRows).insertOnConflictUpdate(
          ChallengeRowsCompanion.insert(
            catalogId: catalogId,
            status: 'active',
            startedAt: Value(startedAt),
            daysCompleted: const Value(0),
          ),
        );
  }

  Future<void> abandon(String catalogId) async {
    await (_db.delete(_db.challengeRows)
          ..where((t) => t.catalogId.equals(catalogId)))
        .go();
  }

  Future<void> markCompleted(String catalogId, int daysCompleted) async {
    await (_db.update(_db.challengeRows)
          ..where((t) => t.catalogId.equals(catalogId)))
        .write(
      ChallengeRowsCompanion(
        status: const Value('completed'),
        daysCompleted: Value(daysCompleted),
      ),
    );
  }

  Future<void> updateDaysCompleted(String catalogId, int days) async {
    await (_db.update(_db.challengeRows)
          ..where((t) => t.catalogId.equals(catalogId)))
        .write(ChallengeRowsCompanion(daysCompleted: Value(days)));
  }

  Future<void> unlockReward(String rewardId) async {
    await _db.into(_db.rewardRows).insertOnConflictUpdate(
          RewardRowsCompanion.insert(
            id: rewardId,
            unlockedAt: DateTime.now(),
          ),
        );
  }

  Future<List<RewardRow>> rewards() => _db.select(_db.rewardRows).get();

  Future<Set<String>> unlockedRewardIds() async {
    final rows = await rewards();
    return rows.map((r) => r.id).toSet();
  }

  Future<bool> hasReward(String rewardId) async {
    final row = await (_db.select(_db.rewardRows)
          ..where((t) => t.id.equals(rewardId)))
        .getSingleOrNull();
    return row != null;
  }

  Future<bool> isCompleted(String catalogId) async {
    final row = await (_db.select(_db.challengeRows)
          ..where((t) => t.catalogId.equals(catalogId)))
        .getSingleOrNull();
    return row?.status == 'completed';
  }
}

