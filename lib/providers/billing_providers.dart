import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../services/billing_service.dart';
import '../services/buddy_widget_sync.dart';
import 'database_provider.dart';
import 'home_providers.dart';
import 'plus_providers.dart';

final billingServiceProvider = Provider<BillingService>((ref) {
  final service = BillingService();
  ref.onDispose(service.dispose);
  return service;
});

final billingBootstrapProvider = FutureProvider<void>((ref) async {
  final billing = ref.read(billingServiceProvider);
  await billing.start(
    onPurchase: (purchase) async {
      if (purchase.productID != kPlusProductId) return;
      if (purchase.status != PurchaseStatus.purchased &&
          purchase.status != PurchaseStatus.restored) {
        return;
      }
      await ref.read(settingsRepositoryProvider).setPlus(true);
      ref.invalidate(plusStateProvider);
      ref.invalidate(homeVmProvider);
      ref.invalidate(weekMoneyProvider);
      ref.invalidate(progressDaysProvider);
      await BuddyWidgetSync.syncFromRepos(
        settingsRepo: ref.read(settingsRepositoryProvider),
        smokeRepo: ref.read(smokeRepositoryProvider),
        challengeRepo: ref.read(challengeRepositoryProvider),
      );
    },
  );
});

class BillingActions {
  BillingActions(this._ref);

  final Ref _ref;

  Future<String?> buyPlus() async {
    final billing = _ref.read(billingServiceProvider);
    final available = await billing.isAvailable;
    if (!available) {
      if (kDebugMode) {
        await _ref.read(plusActionsProvider).unlockPlusPlaceholder();
        return 'Store unavailable — unlocked Plus in debug.';
      }
      return 'Billing unavailable on this device.';
    }
    final ok = await billing.buyPlus();
    if (!ok) {
      if (kDebugMode) {
        await _ref.read(plusActionsProvider).unlockPlusPlaceholder();
        return 'Product not found in Play Console yet — unlocked Plus in debug.';
      }
      return 'Could not start purchase. Is lung_buddy_plus set up in Play Console?';
    }
    return null;
  }

  Future<void> restore() async {
    await _ref.read(billingServiceProvider).restore();
  }
}

final billingActionsProvider =
    Provider<BillingActions>((ref) => BillingActions(ref));
