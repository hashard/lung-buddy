import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/cosmetic_catalog.dart';
import '../domain/cosmetic_unlocks.dart';
import '../services/buddy_widget_sync.dart';
import 'database_provider.dart';
import 'home_providers.dart';

class PlusState {
  final bool isPlus;
  final String equippedCosmeticId;
  final int bestStreak;
  final Set<String> unlockedRewardIds;

  const PlusState({
    required this.isPlus,
    required this.equippedCosmeticId,
    required this.bestStreak,
    required this.unlockedRewardIds,
  });

  CosmeticDef get equipped => CosmeticCatalog.byId(equippedCosmeticId);

  bool canUse(CosmeticDef item) => CosmeticUnlocks.canUse(
        item: item,
        isPlus: isPlus,
        bestStreak: bestStreak,
        unlockedRewardIds: unlockedRewardIds,
      );

  String lockReason(CosmeticDef item) {
    if (canUse(item)) return 'Unlocked';
    return CosmeticCatalog.unlockHint(item);
  }
}

final plusStateProvider = FutureProvider.autoDispose<PlusState>((ref) async {
  final settings = await ref.watch(settingsRepositoryProvider).requireSettings();
  final unlocked =
      await ref.watch(challengeRepositoryProvider).unlockedRewardIds();
  return PlusState(
    isPlus: settings.isPlus,
    equippedCosmeticId: settings.equippedCosmeticId,
    bestStreak: settings.bestStreak,
    unlockedRewardIds: unlocked,
  );
});

class PlusActions {
  PlusActions(this._ref);

  final Ref _ref;

  Future<void> unlockPlusPlaceholder() async {
    await _ref.read(settingsRepositoryProvider).setPlus(true);
    _ref.invalidate(plusStateProvider);
    _ref.invalidate(homeVmProvider);
    _ref.invalidate(weekMoneyProvider);
    _ref.invalidate(progressDaysProvider);
    await BuddyWidgetSync.syncFromRepos(
      settingsRepo: _ref.read(settingsRepositoryProvider),
      smokeRepo: _ref.read(smokeRepositoryProvider),
    );
  }

  Future<void> clearPlusPlaceholder() async {
    final settings =
        await _ref.read(settingsRepositoryProvider).requireSettings();
    final unlocked =
        await _ref.read(challengeRepositoryProvider).unlockedRewardIds();
    final equipped = CosmeticCatalog.byId(settings.equippedCosmeticId);
    final stillOk = CosmeticUnlocks.canUse(
      item: equipped,
      isPlus: false,
      bestStreak: settings.bestStreak,
      unlockedRewardIds: unlocked,
    );
    if (!stillOk) {
      await _ref.read(settingsRepositoryProvider).setEquippedCosmetic('none');
    }
    await _ref.read(settingsRepositoryProvider).setPlus(false);
    _ref.invalidate(plusStateProvider);
    _ref.invalidate(homeVmProvider);
    _ref.invalidate(weekMoneyProvider);
    _ref.invalidate(progressDaysProvider);
    await BuddyWidgetSync.syncFromRepos(
      settingsRepo: _ref.read(settingsRepositoryProvider),
      smokeRepo: _ref.read(smokeRepositoryProvider),
    );
  }

  Future<void> equip(CosmeticDef item) async {
    final settings =
        await _ref.read(settingsRepositoryProvider).requireSettings();
    final unlocked =
        await _ref.read(challengeRepositoryProvider).unlockedRewardIds();
    final ok = CosmeticUnlocks.canUse(
      item: item,
      isPlus: settings.isPlus,
      bestStreak: settings.bestStreak,
      unlockedRewardIds: unlocked,
    );
    if (!ok) return;
    await _ref.read(settingsRepositoryProvider).setEquippedCosmetic(item.id);
    _ref.invalidate(plusStateProvider);
    _ref.invalidate(homeVmProvider);
  }
}

final plusActionsProvider = Provider<PlusActions>((ref) => PlusActions(ref));
