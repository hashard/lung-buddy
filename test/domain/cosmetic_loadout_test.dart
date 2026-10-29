import 'package:flutter_test/flutter_test.dart';
import 'package:lung_buddy/domain/cosmetic_catalog.dart';
import 'package:lung_buddy/domain/cosmetic_loadout.dart';
import 'package:lung_buddy/domain/cosmetic_slot.dart';

void main() {
  test('every wearable catalog item maps to exactly one slot', () {
    final wearable = CosmeticCatalog.items.where((c) => c.id != 'none');
    for (final item in wearable) {
      expect(item.slot, isNotNull, reason: item.id);
    }
  });

  test('equip replaces same slot only', () {
    var loadout = const CosmeticLoadout();
    loadout = loadout.equip(CosmeticCatalog.byId('beanie_mint'));
    loadout = loadout.equip(CosmeticCatalog.byId('streak_cape'));
    expect(loadout.hatId, 'beanie_mint');
    expect(loadout.backId, 'streak_cape');
    loadout = loadout.equip(CosmeticCatalog.byId('bow_coral'));
    expect(loadout.hatId, 'bow_coral');
    expect(loadout.backId, 'streak_cape');
  });

  test('equip same id again clears that slot', () {
    var loadout = const CosmeticLoadout().equip(CosmeticCatalog.byId('halo'));
    expect(loadout.faceId, 'halo');
    loadout = loadout.equip(CosmeticCatalog.byId('halo'));
    expect(loadout.faceId, isNull);
  });

  test('slot mapping samples', () {
    expect(CosmeticCatalog.byId('beanie_mint').slot, CosmeticSlot.hat);
    expect(CosmeticCatalog.byId('shades').slot, CosmeticSlot.eyes);
    expect(CosmeticCatalog.byId('streak_cape').slot, CosmeticSlot.back);
    expect(CosmeticCatalog.byId('angel_wings').slot, CosmeticSlot.back);
    expect(CosmeticCatalog.byId('halo').slot, CosmeticSlot.face);
    expect(CosmeticCatalog.byId('mustache').slot, CosmeticSlot.face);
  });
}
