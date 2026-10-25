import 'cosmetic_catalog.dart';

class CosmeticUnlocks {
  /// Plus owns the whole closet. Otherwise earn via starter / streak / challenge.
  static bool canUse({
    required CosmeticDef item,
    required bool isPlus,
    required int bestStreak,
    required Set<String> unlockedRewardIds,
  }) {
    if (isPlus) return true;
    switch (item.unlock) {
      case CosmeticUnlock.starter:
        return true;
      case CosmeticUnlock.streak:
        final need = item.streakRequired ?? 9999;
        return bestStreak >= need;
      case CosmeticUnlock.challenge:
        return unlockedRewardIds.contains(item.id);
      case CosmeticUnlock.plusExclusive:
        return false;
    }
  }

  static List<int> streakMilestonesFor(int bestStreak) {
    return CosmeticCatalog.items
        .where((c) => c.unlock == CosmeticUnlock.streak)
        .map((c) => c.streakRequired!)
        .where((n) => bestStreak >= n)
        .toList();
  }
}
