# Lung Buddy look + mix-and-match loadout

Date: 2026-10-30  
Status: Approved for planning

## Goal

1. Redesign the in-app Lung Buddy toward the Grok promo look (close match via `CustomPainter`, not a static PNG).
2. Replace single-cosmetic equip with a **4-slot loadout** so looks can mix and match, with hard exclusivity (never two hats, etc.).

## Decisions locked

| Topic | Choice |
|---|---|
| Visual target | Close match to Grok ref (sticker rim, freckles, tongue smile, rounder lobes, chunky face) |
| Slot count | 4: **Hat**, **Eyes**, **Back**, **Face** |
| Closet UI | Slot tabs + live preview + equipped chips |
| Architecture | Loadout object + painter rewrite (not fake presets / free-form multi-select) |

## Slots

```text
hat   → beanie, bow, crowns, bandanas, frog hat, …
eyes  → shades, visors, heart specs, monocle, …
back  → cape, scarf, angel wings, …
face  → halo, mustache, bandage, flower, antenna, horns, leaf, star, sparkle aura, …
```

Rules:

- Every catalog item maps to **exactly one** slot.
- Equipping an item writes that slot only.
- Equipping a second item in the same slot **replaces** the first.
- Tapping the currently equipped item **clears** that slot.
- Unlock rules unchanged: starter / streak / challenge / Plus exclusive. Plus still unlocks all.

## Data model

Replace single `equippedCosmeticId` with a loadout on `Settings`:

- `hatCosmeticId` (text, default `none` / empty meaning unequipped)
- `eyesCosmeticId`
- `backCosmeticId`
- `faceCosmeticId`

Use empty string or `'none'` consistently for “empty slot” (prefer empty string for unequipped; catalog `none` is not equippable as a real item).

Domain type:

```dart
class CosmeticLoadout {
  final String? hatId;
  final String? eyesId;
  final String? backId;
  final String? faceId;
}
```

Helpers:

- `CosmeticCatalog.slotFor(CosmeticDef)` → `CosmeticSlot`
- `loadout.equip(item)` → new loadout with that slot set
- `loadout.clear(slot)` → new loadout with that slot cleared
- `loadout.ids` for unlock checks / widget sync

### Migration (schema bump)

1. Add the four columns.
2. If legacy `equippedCosmeticId` is set and not `none`, place it into the slot returned by `slotFor`.
3. Keep `equippedCosmeticId` temporarily as a deprecated mirror of “primary” item **or** drop it in the same migration after copying — prefer **drop after copy** to avoid dual sources of truth. If drop is awkward for Drift, stop writing it and ignore on read after migration.

## Painter

Rewrite `LungPainter` to accept `CosmeticLoadout` (+ smoke/cough as today).

Draw order (back → front):

1. Back slot (cape / wings / scarf behind body)
2. Body (rounder lobes, thick ink outline, soft white sticker rim, freckle spots, smoke tint)
3. Base face (eyes, blush, tongue smile)
4. Eyes slot (glasses)
5. Hat slot
6. Face slot (halo above hat when present; mustache/bandage/etc. on face)

Smoke ratio continues to lerp body color healthy pink → soot. Cosmetics keep accent colors.

Call sites: `MascotView`, closet preview, `BuddyRender` / widget sync, any tests that construct `LungPainter`.

## Closet UI

- Top: live `CustomPaint` preview of current loadout
- Under preview: four chips (Hat / Eyes / Back / Face) showing equipped name or “Empty”; tap chip optional shortcut to that tab
- Tabs filter catalog by slot
- Row: lock state + unlock hint (unchanged logic via `CosmeticUnlocks`)
- Tap unlocked → `equip` that slot; tap equipped → `clear`
- Plus CTA when not Plus stays as today

## App wiring

- `HomeVm` / `PlusState` expose `CosmeticLoadout` instead of a single `CosmeticDef`
- Equip / clear actions go through settings repo + invalidate home/plus/widget
- Widget `BuddyRender` paints the full loadout
- After implementation, regenerate branding / launcher / widget fallback art from the new painter (follow-up ok if not blocking first dogfood)

## Out of scope

- New cosmetic items beyond remapping existing catalog into slots
- Changing Plus pricing or unlock economy
- Replacing CustomPainter with image assets as the runtime mascot
- iOS-specific work beyond shared Dart

## Testing

- Unit: slot mapping covers every catalog id exactly once; equip/replace/clear; migration places legacy id in correct slot
- Widget/golden or render smoke: loadout with hat+back+face draws without overlap bugs for beanie+halo+cape combo
- Closet: cannot show two hats equipped at once

## Success criteria

- Buddy reads as the Grok promo character family (sticker, freckles, tongue smile)
- User can wear e.g. beanie + cape + shades + halo together
- User cannot wear two hats (or two of any same slot) at once
- Existing unlocks and Plus gating still work
