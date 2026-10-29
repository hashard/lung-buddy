enum CosmeticSlot { hat, eyes, back, face }

extension CosmeticSlotX on CosmeticSlot {
  String get label => switch (this) {
        CosmeticSlot.hat => 'Hat',
        CosmeticSlot.eyes => 'Eyes',
        CosmeticSlot.back => 'Back',
        CosmeticSlot.face => 'Face',
      };
}
