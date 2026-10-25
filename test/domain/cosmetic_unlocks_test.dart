import 'package:flutter_test/flutter_test.dart';
import 'package:lung_buddy/domain/cosmetic_catalog.dart';
import 'package:lung_buddy/domain/cosmetic_unlocks.dart';

void main() {
  group('CosmeticUnlocks', () {
    test('Plus unlocks everything', () {
      for (final item in CosmeticCatalog.items) {
        expect(
          CosmeticUnlocks.canUse(
            item: item,
            isPlus: true,
            bestStreak: 0,
            unlockedRewardIds: {},
          ),
          isTrue,
          reason: item.id,
        );
      }
    });

    test('starters free without Plus', () {
      final beanie = CosmeticCatalog.byId('beanie_mint');
      expect(
        CosmeticUnlocks.canUse(
          item: beanie,
          isPlus: false,
          bestStreak: 0,
          unlockedRewardIds: {},
        ),
        isTrue,
      );
    });

    test('streak gated by best streak', () {
      final flower = CosmeticCatalog.byId('flower');
      expect(
        CosmeticUnlocks.canUse(
          item: flower,
          isPlus: false,
          bestStreak: 6,
          unlockedRewardIds: {},
        ),
        isFalse,
      );
      expect(
        CosmeticUnlocks.canUse(
          item: flower,
          isPlus: false,
          bestStreak: 7,
          unlockedRewardIds: {},
        ),
        isTrue,
      );
    });

    test('challenge gated by reward id', () {
      final hat = CosmeticCatalog.byId('top_hat');
      expect(
        CosmeticUnlocks.canUse(
          item: hat,
          isPlus: false,
          bestStreak: 99,
          unlockedRewardIds: {},
        ),
        isFalse,
      );
      expect(
        CosmeticUnlocks.canUse(
          item: hat,
          isPlus: false,
          bestStreak: 0,
          unlockedRewardIds: {'top_hat'},
        ),
        isTrue,
      );
    });

    test('plus exclusive stays locked without Plus', () {
      final crown = CosmeticCatalog.byId('golden_crown');
      expect(
        CosmeticUnlocks.canUse(
          item: crown,
          isPlus: false,
          bestStreak: 999,
          unlockedRewardIds: {'golden_crown'},
        ),
        isFalse,
      );
    });
  });
}
