# Buddy Look + 4-Slot Loadout Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Redesign Lung Buddy toward the Grok sticker look and replace single-cosmetic equip with an exclusive 4-slot loadout (Hat / Eyes / Back / Face).

**Architecture:** Domain `CosmeticLoadout` + `CosmeticSlot` map every catalog item to one slot. Drift settings store four ID columns (schema v6); legacy `equippedCosmeticId` is migrated then ignored. `LungPainter` takes a loadout and draws Back → Body → Face → Eyes → Hat → Face props. Closet uses slot tabs with equip/clear.

**Tech Stack:** Flutter, Riverpod, Drift/SQLite, CustomPainter, flutter_test

**Spec:** `docs/superpowers/specs/2026-10-30-buddy-look-loadout-design.md`

---

## File map

| File | Responsibility |
|---|---|
| `lib/domain/cosmetic_slot.dart` | `CosmeticSlot` enum + display labels |
| `lib/domain/cosmetic_loadout.dart` | Immutable loadout + equip/clear/ids |
| `lib/domain/cosmetic_catalog.dart` | Add `slot` on each item; `itemsForSlot`; drop obsolete `CosmeticKind` uses where replaced |
| `lib/data/db.dart` + `db.g.dart` | Schema v6: four loadout columns + migration |
| `lib/data/repositories/settings_repository.dart` | Read/write loadout; migrate helper |
| `lib/providers/plus_providers.dart` | `PlusState.loadout`; equip/clear/toggle |
| `lib/providers/home_providers.dart` | `HomeVm.loadout` |
| `lib/ui/home/lung_painter.dart` | Grok-style body + multi-slot cosmetics |
| `lib/ui/home/mascot_view.dart` | Pass loadout |
| `lib/ui/widgets/buddy_render.dart` | Pass loadout |
| `lib/services/buddy_widget_sync.dart` | Sync loadout into widget render |
| `lib/ui/closet/closet_screen.dart` | Slot tabs UI |
| `test/domain/cosmetic_loadout_test.dart` | Slot map + equip/clear |
| `test/domain/cosmetic_slot_coverage_test.dart` | Every catalog id has exactly one slot |
| `test/generate_brand_art_test.dart` / promo pack | Optional regen after painter lands |

---

### Task 1: Domain — slots + loadout (TDD)

**Files:**
- Create: `lib/domain/cosmetic_slot.dart`
- Create: `lib/domain/cosmetic_loadout.dart`
- Create: `test/domain/cosmetic_loadout_test.dart`
- Modify: `lib/domain/cosmetic_catalog.dart`

- [ ] **Step 1: Write failing tests**

Create `test/domain/cosmetic_loadout_test.dart`:

```dart
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
```

- [ ] **Step 2: Run tests — expect FAIL**

```powershell
$env:PUB_CACHE='C:\dev\pub-cache'
cd "C:\Users\Framework 16\Documents\Projects\lung-buddy"
flutter test test/domain/cosmetic_loadout_test.dart
```

Expected: compile errors (`CosmeticLoadout` / `slot` missing).

- [ ] **Step 3: Implement domain types**

`lib/domain/cosmetic_slot.dart`:

```dart
enum CosmeticSlot { hat, eyes, back, face }

extension CosmeticSlotX on CosmeticSlot {
  String get label => switch (this) {
        CosmeticSlot.hat => 'Hat',
        CosmeticSlot.eyes => 'Eyes',
        CosmeticSlot.back => 'Back',
        CosmeticSlot.face => 'Face',
      };
}
```

`lib/domain/cosmetic_loadout.dart`:

```dart
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
```

- [ ] **Step 4: Add `slot` to catalog**

In `lib/domain/cosmetic_catalog.dart`:

1. Import `cosmetic_slot.dart`.
2. Add `final CosmeticSlot? slot;` to `CosmeticDef` (nullable only for `none`).
3. Set slots on every item:

| Slot | IDs |
|---|---|
| hat | `beanie_mint`, `bow_coral`, `party_crown`, `top_hat`, `couch_hat`, `pirate_bandana`, `frog_hat`, `sleepy_cap`, `golden_crown` |
| eyes | `shades`, `sun_visors`, `heart_specs`, `diamond_shades`, `monocle` |
| back | `streak_cape`, `scarf_sunset`, `rainbow_scarf`, `angel_wings` |
| face | `bandage`, `flower`, `halo`, `antenna`, `legend_horns`, `mustache`, `leaf_pin`, `star_stud`, `devil_horns`, `sparkle_aura` |
| none | `slot: null` |

4. Keep `CosmeticKind` for now if painter still references it; painter rewrite (Task 5) will prefer `slot`.
5. Add helper:

```dart
static List<CosmeticDef> itemsForSlot(CosmeticSlot slot) =>
    items.where((c) => c.slot == slot).toList();
```

- [ ] **Step 5: Run tests — expect PASS**

```powershell
flutter test test/domain/cosmetic_loadout_test.dart
```

- [ ] **Step 6: Commit**

```powershell
git add lib/domain/cosmetic_slot.dart lib/domain/cosmetic_loadout.dart lib/domain/cosmetic_catalog.dart test/domain/cosmetic_loadout_test.dart
git -c user.name="hashard" -c user.email="hashard@users.noreply.github.com" commit -m "Add CosmeticLoadout and slot mapping for mix-and-match cosmetics."
```

---

### Task 2: Drift schema v6 + settings repo

**Files:**
- Modify: `lib/data/db.dart`
- Regenerate: `lib/data/db.g.dart`
- Modify: `lib/data/repositories/settings_repository.dart`

- [ ] **Step 1: Add columns on Settings**

In `lib/data/db.dart` `Settings` table, add:

```dart
TextColumn get hatCosmeticId =>
    text().withDefault(const Constant(''))();
TextColumn get eyesCosmeticId =>
    text().withDefault(const Constant(''))();
TextColumn get backCosmeticId =>
    text().withDefault(const Constant(''))();
TextColumn get faceCosmeticId =>
    text().withDefault(const Constant(''))();
```

Keep `equippedCosmeticId` column for migration read; do not drop (SQLite/Drift simplicity).

Bump `schemaVersion` to `6`. In `onUpgrade`:

```dart
if (from < 6) {
  await m.addColumn(settings, settings.hatCosmeticId);
  await m.addColumn(settings, settings.eyesCosmeticId);
  await m.addColumn(settings, settings.backCosmeticId);
  await m.addColumn(settings, settings.faceCosmeticId);
  // Copy legacy single equip into the correct slot.
  final rows = await customSelect(
    'SELECT equipped_cosmetic_id FROM settings WHERE id = 1',
  ).get();
  if (rows.isNotEmpty) {
    final legacy = rows.first.read<String>('equipped_cosmetic_id');
    if (legacy.isNotEmpty && legacy != 'none') {
      // Use a Dart-side map via raw UPDATE after codegen — see Step 3.
    }
  }
}
```

Prefer doing the legacy copy in `SettingsRepository.requireSettings` / a one-shot `migrateLoadoutIfNeeded()` called from `requireSettings` so we can use `CosmeticCatalog.byId` without awkward SQL in migration. Migration only adds columns.

- [ ] **Step 2: Regenerate Drift**

```powershell
$env:PUB_CACHE='C:\dev\pub-cache'
cd "C:\Users\Framework 16\Documents\Projects\lung-buddy"
# Prefer C:\dev\lung-buddy if that is the build root — keep repos in sync
dart run build_runner build
```

- [ ] **Step 3: Settings repository API**

Replace `setEquippedCosmetic` with:

```dart
Future<CosmeticLoadout> loadout() async {
  final s = await requireSettings();
  await _migrateLegacyEquipIfNeeded(s);
  final fresh = await requireSettings();
  return CosmeticLoadout.fromSettings(
    hatCosmeticId: fresh.hatCosmeticId,
    eyesCosmeticId: fresh.eyesCosmeticId,
    backCosmeticId: fresh.backCosmeticId,
    faceCosmeticId: fresh.faceCosmeticId,
  );
}

Future<void> setLoadout(CosmeticLoadout loadout) async {
  await (_db.update(_db.settings)..where((t) => t.id.equals(1))).write(
    SettingsCompanion(
      hatCosmeticId: Value(loadout.hatId ?? ''),
      eyesCosmeticId: Value(loadout.eyesId ?? ''),
      backCosmeticId: Value(loadout.backId ?? ''),
      faceCosmeticId: Value(loadout.faceId ?? ''),
      equippedCosmeticId: Value(loadout.ids.isEmpty ? 'none' : loadout.ids.first),
    ),
  );
}

Future<void> _migrateLegacyEquipIfNeeded(Setting s) async {
  final already = s.hatCosmeticId.isNotEmpty ||
      s.eyesCosmeticId.isNotEmpty ||
      s.backCosmeticId.isNotEmpty ||
      s.faceCosmeticId.isNotEmpty;
  if (already) return;
  final legacy = s.equippedCosmeticId;
  if (legacy.isEmpty || legacy == 'none') return;
  final item = CosmeticCatalog.byId(legacy);
  if (item.slot == null) return;
  final loadout = const CosmeticLoadout().equip(item);
  await setLoadout(loadout);
}
```

Remove public callers of `setEquippedCosmetic` in later tasks; keep a thin private wrapper if needed during transition.

- [ ] **Step 4: Analyze**

```powershell
flutter analyze lib/data/db.dart lib/data/repositories/settings_repository.dart
```

Expected: no issues (or only unused `setEquippedCosmetic` until Task 3).

- [ ] **Step 5: Commit**

```powershell
git add lib/data/db.dart lib/data/db.g.dart lib/data/repositories/settings_repository.dart
git -c user.name="hashard" -c user.email="hashard@users.noreply.github.com" commit -m "Add four-slot cosmetic loadout columns (schema v6)."
```

---

### Task 3: Providers — PlusState + HomeVm use loadout

**Files:**
- Modify: `lib/providers/plus_providers.dart`
- Modify: `lib/providers/home_providers.dart`
- Modify: `lib/services/buddy_widget_sync.dart` (loadout read only; render in Task 6)

- [ ] **Step 1: Update PlusState**

```dart
class PlusState {
  final bool isPlus;
  final CosmeticLoadout loadout;
  final int bestStreak;
  final Set<String> unlockedRewardIds;
  // ...
  bool isEquipped(CosmeticDef item) => loadout.isEquipped(item.id);
}
```

`plusStateProvider`: build loadout via `settingsRepo.loadout()` (or from settings fields after migrate).

`PlusActions`:

```dart
Future<void> toggleEquip(CosmeticDef item) async {
  // unlock check same as today
  final current = await _ref.read(settingsRepositoryProvider).loadout();
  final next = current.equip(item); // toggles clear if same id
  await _ref.read(settingsRepositoryProvider).setLoadout(next);
  _ref.invalidate(plusStateProvider);
  _ref.invalidate(homeVmProvider);
  await BuddyWidgetSync.syncFromRepos(...);
}

Future<void> clearSlot(CosmeticSlot slot) async {
  final current = await _ref.read(settingsRepositoryProvider).loadout();
  await _ref.read(settingsRepositoryProvider).setLoadout(current.clear(slot));
  // invalidate + widget sync
}
```

On `clearPlusPlaceholder`: for each id in `loadout.ids`, if `!canUse` after Plus off, clear that slot.

- [ ] **Step 2: Update HomeVm**

Replace `CosmeticDef cosmetic` with `CosmeticLoadout loadout`. Build loadout from settings; for each equipped id, if `!CosmeticUnlocks.canUse`, treat that slot as empty when constructing the paint loadout (do not necessarily write DB unless you want auto-strip — prefer strip on read for paint only, or clear in repo — **clear invalid slots when building HomeVm** and persist once to avoid ghost locked drip).

- [ ] **Step 3: Fix compile errors in call sites temporarily**

MascotView / Closet / BuddyRender will break until Tasks 4–6. Either:
- Add a temporary `LungPainter` constructor overload accepting loadout with fallback single cosmetic, or
- Update all call sites in the same session after Task 4 starts.

Prefer updating call sites in Tasks 4–6 immediately after painter API changes.

- [ ] **Step 4: Commit**

```powershell
git add lib/providers/plus_providers.dart lib/providers/home_providers.dart
git -c user.name="hashard" -c user.email="hashard@users.noreply.github.com" commit -m "Wire Plus and Home providers to CosmeticLoadout."
```

---

### Task 4: LungPainter — Grok body + loadout API

**Files:**
- Modify: `lib/ui/home/lung_painter.dart` (large rewrite)
- Modify: `lib/ui/home/mascot_view.dart`
- Modify: `lib/ui/widgets/buddy_render.dart`
- Modify: `test/cosmetic_preview_test.dart` / `test/generate_brand_art_test.dart` / `test/generate_promo_pack_test.dart` as needed

- [ ] **Step 1: Change painter constructor**

```dart
class LungPainter extends CustomPainter {
  LungPainter({
    required this.smokeRatio,
    required this.coughPhase,
    this.flowPhase = 0,
    this.loadout = CosmeticLoadout.empty,
  });

  final CosmeticLoadout loadout;
  // remove single CosmeticDef cosmetic field
}
```

- [ ] **Step 2: Redraw body toward Grok look**

Implement in `paint`:

1. Resolve defs: `hat = byId(loadout.hatId)`, etc. (null-safe → none).
2. Draw **back** cosmetics first (`loadout.backId`: cape/scarf/wings) — reuse/adapt existing `_drawBehindCosmetics` but keyed off back item id.
3. Body path: rounder bean lobes, centered trachea stub, **white sticker rim** (stroke white ~8px then ink ~5px), **freckle spots** on outer lobes (2–3 soft darker pink circles each side).
4. Face: larger white eyes + pupils + shine, blush ovals, **U-smile with small tongue** when `smokeRatio < 0.55`; keep worried/frown path when sootier.
5. Draw eyes-slot glasses.
6. Draw hat-slot.
7. Draw face-slot (halo above hat; mustache/bandage/etc. on face).
8. Keep cough puffs / smoke darkening lerp.

Reference image: Desktop / brainstorm `grok-target.png` and `promo-for-grok` mood PNGs for proportions — do not paste raster; redraw in paths.

- [ ] **Step 3: Update `shouldRepaint`**

Compare smoke/cough/flow + all four loadout ids.

- [ ] **Step 4: Update MascotView + BuddyRender**

Pass `loadout:` instead of `cosmetic:`.

- [ ] **Step 5: Smoke render test**

```powershell
flutter test test/cosmetic_preview_test.dart
# or a small new test that PictureRecorder paints beanie+halo+cape loadout
```

Add `test/ui/lung_painter_loadout_smoke_test.dart`:

```dart
test('paints mixed loadout without throwing', () async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  LungPainter(
    smokeRatio: 0.08,
    coughPhase: 0,
    loadout: const CosmeticLoadout(
      hatId: 'beanie_mint',
      backId: 'streak_cape',
      faceId: 'halo',
    ),
  ).paint(canvas, const Size(400, 400));
  final img = await recorder.endRecording().toImage(400, 400);
  expect(img.width, 400);
});
```

- [ ] **Step 6: Commit**

```powershell
git add lib/ui/home/lung_painter.dart lib/ui/home/mascot_view.dart lib/ui/widgets/buddy_render.dart test/
git -c user.name="hashard" -c user.email="hashard@users.noreply.github.com" commit -m "Redesign LungPainter for Grok look and multi-slot loadout."
```

---

### Task 5: Closet UI — slot tabs

**Files:**
- Rewrite: `lib/ui/closet/closet_screen.dart`

- [ ] **Step 1: Convert to StatefulWidget with selected tab**

```dart
class _ClosetScreenState extends ConsumerState<ClosetScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: CosmeticSlot.values.length, vsync: this);
  }
  // dispose _tabs
}
```

- [ ] **Step 2: Layout**

1. Preview `CustomPaint` with `plus.loadout`
2. Row of 4 chips: for each slot, show equipped name or `Empty`; onTap → `_tabs.animateTo(index)`
3. `TabBar` labels from `CosmeticSlot.label`
4. `TabBarView`: for selected slot, list `CosmeticCatalog.itemsForSlot(slot)`
5. Row actions: if equipped → show ON + tap toggles clear via `plusActions.toggleEquip`; else WEAR / LOCKED

Remove unlock-source sections (Starters/Streaks/…) as primary nav — unlock hint stays on subtitle.

Keep Plus buy button when `!plus.isPlus`.

- [ ] **Step 3: Manual dogfood checklist** (document in commit message)

- Wear beanie + cape + shades + halo together  
- Tap second hat → replaces first  
- Tap equipped halo → clears face slot  

- [ ] **Step 4: Commit**

```powershell
git add lib/ui/closet/closet_screen.dart
git -c user.name="hashard" -c user.email="hashard@users.noreply.github.com" commit -m "Rebuild closet with slot tabs and loadout preview."
```

---

### Task 6: Widget sync + home compile clean

**Files:**
- Modify: `lib/services/buddy_widget_sync.dart`
- Modify: `lib/ui/home/home_screen.dart` (if still passing `cosmetic`)
- Grep remaining `equippedCosmetic` / `cosmetic:` painter args

- [ ] **Step 1: Grep cleanup**

```powershell
rg "equippedCosmetic|cosmetic: widget\.cosmetic|LungPainter\(" lib
```

Fix every hit to loadout.

- [ ] **Step 2: BuddyWidgetSync**

Build `CosmeticLoadout` from settings (with unlock strip), pass to `BuddyRender(loadout: ...)`.

- [ ] **Step 3: Analyze + tests**

```powershell
flutter analyze
flutter test
```

Expected: pass (update any broken tests).

- [ ] **Step 4: Commit**

```powershell
git add lib/
git -c user.name="hashard" -c user.email="hashard@users.noreply.github.com" commit -m "Finish loadout wiring for home and home-screen widget."
```

---

### Task 7: Regenerate brand art (follow-up, still in plan)

**Files:**
- Modify: `test/generate_brand_art_test.dart` to use `loadout:`
- Run generator; run `dart run flutter_launcher_icons`
- Commit new PNGs

- [ ] **Step 1: Update generator tests for loadout API**
- [ ] **Step 2: Run**

```powershell
flutter test test/generate_brand_art_test.dart
dart run flutter_launcher_icons
```

- [ ] **Step 3: Commit**

```powershell
git add assets/ android/app/src/main/res/ ios/Runner/Assets.xcassets/
git -c user.name="hashard" -c user.email="hashard@users.noreply.github.com" commit -m "Regenerate launcher and mascot art from new LungPainter."
```

---

## Spec coverage check

| Spec requirement | Task |
|---|---|
| Close-match Grok body | Task 4 |
| 4 exclusive slots | Tasks 1–3, 5 |
| Loadout persistence + migration | Task 2 |
| Closet slot tabs | Task 5 |
| Home/widget wiring | Tasks 3, 6 |
| Art regen | Task 7 |
| Unit tests slot/equip | Task 1 |
| Paint smoke for beanie+halo+cape | Task 4 |

## Placeholder scan

No TBD/TODO steps; slot ID table explicit; commands and commit messages included.
