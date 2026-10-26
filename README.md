# Lung Buddy

Light-hearted Android app to help you **cut down** on smoking — daily budgets, streaks, optional challenges, and a goofy lung buddy mascot. Data stays on-device (no accounts).

## Spec & plan

- [Design](docs/superpowers/specs/2026-10-23-lung-buddy-design.md)
- [Implementation plan](docs/superpowers/plans/2026-10-23-lung-buddy.md)
- [Widget + store pack](docs/superpowers/specs/2026-10-25-widget-store-pack-design.md)
- [Privacy policy](docs/privacy-policy.md)
- [Play Store listing copy](docs/play-store-listing.md)

## Home widget (Android)

Plus unlocks live today count + streak on the launcher. Buy Plus → Settings → **Add widget**, or long-press home → Widgets → **Lung Buddy**.

## Release / Play Store

- [Play Console upload](docs/play-console-upload.md) — IAP `lung_buddy_plus`, signing, AAB
- [Listing copy](docs/play-store-listing.md)
- Privacy site: `privacy-site/` (deploy to Vercel)

```powershell
powershell -File tool/create_upload_keystore.ps1   # once
$env:PUB_CACHE = "C:\dev\pub-cache"
cd C:\dev\lung-buddy
flutter build appbundle --release
```

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
