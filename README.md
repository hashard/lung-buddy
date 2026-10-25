# Lung Buddy

Light-hearted Android app to help you **cut down** on smoking — daily budgets, streaks, optional challenges, and a goofy lung buddy mascot. Data stays on-device (no accounts).

## Spec & plan

- [Design](docs/superpowers/specs/2026-10-23-lung-buddy-design.md)
- [Implementation plan](docs/superpowers/plans/2026-10-23-lung-buddy.md)

## Run

```bash
flutter pub get
flutter run
```

### Windows path with spaces

If your user folder has spaces (e.g. `Framework 16`), Flutter’s native-assets hook for `objective_c` can fail. Work around by building from a path without spaces:

```powershell
$env:PUB_CACHE = "C:\dev\pub-cache"
cd C:\dev\lung-buddy   # copy or mirror of this project
flutter pub get
flutter run
# or: flutter build apk
```

## Tests

```bash
flutter test test/domain/ test/widget/home_screen_test.dart
```

## Stack

Flutter · Riverpod · Drift (SQLite) · go_router · fl_chart
