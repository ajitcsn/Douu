# Douu

Stay close to the people who matter. 100% local — no backend, no network calls, no telemetry.

## What it does

- Import phone contacts → sort the ~100 who matter into **user-named groups** (Family, College, Work…)
- Each group has a **cadence** (weekly / monthly / quarterly / custom)
- Every day Douu fires a low-pressure **quest**: reach out to any K of N due contacts
- One tap opens the right WhatsApp chat; you send the message; Douu tracks who you reached

## Tech stack

Flutter (Dart) · Drift (SQLite) · Riverpod · go_router · flutter_local_notifications

Full dependency list: [pubspec.yaml](pubspec.yaml)

---

## Build & run

### Prerequisites

| Tool | Version |
|------|---------|
| Flutter | ≥ 3.22 (stable channel) |
| Dart | ≥ 3.4 |
| Android SDK | minSdk 24, targetSdk latest stable |
| Java | 17 (for Gradle) |

```bash
# 1. Clone
git clone <repo-url> && cd douu

# 2. Install deps
flutter pub get

# 3. Generate Drift code  ← must run before first build
dart run build_runner build --delete-conflicting-outputs

# 4. Run on a connected device / emulator
flutter run
```

> **Never** add `internet` permission or any network dependency. The spec is explicit: local-only, forever.

---

## Project layout

```
lib/
  main.dart               ← entry; creates AppDatabase, wires ProviderScope
  app.dart                ← MaterialApp.router + theme
  router.dart             ← go_router route map (§6)
  providers.dart          ← all Riverpod providers
  config/
    defaults.dart         ← every [PLACEHOLDER] constant in one file
    theme.dart            ← colours, RAG palette, component defaults
  data/
    db/
      tables.dart         ← Drift table definitions (§4)
      database.dart       ← AppDatabase, migration, seeding
      database.g.dart     ← generated (run build_runner)
    repositories/
      douu_repository.dart
  domain/
    services/
      contacts_import.dart    §5.1
      phone_normalizer.dart   E.164 (IN-aware)
      quest_engine.dart       §5.2 + action path (reach/skip)
      streak_service.dart     §5.3, §5.4
      health_service.dart     §5.5 RAG
      notification_service.dart §5.6
      whatsapp_launcher.dart  §5.7
      backup_service.dart     §5.9
  features/
    splash/               S0
    onboarding/           S1–S6
    hub/                  S7
    groups/               S8, S9, S10 + shared ContactPicker
    contact/              S11
    quest/                S12, S13 (bottom sheet via mixin)
    insights/             S14
    settings/             S15, S16
  shared/widgets/
    douu_states.dart      DouuLoading / DouuEmpty / DouuError
    douu_bits.dart        DouuAvatar / RagDot / CadencePill / StreakChip
test/
  phone_normalizer_test.dart
```

---

## Development notes

### Regenerate Drift after schema changes

```bash
dart run build_runner build --delete-conflicting-outputs
```

### All tunable defaults

Edit [`lib/config/defaults.dart`](lib/config/defaults.dart). Every `[PLACEHOLDER]` constant from the spec lives here — quest size, cadence presets, RAG thresholds, etc.

### Open decisions (`// OPEN` in code)

| # | Decision | Default |
|---|----------|---------|
| 1 | Multi-group streak counting | Count toward all groups |
| 2 | Global streak long-gap reset | Never reset |
| 3 | Hub card tap target | Whole card → group detail |
| 4 | Create-group destination | → Group detail |
| 5 | Confirmation auto-dismiss | 10-min window after wa.me launch |
| 6 | NudgeLog in backup | Excluded (structure + scores only) |

### Play Store compliance (if publishing)

- File a **Play Console Developer Declaration** for `READ_CONTACTS` before 28 Oct 2026 (enforcement date for Android 17 / API 37+).
- Data Safety form: "no data collected, no data shared" — truthful and fast-track.

---

## Build milestones (spec §11)

| # | Milestone | Status |
|---|-----------|--------|
| M1 | Foundation: scaffold, theme, router, Drift schema, seed, S0 | ✅ |
| M2 | Contacts: permission flow, import + E.164, S3 | ✅ |
| M3 | Groups core: S4, S7, S8, S9, S10, quick-sort | ✅ |
| M4 | Scores: per-group streak, RAG health, S14 | ✅ |
| M5 | Quest + WhatsApp: quest engine, S12, wa.me handoff, S13, starters | ✅ |
| M6 | Reminders: notification service, S5, exact-alarm, OEM guidance | ✅ |
| M7 | Contact detail & settings: S11, S15 | ✅ |
| M8 | Backup: export/import AES-GCM, S16 | ✅ |
| M9 | Polish: empty/error/loading states, a11y, perf pass | 🔲 |

---

## Privacy

Nothing leaves this device. No analytics, no crash reporter, no HTTP client. The only outbound action is a `wa.me` deep link opened by the user. The only file output is an explicit user-triggered backup via `share_plus`.
