# Lung Buddy Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship a Flutter Android v1 of Lung Buddy — local-only cut-down tracker with daily budget, one-tap logging, lung mascot moods, streaks, and optional challenges.

**Architecture:** Flutter app with Riverpod for state, Drift (SQLite) for on-device persistence, and a pure Dart domain layer (day-won, streak, challenges, mascot mood) tested with unit tests. UI is three tabs (Home / Progress / Challenges) plus onboarding and settings. No backend, auth, or billing.

**Tech Stack:** Flutter 3.x, Dart, flutter_riverpod, drift + drift_flutter + sqlite3_flutter_libs, go_router (or simple Navigator), fl_chart (Progress), flutter_test / mockito or riverpod testing.

**Spec:** [docs/superpowers/specs/2026-10-23-lung-buddy-design.md](../specs/2026-10-23-lung-buddy-design.md)

---

## File map (create)

```
lung-buddy/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── theme/app_theme.dart
│   ├── data/
│   │   ├── db.dart                 # Drift database + tables
│   │   ├── db.g.dart               # generated
│   │   └── repositories/
│   │       ├── smoke_repository.dart
│   │       ├── settings_repository.dart
│   │       └── challenge_repository.dart
│   ├── domain/
│   │   ├── models.dart             # DayResult, StreakInfo, MascotMood, ChallengeDef
│   │   ├── day_evaluator.dart      # count vs budget → won / in progress
│   │   ├── streak_calculator.dart
│   │   ├── mascot_mood.dart
│   │   ├── challenge_engine.dart
│   │   └── challenge_catalog.dart  # 5 static packs
│   ├── providers/
│   │   ├── database_provider.dart
│   │   ├── home_providers.dart
│   │   └── challenge_providers.dart
│   ├── ui/
│   │   ├── shell/main_shell.dart    # bottom nav
│   │   ├── home/home_screen.dart
│   │   ├── home/mascot_view.dart
│   │   ├── progress/progress_screen.dart
│   │   ├── challenges/challenges_screen.dart
│   │   ├── onboarding/onboarding_flow.dart
│   │   └── settings/settings_screen.dart
│   └── l10n/copy.dart              # cheeky strings (no medical claims)
├── test/
│   ├── domain/day_evaluator_test.dart
│   ├── domain/streak_calculator_test.dart
│   ├── domain/mascot_mood_test.dart
│   ├── domain/challenge_engine_test.dart
│   └── widget/home_screen_test.dart
├── assets/mascot/                  # happy, chill, worried, celebrate placeholders
└── pubspec.yaml
```

---

### Task 1: Scaffold Flutter project

**Files:**
- Create: project root via `flutter create`
- Modify: `pubspec.yaml`, `analysis_options.yaml`

- [ ] **Step 1: Create the app**

```bash
cd "C:\Users\Framework 16\Documents\Projects"
flutter create --org com.lungbuddy --project-name lung_buddy lung-buddy-app
```

Note: Spec/docs already live under `lung-buddy/`. Either create the Flutter app inside `lung-buddy/` (preferred: `flutter create .` from that folder after moving docs aside temporarily) **or** create `lung-buddy-app` and move `docs/` into it. Prefer **one repo root**:

```bash
cd "C:\Users\Framework 16\Documents\Projects\lung-buddy"
flutter create --org com.lungbuddy --project-name lung_buddy .
```

If `flutter create .` refuses non-empty dir, create in a temp folder and merge `lib/`, `pubspec.yaml`, `android/` into `lung-buddy/` keeping `docs/`.

- [ ] **Step 2: Add dependencies to `pubspec.yaml`**

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1
  drift: ^2.22.1
  drift_flutter: ^0.2.4
  sqlite3_flutter_libs: ^0.5.28
  path_provider: ^2.1.5
  path: ^1.9.1
  go_router: ^14.8.1
  fl_chart: ^0.70.2
  intl: ^0.19.0
  share_plus: ^10.1.4

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  build_runner: ^2.4.14
  drift_dev: ^2.22.1
  riverpod_generator: ^2.6.3
  mockito: ^5.4.5
```

- [ ] **Step 3: Enable assets and Material 3**

In `pubspec.yaml`:

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/mascot/
```

Create placeholder PNGs or SVGs later in Task 10 (`happy.png`, `chill.png`, `worried.png`, `celebrate.png`). For now empty dir + 1x1 placeholder is fine.

- [ ] **Step 4: Verify analyze**

```bash
cd "C:\Users\Framework 16\Documents\Projects\lung-buddy"
flutter pub get
flutter analyze
```

Expected: no errors (warnings OK).

- [ ] **Step 5: Commit**

```bash
git init
git add -A
git commit -m "chore: scaffold Flutter Lung Buddy project"
```

---

### Task 2: Domain models + day evaluator (TDD)

**Files:**
- Create: `lib/domain/models.dart`
- Create: `lib/domain/day_evaluator.dart`
- Test: `test/domain/day_evaluator_test.dart`

- [ ] **Step 1: Write failing tests**

```dart
// test/domain/day_evaluator_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:lung_buddy/domain/day_evaluator.dart';
import 'package:lung_buddy/domain/models.dart';

void main() {
  final day = DateTime(2026, 10, 23);

  test('under budget is day won when day is complete', () {
    final r = DayEvaluator.evaluate(
      date: day,
      smokeCount: 4,
      budget: 10,
      now: DateTime(2026, 10, 24, 0, 1), // next day → complete
    );
    expect(r.status, DayStatus.won);
    expect(r.smokeCount, 4);
  });

  test('over budget is lost when day is complete', () {
    final r = DayEvaluator.evaluate(
      date: day,
      smokeCount: 12,
      budget: 10,
      now: DateTime(2026, 10, 24),
    );
    expect(r.status, DayStatus.lost);
  });

  test('today under budget is inProgress, not won yet', () {
    final r = DayEvaluator.evaluate(
      date: day,
      smokeCount: 3,
      budget: 10,
      now: DateTime(2026, 10, 23, 15),
    );
    expect(r.status, DayStatus.inProgress);
  });

  test('today over budget is lost even before midnight', () {
    final r = DayEvaluator.evaluate(
      date: day,
      smokeCount: 11,
      budget: 10,
      now: DateTime(2026, 10, 23, 15),
    );
    expect(r.status, DayStatus.lost);
  });

  test('no budget and no events is empty (breaks streak later)', () {
    final r = DayEvaluator.evaluate(
      date: day,
      smokeCount: 0,
      budget: null,
      now: DateTime(2026, 10, 24),
      hadAnyBudgetOrOpen: false,
    );
    expect(r.status, DayStatus.empty);
  });
}
```

- [ ] **Step 2: Run tests — expect FAIL**

```bash
flutter test test/domain/day_evaluator_test.dart
```

Expected: FAIL (library not found).

- [ ] **Step 3: Implement models + evaluator**

```dart
// lib/domain/models.dart
enum DayStatus { won, lost, inProgress, empty }

class DayResult {
  final DateTime date; // date-only local
  final int smokeCount;
  final int? budget;
  final DayStatus status;
  const DayResult({
    required this.date,
    required this.smokeCount,
    required this.budget,
    required this.status,
  });
}

enum MascotMood { happy, chill, worried, celebrate }

class StreakInfo {
  final int current; // completed won days only
  final int best;
  const StreakInfo({required this.current, required this.best});
}
```

```dart
// lib/domain/day_evaluator.dart
import 'models.dart';

class DayEvaluator {
  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static DayResult evaluate({
    required DateTime date,
    required int smokeCount,
    required int? budget,
    required DateTime now,
    bool hadAnyBudgetOrOpen = true,
  }) {
    final d = dateOnly(date);
    final today = dateOnly(now);
    if (!hadAnyBudgetOrOpen && smokeCount == 0 && budget == null) {
      return DayResult(date: d, smokeCount: 0, budget: null, status: DayStatus.empty);
    }
    final b = budget;
    if (b == null) {
      return DayResult(date: d, smokeCount: smokeCount, budget: null, status: DayStatus.empty);
    }
    final isToday = d == today;
    if (smokeCount > b) {
      return DayResult(date: d, smokeCount: smokeCount, budget: b, status: DayStatus.lost);
    }
    if (isToday) {
      return DayResult(date: d, smokeCount: smokeCount, budget: b, status: DayStatus.inProgress);
    }
    return DayResult(date: d, smokeCount: smokeCount, budget: b, status: DayStatus.won);
  }
}
```

- [ ] **Step 4: Run tests — expect PASS**

```bash
flutter test test/domain/day_evaluator_test.dart
```

- [ ] **Step 5: Commit**

```bash
git add lib/domain test/domain/day_evaluator_test.dart
git commit -m "feat: add day evaluator and domain models"
```

---

### Task 3: Streak calculator (TDD)

**Files:**
- Create: `lib/domain/streak_calculator.dart`
- Test: `test/domain/streak_calculator_test.dart`

- [ ] **Step 1: Write failing tests**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:lung_buddy/domain/models.dart';
import 'package:lung_buddy/domain/streak_calculator.dart';

void main() {
  DateTime d(int day) => DateTime(2026, 10, day);

  DayResult won(int day) => DayResult(
        date: d(day), smokeCount: 2, budget: 10, status: DayStatus.won);
  DayResult lost(int day) => DayResult(
        date: d(day), smokeCount: 12, budget: 10, status: DayStatus.lost);
  DayResult empty(int day) => DayResult(
        date: d(day), smokeCount: 0, budget: null, status: DayStatus.empty);
  DayResult progress(int day) => DayResult(
        date: d(day), smokeCount: 2, budget: 10, status: DayStatus.inProgress);

  test('current streak counts consecutive completed wins ending yesterday', () {
    final info = StreakCalculator.compute(
      days: [won(20), won(21), won(22), progress(23)],
      today: d(23),
      bestEver: 5,
    );
    expect(info.current, 3);
    expect(info.best, 5);
  });

  test('empty day breaks streak', () {
    final info = StreakCalculator.compute(
      days: [won(20), empty(21), won(22)],
      today: d(23),
      bestEver: 2,
    );
    // only Oct 22 completed win contiguous from yesterday? yesterday=22 → 1
    expect(info.current, 1);
  });

  test('lost day breaks streak', () {
    final info = StreakCalculator.compute(
      days: [won(21), lost(22), progress(23)],
      today: d(23),
      bestEver: 10,
    );
    expect(info.current, 0);
  });

  test('updates best when current exceeds bestEver', () {
    final info = StreakCalculator.compute(
      days: [won(21), won(22)],
      today: d(23),
      bestEver: 1,
    );
    expect(info.current, 2);
    expect(info.best, 2);
  });
}
```

- [ ] **Step 2: Run — expect FAIL**

```bash
flutter test test/domain/streak_calculator_test.dart
```

- [ ] **Step 3: Implement**

```dart
// lib/domain/streak_calculator.dart
import 'models.dart';
import 'day_evaluator.dart';

class StreakCalculator {
  static StreakInfo compute({
    required List<DayResult> days,
    required DateTime today,
    required int bestEver,
  }) {
    final byDate = {
      for (final r in days) DayEvaluator.dateOnly(r.date): r,
    };
    var cursor = DayEvaluator.dateOnly(today).subtract(const Duration(days: 1));
    var current = 0;
    while (true) {
      final r = byDate[cursor];
      if (r == null || r.status != DayStatus.won) break;
      current++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    final best = current > bestEver ? current : bestEver;
    return StreakInfo(current: current, best: best);
  }
}
```

- [ ] **Step 4: Run — expect PASS**

```bash
flutter test test/domain/streak_calculator_test.dart
```

- [ ] **Step 5: Commit**

```bash
git add lib/domain/streak_calculator.dart test/domain/streak_calculator_test.dart
git commit -m "feat: add streak calculator for consecutive day wins"
```

---

### Task 4: Mascot mood (TDD)

**Files:**
- Create: `lib/domain/mascot_mood.dart`
- Create: `lib/l10n/copy.dart`
- Test: `test/domain/mascot_mood_test.dart`

- [ ] **Step 1: Write failing tests**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:lung_buddy/domain/mascot_mood.dart';
import 'package:lung_buddy/domain/models.dart';

void main() {
  test('zero smokes early → happy', () {
    expect(
      MascotMoodLogic.fromToday(smokeCount: 0, budget: 10, nowHour: 9),
      MascotMood.happy,
    );
  });

  test('under half budget → chill', () {
    expect(
      MascotMoodLogic.fromToday(smokeCount: 3, budget: 10, nowHour: 14),
      MascotMood.chill,
    );
  });

  test('near budget → worried', () {
    expect(
      MascotMoodLogic.fromToday(smokeCount: 9, budget: 10, nowHour: 18),
      MascotMood.worried,
    );
  });

  test('over budget → worried (never shame state)', () {
    expect(
      MascotMoodLogic.fromToday(smokeCount: 12, budget: 10, nowHour: 20),
      MascotMood.worried,
    );
  });

  test('celebrate when yesterday won and today still under', () {
    expect(
      MascotMoodLogic.fromToday(
        smokeCount: 1,
        budget: 10,
        nowHour: 10,
        yesterdayWon: true,
      ),
      MascotMood.celebrate,
    );
  });
}
```

- [ ] **Step 2: Implement**

```dart
// lib/domain/mascot_mood.dart
import 'models.dart';

class MascotMoodLogic {
  static MascotMood fromToday({
    required int smokeCount,
    required int budget,
    required int nowHour,
    bool yesterdayWon = false,
  }) {
    if (smokeCount > budget) return MascotMood.worried;
    if (yesterdayWon && smokeCount <= budget * 0.3) return MascotMood.celebrate;
    if (smokeCount == 0) return MascotMood.happy;
    if (smokeCount >= budget) return MascotMood.worried; // equal = on edge
    if (smokeCount >= (budget * 0.7).floor()) return MascotMood.worried;
    if (smokeCount >= (budget * 0.4).floor()) return MascotMood.chill;
    return MascotMood.happy;
  }
}
```

```dart
// lib/l10n/copy.dart
import '../domain/models.dart';

class Copy {
  static String mascotLine(MascotMood mood, {required int count, required int budget}) {
    switch (mood) {
      case MascotMood.happy:
        return "Fresh lungs vibes. You're doing great.";
      case MascotMood.chill:
        return "Steady pace — $count of $budget so far.";
      case MascotMood.worried:
        return count > budget
            ? "Rough day happens. Tomorrow's a fresh budget."
            : "Getting close to today's budget — no rush.";
      case MascotMood.celebrate:
        return "Streak energy! Keep today's tally honest.";
    }
  }

  static String streakBroken() =>
      "Streak paused — start a new one tomorrow. No guilt.";
}
```

- [ ] **Step 3: Run tests PASS + commit**

```bash
flutter test test/domain/mascot_mood_test.dart
git add lib/domain/mascot_mood.dart lib/l10n/copy.dart test/domain/mascot_mood_test.dart
git commit -m "feat: mascot mood rules and cheeky copy"
```

---

### Task 5: Challenge catalog + engine (TDD)

**Files:**
- Create: `lib/domain/challenge_catalog.dart`
- Create: `lib/domain/challenge_engine.dart`
- Extend: `lib/domain/models.dart`
- Test: `test/domain/challenge_engine_test.dart`

- [ ] **Step 1: Add challenge models to `models.dart`**

```dart
enum ChallengeKind {
  underYesterdayForDays,
  underBudgetForDays,
  underBaselineForDays,
  noSmokesBeforeNoonForDays,
  weekendUnderBudget,
}

class ChallengeDef {
  final String id;
  final String title;
  final String description;
  final ChallengeKind kind;
  final int targetDays;
  final String rewardId;
  const ChallengeDef({
    required this.id,
    required this.title,
    required this.description,
    required this.kind,
    required this.targetDays,
    required this.rewardId,
  });
}

enum ChallengeStatus { available, active, completed }

class ChallengeProgress {
  final String catalogId;
  final ChallengeStatus status;
  final int daysCompleted;
  final int targetDays;
  const ChallengeProgress({
    required this.catalogId,
    required this.status,
    required this.daysCompleted,
    required this.targetDays,
  });
}
```

- [ ] **Step 2: Catalog (5 packs)**

```dart
// lib/domain/challenge_catalog.dart
import 'models.dart';

class ChallengeCatalog {
  static const packs = <ChallengeDef>[
    ChallengeDef(
      id: 'under_yesterday_3',
      title: 'Two under yesterday',
      description: 'Beat yesterday by 2+ smokes, three days in a row.',
      kind: ChallengeKind.underYesterdayForDays,
      targetDays: 3,
      rewardId: 'sticker_spark',
    ),
    ChallengeDef(
      id: 'under_budget_5',
      title: 'Budget boss',
      description: 'Stay at or under budget for 5 days.',
      kind: ChallengeKind.underBudgetForDays,
      targetDays: 5,
      rewardId: 'sticker_star',
    ),
    ChallengeDef(
      id: 'under_baseline_7',
      title: 'Below usual',
      description: 'Stay under your usual baseline for 7 days.',
      kind: ChallengeKind.underBaselineForDays,
      targetDays: 7,
      rewardId: 'mood_party',
    ),
    ChallengeDef(
      id: 'morning_clear_3',
      title: 'Clear mornings',
      description: 'No smokes before noon for 3 days.',
      kind: ChallengeKind.noSmokesBeforeNoonForDays,
      targetDays: 3,
      rewardId: 'sticker_sun',
    ),
    ChallengeDef(
      id: 'weekend_budget',
      title: 'Chill weekend',
      description: 'Stay under budget Saturday and Sunday.',
      kind: ChallengeKind.weekendUnderBudget,
      targetDays: 2,
      rewardId: 'sticker_couch',
    ),
  ];
}
```

- [ ] **Step 3: Engine tests + implementation**

Test that `underBudgetForDays` increments on won days, resets progress day on loss, completes at target. Implement `ChallengeEngine.evaluateActive(...)` taking def, startDate, list of DayResults + smoke timestamps for morning challenge, baseline int.

```dart
// lib/domain/challenge_engine.dart — core API
class ChallengeEngine {
  static ChallengeProgress evaluate({
    required ChallengeDef def,
    required DateTime startedOn, // date-only
    required List<DayResult> daysSinceStart,
    required int baseline,
    required List<DateTime> smokeTimestamps, // for morning challenge
    required DateTime today,
  }) { /* ... */ }
}
```

Implement kind-specific logic in the same file; keep functions pure.

- [ ] **Step 4: `flutter test test/domain/challenge_engine_test.dart` PASS + commit**

```bash
git commit -m "feat: challenge catalog and progress engine"
```

---

### Task 6: Drift database + repositories

**Files:**
- Create: `lib/data/db.dart`
- Create: `lib/data/repositories/*.dart`
- Create: `lib/providers/database_provider.dart`

- [ ] **Step 1: Define Drift tables in `lib/data/db.dart`**

```dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'db.g.dart';

class SmokeEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get timestamp => dateTime()();
}

class DailyBudgets extends Table {
  // store date as YYYY-MM-DD string PK
  TextColumn get date => text()();
  IntColumn get limit => integer()();
  @override
  Set<Column> get primaryKey => {date};
}

class Settings extends Table {
  IntColumn get id => integer()(); // always 1
  IntColumn get usualBaseline => integer()();
  IntColumn get defaultBudget => integer()();
  BoolColumn get onboardingDone => boolean().withDefault(const Constant(false))();
  TextColumn get buddyName => text().withDefault(const Constant('Buddy'))();
  IntColumn get bestStreak => integer().withDefault(const Constant(0))();
  @override
  Set<Column> get primaryKey => {id};
}

class ChallengeRows extends Table {
  TextColumn get catalogId => text()();
  TextColumn get status => text()(); // active | completed
  DateTimeColumn get startedAt => dateTime().nullable()();
  IntColumn get daysCompleted => integer().withDefault(const Constant(0))();
  @override
  Set<Column> get primaryKey => {catalogId};
}

class RewardRows extends Table {
  TextColumn get id => text()();
  DateTimeColumn get unlockedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [SmokeEvents, DailyBudgets, Settings, ChallengeRows, RewardRows])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_open());
  AppDatabase.forTesting(QueryExecutor e) : super(e);
  @override
  int get schemaVersion => 1;
}

LazyDatabase _open() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'lung_buddy.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
```

- [ ] **Step 2: Generate code**

```bash
dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 3: Repositories**

`SmokeRepository`: `logNow()`, `undoLastSameDay(DateTime now)`, `countForDate(DateTime)`, `eventsBetween(...)`.  
`SettingsRepository`: get/upsert settings, set budgets for date.  
`ChallengeRepository`: start (ensure only one active), cancel, mark completed, unlock reward.  
`ExportService`: JSON encode all tables; `wipeAll()`.

- [ ] **Step 4: Riverpod provider**

```dart
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
```

- [ ] **Step 5: Commit**

```bash
git commit -m "feat: Drift schema and repositories"
```

---

### Task 7: Home providers + logging actions

**Files:**
- Create: `lib/providers/home_providers.dart`
- Wire domain evaluators to repos

- [ ] **Step 1: Expose `todayHomeProvider`**

Async notifier or provider that returns a view model:

```dart
class HomeVm {
  final int count;
  final int budget;
  final StreakInfo streak;
  final MascotMood mood;
  final String mascotLine;
  final ChallengeProgress? activeChallenge;
  final bool todayOnTrack;
}
```

Load today’s events count, today’s budget (fallback default), build DayResults for last ~60 days for streak, compute mood + copy.

- [ ] **Step 2: `logSmokeProvider` / methods**

`ref.read(smokeActionsProvider).log()` inserts event and invalidates home.  
`undo()` deletes last same-day event.

- [ ] **Step 3: Manual smoke test via temporary debug button if UI not ready — or proceed to Task 8**

- [ ] **Step 4: Commit**

```bash
git commit -m "feat: home state providers for log, streak, mood"
```

---

### Task 8: Onboarding + app routing

**Files:**
- Create: `lib/ui/onboarding/onboarding_flow.dart`
- Create: `lib/app.dart`, update `lib/main.dart`

- [ ] **Step 1: Onboarding pages**

1. Welcome  
2. Usual daily count (int stepper)  
3. Suggested budget = max(usual - 1, 1) with edit  
4. Buddy name text field  
5. Honesty tip → mark `onboardingDone`, write settings + today’s budget row → go Home  

- [ ] **Step 2: `go_router`**

Redirect to `/onboarding` if `!onboardingDone`, else `/` shell.

- [ ] **Step 3: Commit**

```bash
git commit -m "feat: onboarding flow and router gate"
```

---

### Task 9: Main shell + Home UI

**Files:**
- Create: `lib/ui/shell/main_shell.dart`
- Create: `lib/ui/home/home_screen.dart`
- Create: `lib/ui/home/mascot_view.dart`
- Create: `lib/theme/app_theme.dart`
- Test: `test/widget/home_screen_test.dart`

- [ ] **Step 1: Theme** — playful, non-clinical colors (avoid purple-default AI look); soft greens/corals, rounded buddy-friendly shapes.

- [ ] **Step 2: Home layout**

- Top: settings gear  
- Center: `MascotView(mood)` + line + streak chip (`🔥 {current}` or friendly label without fire if preferred)  
- `count / budget` + linear/circular progress  
- Active challenge chip (if any)  
- Large **I smoked** button  
- Text button **Undo last**  

- [ ] **Step 3: Widget test** with overridden providers: expect count text and button present.

- [ ] **Step 4: Commit**

```bash
git commit -m "feat: Home screen with mascot, budget, and log CTA"
```

---

### Task 10: Mascot assets

**Files:**
- Create: `assets/mascot/happy.png`, `chill.png`, `worried.png`, `celebrate.png` (simple illustrated placeholders OK)

- [ ] **Step 1: Add four placeholder illustrations** (draw simple lung character variants or use temporary colored shapes exported as PNG).

- [ ] **Step 2: Wire `MascotView` to switch asset by `MascotMood`.

- [ ] **Step 3: Commit**

```bash
git commit -m "feat: mascot mood assets on Home"
```

---

### Task 11: Progress screen

**Files:**
- Create: `lib/ui/progress/progress_screen.dart`

- [ ] **Step 1: Show current + best streak**

- [ ] **Step 2: `fl_chart` bar chart** — last 7 / 30 days smoke counts; optional budget line.

- [ ] **Step 3: List recent days** with won/lost labels (gentle copy for lost).

- [ ] **Step 4: Commit**

```bash
git commit -m "feat: Progress tab with chart and streaks"
```

---

### Task 12: Challenges screen

**Files:**
- Create: `lib/ui/challenges/challenges_screen.dart`
- Create: `lib/providers/challenge_providers.dart`

- [ ] **Step 1: List catalog** with status badges; disable Start if another active.

- [ ] **Step 2: Start / abandon active challenge**; on completion unlock reward row + snackbar (“Reward unlocked — {id}”).

- [ ] **Step 3: Re-evaluate progress on each Home/Challenges open via engine + day results.**

- [ ] **Step 4: Commit**

```bash
git commit -m "feat: Challenges tab with catalog and one active pack"
```

---

### Task 13: Settings — budget, undo, export, wipe

**Files:**
- Create: `lib/ui/settings/settings_screen.dart`

- [ ] **Step 1: Edit today’s budget and default budget**

- [ ] **Step 2: Undo last log** (same as Home)

- [ ] **Step 3: Export JSON via `share_plus`**

- [ ] **Step 4: Delete all data** with confirm dialog → wipe DB → onboarding

- [ ] **Step 5: About / privacy blurb** — “No account. Data stays on this phone.”

- [ ] **Step 6: Commit**

```bash
git commit -m "feat: Settings for budget, export, and data wipe"
```

---

### Task 14: Android polish + manual QA

**Files:**
- Modify: `android/app/src/main/AndroidManifest.xml` (label, optional)
- Modify: launcher icon (flutter_launcher_icons optional)

- [ ] **Step 1: Set app label to `Lung Buddy`**

- [ ] **Step 2: Run on device/emulator**

```bash
flutter run
```

Checklist:
- [ ] Onboarding → Home  
- [ ] Log / undo updates count and mood  
- [ ] Under-budget completed days increase streak after midnight simulation (change device date or inject `now` in debug)  
- [ ] Over day shows rough-day copy; streak 0 next day  
- [ ] Start challenge; complete path  
- [ ] Export + wipe  

- [ ] **Step 3: Full test suite**

```bash
flutter test
```

Expected: all PASS.

- [ ] **Step 4: Commit**

```bash
git commit -m "chore: Android label and v1 QA pass"
```

---

## Spec coverage checklist

| Spec item | Task |
|-----------|------|
| Daily budget + one-tap log | 7, 9 |
| Undo same day | 6, 9, 13 |
| Mascot moods + copy | 4, 9, 10 |
| Day won / lean loop | 2 |
| Streaks (incl. empty break, today in progress) | 3, 9, 11 |
| Challenges 3–5 packs, one active | 5, 12 |
| Progress chart | 11 |
| Onboarding | 8 |
| Settings export/wipe/privacy | 13 |
| Local-only Drift | 6 |
| No billing / accounts / widgets | — intentionally omitted |
| Unit tests domain | 2–5 |
| Widget test Home | 9 |

---

## Execution handoff

Plan saved to `docs/superpowers/plans/2026-10-23-lung-buddy.md`.

**Two execution options:**

1. **Subagent-Driven (recommended)** — fresh subagent per task, review between tasks  
2. **Inline Execution** — run tasks in this session with checkpoints  

Which approach?
