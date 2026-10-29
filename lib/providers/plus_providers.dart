import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/cosmetic_catalog.dart';
import '../domain/cosmetic_loadout.dart';
import '../domain/cosmetic_slot.dart';
import '../domain/cosmetic_unlocks.dart';
import '../services/buddy_widget_sync.dart';
import 'database_provider.dart';
import 'home_providers.dart';

class PlusState {
  final bool isPlus;
  final CosmeticLoadout loadout;
  final int bestStreak;
  final Set<String> unlockedRewardIds;

  const PlusState({
    required this.isPlus,
    required this.loadout,
    required this.bestStreak,
    required this.unlockedRewardIds,
  });

  CosmeticDef get primaryCosmetic => loadout.ids.isEmpty
      ? CosmeticCatalog.none
      : CosmeticCatalog.byId(loadout.ids.first);

  bool isEquipped(CosmeticDef item) => loadout.isEquipped(item.id);

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
  final settingsRepo = ref.watch(settingsRepositoryProvider);
  final settings = await settingsRepo.requireSettings();
  var loadout = await settingsRepo.loadout();
  final unlocked =
      await ref.watch(challengeRepositoryProvider).unlockedRewardIds();

  var cleaned = loadout;
  var loadoutChanged = false;
  for (final slot in CosmeticSlot.values) {
    final id = loadout.idFor(slot);
    if (id == null) continue;
    final item = CosmeticCatalog.byId(id);
    final ok = CosmeticUnlocks.canUse(
      item: item,
      isPlus: settings.isPlus,
      bestStreak: settings.bestStreak,
      unlockedRewardIds: unlocked,
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

  return PlusState(
    isPlus: settings.isPlus,
    loadout: loadout,
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
      challengeRepo: _ref.read(challengeRepositoryProvider),
    );
  }

  Future<void> clearPlusPlaceholder() async {
    final settingsRepo = _ref.read(settingsRepositoryProvider);
    final settings = await settingsRepo.requireSettings();
    final unlocked =
        await _ref.read(challengeRepositoryProvider).unlockedRewardIds();
    var loadout = await settingsRepo.loadout();

    for (final slot in CosmeticSlot.values) {
      final id = loadout.idFor(slot);
      if (id == null) continue;
      final item = CosmeticCatalog.byId(id);
      final stillOk = CosmeticUnlocks.canUse(
        item: item,
        isPlus: false,
        bestStreak: settings.bestStreak,
        unlockedRewardIds: unlocked,
      );
      if (!stillOk) {
        loadout = loadout.clear(slot);
      }
    }

    await settingsRepo.setLoadout(loadout);
    await settingsRepo.setPlus(false);
    _ref.invalidate(plusStateProvider);
    _ref.invalidate(homeVmProvider);
    _ref.invalidate(weekMoneyProvider);
    _ref.invalidate(progressDaysProvider);
    await BuddyWidgetSync.syncFromRepos(
      settingsRepo: settingsRepo,
      smokeRepo: _ref.read(smokeRepositoryProvider),
      challengeRepo: _ref.read(challengeRepositoryProvider),
    );
  }

  Future<void> toggleEquip(CosmeticDef item) async {
    final settingsRepo = _ref.read(settingsRepositoryProvider);
    final settings = await settingsRepo.requireSettings();
    final unlocked =
        await _ref.read(challengeRepositoryProvider).unlockedRewardIds();
    final ok = CosmeticUnlocks.canUse(
      item: item,
      isPlus: settings.isPlus,
      bestStreak: settings.bestStreak,
      unlockedRewardIds: unlocked,
    );
    if (!ok) return;
    final current = await settingsRepo.loadout();
    final next = current.equip(item);
    await settingsRepo.setLoadout(next);
    _ref.invalidate(plusStateProvider);
    _ref.invalidate(homeVmProvider);
    await BuddyWidgetSync.syncFromRepos(
      settingsRepo: settingsRepo,
      smokeRepo: _ref.read(smokeRepositoryProvider),
      challengeRepo: _ref.read(challengeRepositoryProvider),
    );
  }

  Future<void> equip(CosmeticDef item) => toggleEquip(item);

  Future<void> clearSlot(CosmeticSlot slot) async {
    final settingsRepo = _ref.read(settingsRepositoryProvider);
    final current = await settingsRepo.loadout();
    await settingsRepo.setLoadout(current.clear(slot));
    _ref.invalidate(plusStateProvider);
    _ref.invalidate(homeVmProvider);
    await BuddyWidgetSync.syncFromRepos(
      settingsRepo: settingsRepo,
      smokeRepo: _ref.read(smokeRepositoryProvider),
      challengeRepo: _ref.read(challengeRepositoryProvider),
    );
  }
}

final plusActionsProvider = Provider<PlusActions>((ref) => PlusActions(ref));
