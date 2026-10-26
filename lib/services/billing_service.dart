import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Play / App Store product id for Lung Buddy Plus (non-consumable).
const kPlusProductId = 'lung_buddy_plus';

class BillingService {
  BillingService();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;
  ProductDetails? _plusProduct;

  ProductDetails? get plusProduct => _plusProduct;

  Future<bool> get isAvailable => _iap.isAvailable();

  Future<void> start({
    required void Function(PurchaseDetails purchase) onPurchase,
  }) async {
    _sub?.cancel();
    _sub = _iap.purchaseStream.listen(
      (purchases) async {
        for (final purchase in purchases) {
          if (purchase.status == PurchaseStatus.pending) continue;
          if (purchase.status == PurchaseStatus.error) {
            debugPrint('Billing error: ${purchase.error}');
            if (purchase.pendingCompletePurchase) {
              await _iap.completePurchase(purchase);
            }
            continue;
          }
          if (purchase.status == PurchaseStatus.purchased ||
              purchase.status == PurchaseStatus.restored) {
            if (purchase.productID == kPlusProductId) {
              onPurchase(purchase);
            }
          }
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
        }
      },
      onError: (e) => debugPrint('purchaseStream error: $e'),
    );

    await queryProducts();
  }

  Future<void> queryProducts() async {
    final available = await _iap.isAvailable();
    if (!available) return;
    final response = await _iap.queryProductDetails({kPlusProductId});
    if (response.error != null) {
      debugPrint('queryProductDetails: ${response.error}');
    }
    if (response.productDetails.isNotEmpty) {
      _plusProduct = response.productDetails.first;
    }
  }

  Future<bool> buyPlus() async {
    final available = await _iap.isAvailable();
    if (!available) return false;
    if (_plusProduct == null) await queryProducts();
    final product = _plusProduct;
    if (product == null) return false;
    final param = PurchaseParam(productDetails: product);
    return _iap.buyNonConsumable(purchaseParam: param);
  }

  Future<void> restore() async {
    await _iap.restorePurchases();
  }

  Future<void> dispose() async {
    await _sub?.cancel();
  }
}
