import 'cosmetic_catalog.dart';
import 'cosmetic_slot.dart';

class CosmeticLoadout {
  const CosmeticLoadout({
    this.hatId,
    this.eyesId,
    this.backId,
    this.faceId,
  });

  final String? hatId;
  final String? eyesId;
  final String? backId;
  final String? faceId;

  static const empty = CosmeticLoadout();

  String? idFor(CosmeticSlot slot) => switch (slot) {
        CosmeticSlot.hat => hatId,
        CosmeticSlot.eyes => eyesId,
        CosmeticSlot.back => backId,
        CosmeticSlot.face => faceId,
      };

  bool isEquipped(String id) =>
      hatId == id || eyesId == id || backId == id || faceId == id;

  List<String> get ids => [
        if (hatId != null) hatId!,
        if (eyesId != null) eyesId!,
        if (backId != null) backId!,
        if (faceId != null) faceId!,
      ];

  /// Equip item into its slot. Tapping the same id again clears that slot.
  CosmeticLoadout equip(CosmeticDef item) {
    if (item.id == 'none' || item.slot == null) return this;
    final slot = item.slot!;
    if (idFor(slot) == item.id) return clear(slot);
    return _copyWithSlot(slot, item.id);
  }

  CosmeticLoadout clear(CosmeticSlot slot) => _copyWithSlot(slot, null);

  CosmeticLoadout _copyWithSlot(CosmeticSlot slot, String? id) => switch (slot) {
        CosmeticSlot.hat => CosmeticLoadout(
            hatId: id, eyesId: eyesId, backId: backId, faceId: faceId),
        CosmeticSlot.eyes => CosmeticLoadout(
            hatId: hatId, eyesId: id, backId: backId, faceId: faceId),
        CosmeticSlot.back => CosmeticLoadout(
            hatId: hatId, eyesId: eyesId, backId: id, faceId: faceId),
        CosmeticSlot.face => CosmeticLoadout(
            hatId: hatId, eyesId: eyesId, backId: backId, faceId: id),
      };

  factory CosmeticLoadout.fromSettings({
    required String hatCosmeticId,
    required String eyesCosmeticId,
    required String backCosmeticId,
    required String faceCosmeticId,
  }) {
    String? norm(String raw) {
      final t = raw.trim();
      if (t.isEmpty || t == 'none') return null;
      return t;
    }

    return CosmeticLoadout(
      hatId: norm(hatCosmeticId),
      eyesId: norm(eyesCosmeticId),
      backId: norm(backCosmeticId),
      faceId: norm(faceCosmeticId),
    );
  }
}
