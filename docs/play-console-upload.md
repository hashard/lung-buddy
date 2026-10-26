# Play Console upload checklist — Lung Buddy

## Before first upload

1. **Google Play Console** developer account (one-time fee).
2. Create app: **Lung Buddy**, package `com.lungbuddy.lung_buddy`.
3. **In-app product** (managed / non-consumable):
   - Product ID: `lung_buddy_plus`
   - Name: Lung Buddy Plus
   - Price: ~AUD / USD equivalent of **$6.99**
4. Add license testers (Settings → License testing) with your Google account.
5. Privacy policy URL (host `privacy-site/` on Vercel): paste into App content → Privacy policy.
6. Complete Data safety (local-only — see `docs/play-store-listing.md`).
7. Content rating questionnaire.

## Signing

```powershell
# Once, from repo root:
powershell -File tool/create_upload_keystore.ps1
# Saves android/upload-keystore.jks + android/key.properties (gitignored)
```

Backup the `.jks` and passwords offline. Losing them blocks updates.

## Build the AAB

```powershell
$env:PUB_CACHE = "C:\dev\pub-cache"
# mirror to C:\dev\lung-buddy if needed
cd C:\dev\lung-buddy
flutter pub get
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

## Store listing

Copy from `docs/play-store-listing.md`. Capture screenshots on a real phone (shot list in that file).

## What this repo cannot finish for you

- Clicking “Create app” / uploading the AAB in the Console UI
- Agreeing to Play policies
- Waiting for review
- iOS App Store (needs Mac + Apple Developer account)

## Analytics

Intentionally **not** added — matches the privacy policy (no analytics SDKs). Crash reports can wait until you want Firebase / Play Vitals only.
