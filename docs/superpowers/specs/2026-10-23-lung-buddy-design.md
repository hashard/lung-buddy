# Lung Buddy — Design Spec

**Date:** 2026-10-23  
**Status:** Ready for user review  
**Working name:** Lung Buddy (placeholder; final store name TBD)

## Summary

Lung Buddy is a light-hearted Android app that helps people **cut down** cigarette smoking over time. It pairs a goofy lung/body-buddy mascot with a soft daily game loop (budget, challenges, rewards, streaks). It is **not** a hard-quit coach and never shames the user for logging.

**v1 approach:** Lean loop — core logging, mascot, daily budget, streaks, a small challenge catalog, and simple progress. No accounts, no billing, no widgets/notifications yet.

## Goals

- Help users smoke **fewer** cigarettes over time without requiring a quit day.
- Feel fun and encouraging: mascot reactions + light goals/rewards.
- Ship a polished Play Store–ready Android app with a clear privacy story (local-only).

## Non-goals (v1)

- Forced quit / cold-turkey program
- Accounts, cloud sync, or social features
- Monetization (ads, IAP, tips) — leave billing out of v1 code
- Home screen widgets, push notifications / urge nudges
- Money-saved or detailed health-claim dashboards
- iOS (Flutter leaves the door open later)

## Personas & distribution

- **Audience:** Anyone on Android who wants to cut down; published on Google Play.
- **Tone:** Cheeky, warm, honest. Celebrate cuts and honesty. Over-budget days are “rough days,” not moral failure.

## Core product loop

1. **Budget** — User has a max cigarettes for today (set in onboarding; editable anytime).
2. **Log** — One primary action: “I smoked.” Optional undo (last log, same day).
3. **Mascot reacts** — Mood and short copy based on pace vs budget (playful, not medical).
4. **Win the day** — Stay at or under budget → day success + small reward cue.
5. **Streak** — Consecutive **days won** (at/under budget). Shown on Home and Progress. An over day gently breaks/pauses the streak (“start a new one tomorrow”). Logging is never punished.
6. **Challenges (optional)** — Short opt-in packs (e.g. “2 under yesterday for 3 days”). v1: at most one active challenge.

### Tone rules

- Never punish logging a cigarette.
- Never guilt-trip over-budget or broken streaks.
- No clinical/medical claims in copy or UI.

## Screens & navigation

### Bottom navigation (3 tabs)

| Tab | Purpose |
|-----|---------|
| **Home** | Mascot + today’s count/budget, streak badge, big **I smoked** button, active challenge chip, progress toward budget |
| **Progress** | Week/month chart (smokes vs budgets), recent days under/over, current + best streak |
| **Challenges** | Catalog (available / active / done); start one; clear reward copy |

### Other flows

- **Onboarding (first launch):** Welcome → usual daily count → suggested first budget (usual, or usual − 1) → meet/name the buddy → short honesty tip → Home.
- **Settings (gear on Home):** Edit today’s and default budget, undo last log, export data, delete all data, about / privacy (local-only).

## Mascot

- **Concept:** Tiny lung / body buddy — goofy health sidekick, not a doctor.
- **v1 expression:** Small set of mood states (e.g. happy, chill, worried, celebrate) + short string lines.
- Assets can start as simple illustrations; polish can iterate without changing domain logic.

## Streaks (first-class)

- **Definition:** Consecutive local calendar days where `smoke_count <= budget` for that day (**day won**).
- **Display:** Current streak on Home (near mascot) and Progress; best streak on Progress.
- **Break:** Over-budget day ends the current streak (gentle copy).
- **No-open / no-data days:** Days with no app open and no logs do **not** count as wins; they **break** the streak (simple, honest rule).
- **Evaluation:** Day boundary = device local midnight. Streak updates when a day closes or on next app open after midnight.
- **Today while in progress:** Home shows an “in progress” state for today. **Current streak** counts only *completed* won days; if yesterday was a win, show that streak and a positive cue if today is still under budget (today is not added until the day completes under budget).

## Challenges (v1 catalog)

Ship 3–5 starter packs, for example:

1. Two under yesterday — 3 days  
2. Stay under budget — 5 days  
3. One fewer than usual baseline — 7 days  
4. Smoke-free morning (no logs before noon) — 3 days  
5. Weekend under budget — Sat+Sun

**Rules:** Opt-in; one active at a time; progress derived from `smoke_events` + budgets; completion unlocks a simple reward flag (sticker / mood).

## Architecture

```
Flutter (Android-first)
├── UI (screens, mascot widgets)
├── State: Riverpod
├── Domain: log / undo / budget / streak / challenge evaluation
└── Data: Drift (SQLite) — on-device only
```

No backend, no auth, no analytics SDK required for v1 (optional later).

### Domain operations

- `logSmoke()` / `undoLastSmoke()`
- `setTodayBudget()` / `setDefaultBudget()`
- `startChallenge()` / `cancelChallenge()`
- `evaluateDay(date)` → under/over, day won
- `computeStreak()` → current + best
- `exportData()` / `wipeData()`

### Data model (Drift)

- **`smoke_events`** — id, timestamp  
- **`daily_budgets`** — date, limit  
- **`settings`** — usual_baseline, default_budget, onboarding_done, buddy_name  
- **`challenges`** — catalog_id, status, started_at, progress payload  
- **`rewards`** — id, unlocked_at (stickers/moods as simple flags)  
Day won / streak / charts are **computed on the fly** from `smoke_events` + `daily_budgets` in v1 (no separate summary table). Add a cache later only if performance requires it.

## Edge cases

| Case | Behavior |
|------|----------|
| Undo | Last log only, same calendar day; adjusts count, challenge progress, mood |
| Mid-day budget change | Recalculates today only; past days unchanged |
| Midnight / timezone | Local midnight day boundary |
| Missed days | Break streak; do not auto-win |
| Over budget | Rough-day copy; streak breaks; logging still encouraged |
| Export / wipe failure | Explicit error; no silent data loss |

## Error handling

- Local SQLite failures: user-visible “try again”; keep shell UI usable.
- No network error paths in v1.

## Testing

- **Unit:** day-won, streak (including missed-day break), budget change, challenge progress, undo.
- **Widget/golden (light):** Home with count + mascot state + streak.
- **Manual:** Real Android device before Play upload.

## Privacy & Play Store

- All data on-device.
- Settings: export + delete all data.
- Store listing / in-app about: clear “no account, data stays on your phone” messaging.
- No medical claims in listing copy.

## Out of scope → later candidates

- Widgets, reminders / urge support  
- Money saved  
- Optional cloud backup  
- Cosmetics / IAP / tips  
- Larger challenge catalog  
- iOS build  

## Success criteria (v1)

- User can onboard, set budget, log/undo, see mascot react, track streak, run one challenge, view progress chart.
- App works fully offline.
- Tone stays light-hearted across over-budget and streak-break copy.
- Ready for internal sideload / closed testing on Play.
