import 'package:flutter/material.dart';

enum CosmeticKind { none, hat, scarf, glasses, prop }

enum CosmeticUnlock { starter, streak, challenge, plusExclusive }

class CosmeticDef {
  final String id;
  final String name;
  final String blurb;
  final CosmeticKind kind;
  final CosmeticUnlock unlock;
  final int? streakRequired;
  final Color accent;

  const CosmeticDef({
    required this.id,
    required this.name,
    required this.blurb,
    required this.kind,
    required this.unlock,
    this.streakRequired,
    required this.accent,
  });
}

class CosmeticCatalog {
  static const none = CosmeticDef(
    id: 'none',
    name: 'Naked lung',
    blurb: 'Starter look. Pure chaos.',
    kind: CosmeticKind.none,
    unlock: CosmeticUnlock.starter,
    accent: Color(0xFFFF8FB8),
  );

  static const items = <CosmeticDef>[
    none,
    // Starters
    CosmeticDef(
      id: 'beanie_mint',
      name: 'Mint beanie',
      blurb: 'Free cozy vibes.',
      kind: CosmeticKind.hat,
      unlock: CosmeticUnlock.starter,
      accent: Color(0xFF7DFFB3),
    ),
    CosmeticDef(
      id: 'bow_coral',
      name: 'Chaos bow',
      blurb: 'Free flourish.',
      kind: CosmeticKind.hat,
      unlock: CosmeticUnlock.starter,
      accent: Color(0xFFFF6BB5),
    ),
    // Streak unlocks
    CosmeticDef(
      id: 'bandage',
      name: 'Booboo bandage',
      blurb: 'Earn with a 3-day streak.',
      kind: CosmeticKind.prop,
      unlock: CosmeticUnlock.streak,
      streakRequired: 3,
      accent: Color(0xFFFFE566),
    ),
    CosmeticDef(
      id: 'flower',
      name: 'Daisy of denial',
      blurb: 'Earn with a 7-day streak.',
      kind: CosmeticKind.prop,
      unlock: CosmeticUnlock.streak,
      streakRequired: 7,
      accent: Color(0xFFFF8C42),
    ),
    CosmeticDef(
      id: 'halo',
      name: 'Suspicious halo',
      blurb: 'Earn with a 14-day streak.',
      kind: CosmeticKind.prop,
      unlock: CosmeticUnlock.streak,
      streakRequired: 14,
      accent: Color(0xFFFFE566),
    ),
    CosmeticDef(
      id: 'antenna',
      name: 'Alien antenna',
      blurb: 'Earn with a 21-day streak.',
      kind: CosmeticKind.prop,
      unlock: CosmeticUnlock.streak,
      streakRequired: 21,
      accent: Color(0xFF7DFFB3),
    ),
    CosmeticDef(
      id: 'party_crown',
      name: 'Party crown',
      blurb: 'Earn with a 30-day streak.',
      kind: CosmeticKind.hat,
      unlock: CosmeticUnlock.streak,
      streakRequired: 30,
      accent: Color(0xFFFFE566),
    ),
    CosmeticDef(
      id: 'streak_cape',
      name: 'Streak cape',
      blurb: 'Earn with a 45-day streak.',
      kind: CosmeticKind.scarf,
      unlock: CosmeticUnlock.streak,
      streakRequired: 45,
      accent: Color(0xFF7B5CFF),
    ),
    CosmeticDef(
      id: 'legend_horns',
      name: 'Legend horns',
      blurb: 'Earn with a 60-day streak.',
      kind: CosmeticKind.prop,
      unlock: CosmeticUnlock.streak,
      streakRequired: 60,
      accent: Color(0xFFFF4D6D),
    ),
    // Challenge unlocks (rewardId == cosmetic id)
    CosmeticDef(
      id: 'top_hat',
      name: 'Tiny top hat',
      blurb: 'Quest: Two under yesterday.',
      kind: CosmeticKind.hat,
      unlock: CosmeticUnlock.challenge,
      accent: Color(0xFF2B2433),
    ),
    CosmeticDef(
      id: 'scarf_sunset',
      name: 'Sunset scarf',
      blurb: 'Quest: Budget boss.',
      kind: CosmeticKind.scarf,
      unlock: CosmeticUnlock.challenge,
      accent: Color(0xFFFF8C42),
    ),
    CosmeticDef(
      id: 'shades',
      name: 'Cool shades',
      blurb: 'Quest: Below usual.',
      kind: CosmeticKind.glasses,
      unlock: CosmeticUnlock.challenge,
      accent: Color(0xFF7B5CFF),
    ),
    CosmeticDef(
      id: 'sun_visors',
      name: 'Sun visors',
      blurb: 'Quest: Clear mornings.',
      kind: CosmeticKind.glasses,
      unlock: CosmeticUnlock.challenge,
      accent: Color(0xFFFFE566),
    ),
    CosmeticDef(
      id: 'couch_hat',
      name: 'Couch potato hat',
      blurb: 'Quest: Chill weekend.',
      kind: CosmeticKind.hat,
      unlock: CosmeticUnlock.challenge,
      accent: Color(0xFFB08968),
    ),
    CosmeticDef(
      id: 'mustache',
      name: 'Sneaky stache',
      blurb: 'Quest: Smoke-lite week.',
      kind: CosmeticKind.prop,
      unlock: CosmeticUnlock.challenge,
      accent: Color(0xFF2B2433),
    ),
    CosmeticDef(
      id: 'pirate_bandana',
      name: 'Pirate bandana',
      blurb: 'Quest: Cut by two.',
      kind: CosmeticKind.hat,
      unlock: CosmeticUnlock.challenge,
      accent: Color(0xFFFF4D6D),
    ),
    CosmeticDef(
      id: 'frog_hat',
      name: 'Froggy hat',
      blurb: 'Quest: Midweek mercy.',
      kind: CosmeticKind.hat,
      unlock: CosmeticUnlock.challenge,
      accent: Color(0xFF7DFFB3),
    ),
    CosmeticDef(
      id: 'sleepy_cap',
      name: 'Sleepy cap',
      blurb: 'Quest: Night owl trim.',
      kind: CosmeticKind.hat,
      unlock: CosmeticUnlock.challenge,
      accent: Color(0xFF9B8CFF),
    ),
    CosmeticDef(
      id: 'heart_specs',
      name: 'Heart specs',
      blurb: 'Quest: Soft launch.',
      kind: CosmeticKind.glasses,
      unlock: CosmeticUnlock.challenge,
      accent: Color(0xFFFF6BB5),
    ),
    // Plus exclusive (also unlocked by purchasing Plus = all)
    CosmeticDef(
      id: 'golden_crown',
      name: 'Golden crown',
      blurb: 'Plus exclusive bling.',
      kind: CosmeticKind.hat,
      unlock: CosmeticUnlock.plusExclusive,
      accent: Color(0xFFFFD166),
    ),
    CosmeticDef(
      id: 'diamond_shades',
      name: 'Diamond shades',
      blurb: 'Plus exclusive sparkle.',
      kind: CosmeticKind.glasses,
      unlock: CosmeticUnlock.plusExclusive,
      accent: Color(0xFFB8F0FF),
    ),
    CosmeticDef(
      id: 'rainbow_scarf',
      name: 'Rainbow scarf',
      blurb: 'Plus exclusive drip.',
      kind: CosmeticKind.scarf,
      unlock: CosmeticUnlock.plusExclusive,
      accent: Color(0xFFFF6BB5),
    ),
    CosmeticDef(
      id: 'devil_horns',
      name: 'Lil devil horns',
      blurb: 'Plus exclusive mischief.',
      kind: CosmeticKind.prop,
      unlock: CosmeticUnlock.plusExclusive,
      accent: Color(0xFFFF4D6D),
    ),
    CosmeticDef(
      id: 'angel_wings',
      name: 'Angel stub wings',
      blurb: 'Plus exclusive irony.',
      kind: CosmeticKind.prop,
      unlock: CosmeticUnlock.plusExclusive,
      accent: Color(0xFFFFFFFF),
    ),
    CosmeticDef(
      id: 'monocle',
      name: 'Fancy monocle',
      blurb: 'Plus exclusive class.',
      kind: CosmeticKind.glasses,
      unlock: CosmeticUnlock.plusExclusive,
      accent: Color(0xFF2B2433),
    ),
  ];

  static CosmeticDef byId(String? id) {
    if (id == null || id.isEmpty) return none;
    for (final item in items) {
      if (item.id == id) return item;
    }
    return none;
  }

  static String unlockHint(CosmeticDef item) {
    switch (item.unlock) {
      case CosmeticUnlock.starter:
        return 'Free starter';
      case CosmeticUnlock.streak:
        return '${item.streakRequired}-day streak';
      case CosmeticUnlock.challenge:
        return item.blurb;
      case CosmeticUnlock.plusExclusive:
        return 'Plus exclusive';
    }
  }
}
