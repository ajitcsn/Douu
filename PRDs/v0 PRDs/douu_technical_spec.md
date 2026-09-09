# Douu — Technical Specification (v1)

> **Build target:** Flutter, **Android first** (iOS is a documented fast-follow, see §8.4).
> **Core constraint:** 100% local. No backend, no network calls, no telemetry. The only outbound action is launching a `wa.me` deep link.
> **Audience:** the implementing coding agent (Claude Code). This file is the single source of truth. Keep it updated as you build.

---

## 0. How to use this document (implementing agent)

- Build in the milestone order in §11. Do not jump ahead — later screens depend on the data model and domain logic from earlier milestones.
- Every screen in §7 has an **Acceptance criteria** checklist. A screen is "done" only when all boxes pass.
- Anything marked **[PLACEHOLDER]** is a tunable default, not a researched value. Implement it as a named constant in one config file (`lib/config/defaults.dart`) so it can be changed in one place.
- Anything marked **[OPEN]** is an unresolved product decision. Implement the stated default, leave a `// OPEN:` code comment, and do not block on it.
- Never add a networking dependency. If a task seems to need the network, stop and flag it — it's almost certainly a misread of the spec.

---

## 1. Product summary & non-negotiables

Douu helps a single user stay in regular contact with the people who matter. The user imports their phone contacts, sorts the important ones into **user-named groups** (Family, College, Work…), and each group has a **reminder cadence**. Douu fires local notifications — a low-pressure daily/weekly **quest** of who to reach out to — and deep-links the user straight into the right **WhatsApp** chat. Acting is one tap; sending the message is done by the user, manually, inside WhatsApp.

### Non-negotiables
1. **Local-only.** All data in on-device SQLite (Drift). Nothing is transmitted anywhere. The Data Safety / privacy disclosure is "no data collected, no data shared."
2. **No message automation.** Douu never sends a WhatsApp message. It only opens a chat via `wa.me`. (Automated personal-WhatsApp sending = ban risk; not in scope, ever.)
3. **No penalties, ever.** No streak can decrease. No "you're falling behind" copy anywhere — in UI or notifications. Skipping is free. Partial completion is a full win.
4. **Completion is self-reported.** Douu cannot verify a message was sent/delivered/read. All "in touch" data is self-reported intent. Never present it as proof.
5. **Default-to-invisible.** A contact not in any group generates no reminders. The user promotes the ~100 they care about; the rest stay silent forever.

---

## 2. Tech stack & dependencies

| Concern | Package | Notes |
|---|---|---|
| Framework | Flutter (stable) | `minSdkVersion 24`, target latest stable API |
| Language | Dart (null-safe) | |
| State mgmt | `flutter_riverpod` | Keep domain logic in providers, UI dumb & testable |
| Routing | `go_router` | Declarative routes per §6 |
| Local DB | `drift` + `sqlite3_flutter_libs` | Schema in §4 |
| Contacts | `flutter_contacts` | Read-only; request `READ_CONTACTS` |
| Phone normalization | `libphonenumber_plugin` (or `phone_numbers_parser`) | E.164, default region `IN` |
| Notifications | `flutter_local_notifications` | `zonedSchedule` for pre-scheduled reminders |
| Timezone | `timezone` | Required by `zonedSchedule` |
| Background (Android) | `workmanager` | Quest recompute / catch-up only — NOT the user-facing fire path |
| Launch WhatsApp | `url_launcher` | `wa.me` deep link |
| Permissions | `permission_handler` | Contacts, notifications, exact alarms |
| File export/import | `file_picker` + `share_plus` + `path_provider` | Backup (§5.9) |
| Encryption (backup) | `cryptography` (Dart) | AES-GCM for optional passphrase-protected export |

> Do **not** add: any analytics SDK, crash reporter that transmits, HTTP client, or Firebase. There are no network dependencies in this project.

---

## 3. Architecture & project structure

Layered, feature-first. Suggested layout:

```
lib/
  main.dart
  app.dart                      app shell, theme, router wiring
  config/
    defaults.dart               all [PLACEHOLDER] constants
    theme.dart
  data/
    db/
      database.dart             Drift database (§4)
      tables.dart               table definitions
      daos/                     ContactDao, GroupDao, QuestDao, etc.
    repositories/               thin wrappers exposing domain ops
  domain/
    models/                     plain Dart models / freezed
    services/
      contacts_import.dart      §5.1
      quest_engine.dart         §5.2
      streak_service.dart       §5.3, §5.4
      health_service.dart       §5.5
      notification_service.dart §5.6
      whatsapp_launcher.dart    §5.7
      backup_service.dart       §5.9
  features/
    onboarding/                 S1–S6
    hub/                        S7, quick-sort
    groups/                     S8, S9, S10
    contact/                    S11
    quest/                      S12, S13
    insights/                   S14
    settings/                   S15, S16
  shared/
    widgets/                    avatar, RAG dot, cadence pill, empty/error/loading
```

State rule: UI widgets read from Riverpod providers and call repository methods. No business logic in widgets.

---

## 4. Data model (Drift)

All timestamps stored as UTC epoch millis (`int`). All booleans real. Dates without time stored as `YYYY-MM-DD` text for streak day-keys.

```
TABLE Contact
  id              INTEGER PK AUTOINCREMENT
  systemContactId TEXT      -- platform contact identifier (for re-sync), nullable
  displayName     TEXT NOT NULL
  phoneE164       TEXT      -- normalized; nullable if no valid number
  phoneRaw        TEXT      -- original stored string (debugging/fallback)
  photoUri        TEXT      -- nullable
  isStarredOnImport BOOL NOT NULL DEFAULT 0
  lastReachedAt   INTEGER   -- UTC millis; nullable (never contacted via Douu)
  createdAt       INTEGER NOT NULL

TABLE Group
  id              INTEGER PK AUTOINCREMENT
  name            TEXT NOT NULL UNIQUE
  cadenceDays     INTEGER NOT NULL      -- per-group reminder cadence
  streakCount     INTEGER NOT NULL DEFAULT 0     -- per-group streak (§5.4)
  streakLastDay   TEXT                  -- 'YYYY-MM-DD' of last increment; nullable
  ragHealth       TEXT NOT NULL DEFAULT 'grey'   -- 'green'|'amber'|'red'|'grey' (derived, cached)
  sortOrder       INTEGER NOT NULL DEFAULT 0
  createdAt       INTEGER NOT NULL

TABLE GroupMembership            -- many-to-many: a contact can be in multiple groups
  id        INTEGER PK AUTOINCREMENT
  contactId INTEGER NOT NULL REFERENCES Contact(id) ON DELETE CASCADE
  groupId   INTEGER NOT NULL REFERENCES Group(id)   ON DELETE CASCADE
  UNIQUE(contactId, groupId)

TABLE ContactCadenceOverride     -- optional per-contact cadence (overrides group cadence)
  contactId   INTEGER PK REFERENCES Contact(id) ON DELETE CASCADE
  cadenceDays INTEGER NOT NULL

TABLE Quest
  id            INTEGER PK AUTOINCREMENT
  periodStart   INTEGER NOT NULL      -- UTC millis, local-day/period boundary
  periodEnd     INTEGER NOT NULL
  type          TEXT NOT NULL         -- 'daily' | 'weekly'
  poolContactIds TEXT NOT NULL        -- JSON array of contactIds
  kThreshold    INTEGER NOT NULL      -- wins at K reached
  reachedCount  INTEGER NOT NULL DEFAULT 0
  status        TEXT NOT NULL         -- 'active' | 'won' | 'expired'
  createdAt     INTEGER NOT NULL

TABLE NudgeLog                    -- one row per action on a quest pool member
  id         INTEGER PK AUTOINCREMENT
  contactId  INTEGER NOT NULL REFERENCES Contact(id) ON DELETE CASCADE
  questId    INTEGER REFERENCES Quest(id) ON DELETE SET NULL
  dueDate    INTEGER NOT NULL
  action     TEXT NOT NULL         -- 'reached' | 'skipped' | 'rolled_over'
  actionAt   INTEGER NOT NULL

TABLE GlobalStreak               -- single row (id=1)
  id            INTEGER PK         -- always 1
  currentStreak INTEGER NOT NULL DEFAULT 0
  bestStreak    INTEGER NOT NULL DEFAULT 0
  lastWinPeriod INTEGER            -- periodStart of last win; nullable

TABLE MessageTemplate            -- pre-filled WhatsApp starters (§5.8)
  id        INTEGER PK AUTOINCREMENT
  groupId   INTEGER REFERENCES Group(id) ON DELETE CASCADE  -- null = global default
  body      TEXT NOT NULL         -- may contain {name}
  isDefault BOOL NOT NULL DEFAULT 0

TABLE Settings                   -- single row (id=1)
  id              INTEGER PK      -- always 1
  questType       TEXT NOT NULL DEFAULT 'daily'   -- 'daily' | 'weekly'
  questSizeN      INTEGER NOT NULL DEFAULT 5
  kThreshold      INTEGER NOT NULL DEFAULT 2
  notifyHour      INTEGER NOT NULL DEFAULT 9       -- local hour 0–23
  notifyMinute    INTEGER NOT NULL DEFAULT 0
  quietHoursStart INTEGER         -- hour, nullable
  quietHoursEnd   INTEGER         -- hour, nullable
  onboardingDone  BOOL NOT NULL DEFAULT 0
```

Seed on first run: `GlobalStreak(id=1)`, `Settings(id=1)`, and the default global `MessageTemplate` set (§5.8). The `Family` group is created during onboarding (S4), not seeded blind.

---

## 5. Core domain logic

### 5.1 Contact import & E.164 normalization  `contacts_import.dart`
- Read all device contacts once via `flutter_contacts` (with phone + photo, withThumbnail).
- For each contact: take the first phone number, normalize to E.164 with default region `IN`. Store both `phoneE164` (nullable on failure) and `phoneRaw`.
- **Normalization is critical** — Indian numbers are stored as `98765 43210`, `+91 98765 43210`, `098765…`, `+919876543210`. A wrong format silently breaks the `wa.me` link. Strip spaces/dashes/leading zeros; assume `+91` if no country code and the number is 10 digits starting 6–9.
- Mark `isStarredOnImport` from the platform star/favorite flag if available.
- **Smart pre-sort ordering** for any triage list: starred first → has name + photo → has name only → bare number / digits-only name last.
- Importing thousands of contacts must not block the UI thread — do it in an isolate or batched transaction with progress callbacks.

### 5.2 Quest generation  `quest_engine.dart`
Runs once per period (per local timezone). A "due" contact = any contact in ≥1 group where `now - lastReachedAt >= effectiveCadenceDays(contact)`, where `effectiveCadenceDays` = `ContactCadenceOverride` if present else the **minimum** cadence among the contact's groups (the tightest cadence wins). Contacts never reached (`lastReachedAt == null`) are due immediately once grouped.

Algorithm:
1. Compute the due set.
2. Pool = take up to `questSizeN` from the due set, prioritizing: rolled-over contacts first, then most-overdue, then light randomization to vary ordering within ties.
3. `kThreshold = min(settings.kThreshold, pool.length)`.
4. Persist a `Quest` row (`status='active'`).
5. Contacts in the due set but not selected this period are **not** penalized; they remain due and will surface next period (natural rollover via the due computation). Explicit rollover rows are written only when a quest expires with un-acted members (see below).

On period end (next generation run): for the previous active quest, any pool member with no `reached`/`skipped` log gets a `NudgeLog(action='rolled_over')`; mark quest `status='expired'` (unless already `won`).

**Win:** when `reachedCount >= kThreshold`, set quest `status='won'` and trigger global-streak increment (§5.3). Reaching more than K is allowed and encouraged but changes nothing mechanically.

[PLACEHOLDER] `questSizeN=5` daily / larger for weekly, `kThreshold=2`.

### 5.3 Global quest streak  `streak_service.dart`
- On a quest reaching `won`: if `lastWinPeriod` is the immediately-previous period or null, `currentStreak += 1`; else `currentStreak = 1` (a new run). Update `bestStreak = max(...)`. Set `lastWinPeriod`.
- **A non-won / expired period never decrements `currentStreak`.** It simply doesn't increment. (No-penalty rule.)
- [OPEN] Whether a missed period should eventually "soft-reset" the run counter after a long gap. Default: never reset; the number only ever rises. Leave `// OPEN`.

### 5.4 Per-group streak  `streak_service.dart`
- On a contact being marked `reached`: for **every** group that contact belongs to, if `group.streakLastDay != today`, increment `group.streakCount += 1` and set `streakLastDay = today`.
- **Gap behavior (no-penalty):** on a day with no qualifying contact, the streak **holds** (does not reset). [PLACEHOLDER] — a `hardReset` flag in `defaults.dart` can switch this to classic reset-on-gap later.
- [OPEN] Multi-group counting: a contact in Family + Hometown advances **both** group streaks. Default = count toward all groups. Alternative (primary-group-only) is a config switch; leave `// OPEN`.

### 5.5 Relationship health (RAG)  `health_service.dart`
Per group, derived (and cached into `Group.ragHealth`) on relevant events (member reached, member added, cadence changed, daily recompute):
- `ratio = membersWithinCadence / totalMembers`
- `green` if `ratio >= 0.8`, `amber` if `0.4 <= ratio < 0.8`, `red` if `ratio < 0.4`, `grey` if group empty.

[PLACEHOLDER] thresholds 0.8 / 0.4. RAG = the group's *upkeep over time*; the streak = the user's *recent activity*. Keep them distinct.

### 5.6 Notification scheduling  `notification_service.dart` (Android-first)
- **Primary path (must be reliable):** pre-schedule the next quest notification with `flutter_local_notifications.zonedSchedule` at `notifyHour:notifyMinute` local, respecting quiet hours. The OS fires it; do not depend on a background process being alive.
- **Secondary path:** a daily `workmanager` job regenerates the quest (§5.2) and re-schedules the next notification. This is catch-up/resync, not the user-facing fire mechanism.
- Notification copy is **encouraging, never guilt-based**. e.g. title "Today's Douu quest", body "Reach out to any [K] of [N] people →". Tapping opens `/quest`.
- Handle **Android 12+ exact-alarm permission** (`SCHEDULE_EXACT_ALARM` / "Alarms & reminders"); if not granted, fall back to inexact and inform the user timing may drift.
- Handle **OEM battery killers** (MIUI/Vivo/Oppo/Realme) — see S5; reminders silently die without background whitelist. This is the #1 silent-failure risk.

### 5.7 WhatsApp handoff + confirmation  `whatsapp_launcher.dart`
- Build `https://wa.me/<digits>` where `<digits>` = `phoneE164` minus the leading `+`. Optionally append `?text=<urlEncoded(template)>` (§5.8).
- Launch via `url_launcher` (`mode: externalApplication`).
- If `phoneE164` is null/invalid → disable the Message button and show "No valid WhatsApp number" inline. Do not crash.
- On return to the app (lifecycle resume after a launch), present the **reach-out confirmation** (S13). On "Yes": write `NudgeLog(action='reached')`, set `contact.lastReachedAt = now`, run §5.4 and §5.5 updates, bump `quest.reachedCount`, check win (§5.3). On "Not yet": no state change.
- Cannot detect actual send. Confirmation is honor-system; never claim verification.

### 5.8 Message starters  `MessageTemplate`
- Seed global defaults (editable in Settings). Use `{name}` substitution (first name). Keep warm, personal, non-salesy. Defaults [PLACEHOLDER]:
  - "Hey {name}, you crossed my mind today — how have you been?"
  - "Hi {name}! It's been a while. How are things?"
  - "{name}! Long time. Hope you're doing well :)"
- A group may have its own templates (`groupId` set). Resolution order: contact's group-specific template (random pick) → global default. The chosen text is pre-filled into `wa.me?text=`; the user edits/sends in WhatsApp.
- The user can disable pre-fill entirely (Settings) → omit `?text=`.

### 5.9 Backup / export  `backup_service.dart`
- **Export:** serialize all tables (Contact, Group, GroupMembership, ContactCadenceOverride, MessageTemplate, Settings, streaks) to a single JSON document with `{ "douuBackupVersion": 1, "exportedAt": <millis>, "data": {...} }`. Offer **optional passphrase** → AES-GCM encrypt the JSON, wrap as `{ "douuBackupVersion":1, "encrypted":true, "kdf":"pbkdf2", "salt":..., "iv":..., "ciphertext":... }`. Save to a file and present via `share_plus`.
- **Import:** pick a file (`file_picker`), prompt for passphrase if encrypted, validate version, then **replace-or-merge** (v1 = replace, with a clear confirm dialog warning it overwrites current data).
- Backups contain PII (names + numbers). Warn the user; recommend the passphrase. This is the only place data leaves the app as a file, and only by explicit user action.
- Quest/NudgeLog history is optional to include [OPEN]; default = exclude logs, include structure + scores (keeps file small, restores the meaningful state).

---

## 6. Navigation map (`go_router`)

```
/                       Splash/router (S0) → decides onboarding vs hub
/onboarding/welcome     S1
/onboarding/contacts    S2  (permission rationale + request)
/onboarding/importing   S3  (loading)
/onboarding/family      S4  (build Family bulk-add)
/onboarding/reminders   S5  (notif + exact alarm + battery)
/onboarding/done        S6
/hub                    S7  (home; groups + quick-sort)   ← default post-onboarding
/groups/new             S9  (create group sheet)
/groups/:id             S10 (group detail)
/groups/:id/add         S8  (bulk-add scoped to group)
/contacts/:id           S11 (contact detail)
/quest                  S12 (today's quest)
/insights               S14 (scores overview)
/settings               S15
/settings/backup        S16
```

Confirmation (S13) is a modal bottom sheet, not a route.

---

## 7. Screen-by-screen specification

Legend for wireframes: `[ ]` button, `(•)` selected, `____` input, `▸` nav chevron, `●` avatar.

---

### S0 — Splash / Router
**Purpose:** decide where to send the user; initialize DB & timezone.

```
┌─────────────────────────────┐
│                             │
│           Douu              │
│        (loading…)           │
│                             │
└─────────────────────────────┘
```
- **Logic:** init Drift, `tz` init, read `Settings.onboardingDone`. If false → `/onboarding/welcome`. If true → `/hub`.
- **States:** loading only (sub-second). On DB init error → full-screen error with "Retry".
- **Acceptance:** ☐ routes correctly on both first-run and returning user ☐ no flash of wrong screen ☐ DB error handled.

---

### S1 — Welcome
**Purpose:** explain value + privacy promise.

```
┌─────────────────────────────┐
│                             │
│  Stay close to the people   │
│  who matter.                │
│                             │
│  Douu reminds you who to    │
│  reach out to, and opens    │
│  the WhatsApp chat for you. │
│                             │
│  🔒 Everything stays on     │
│     this phone. Always.     │
│                             │
│        [ Get started ]      │
└─────────────────────────────┘
```
- **Interactions:** "Get started" → S2.
- **States:** static.
- **Acceptance:** ☐ privacy promise visible ☐ single CTA ☐ no permission requested yet.

---

### S2 — Contacts permission rationale
**Purpose:** explain *why* before the system dialog (improves grant rate + satisfies store policy).

```
┌─────────────────────────────┐
│  ← │                        │
│                             │
│  Douu needs your contacts   │
│                             │
│  To show your people so you │
│  can sort them into groups  │
│  and get reminders to stay  │
│  in touch.                  │
│                             │
│  Your contacts never leave  │
│  this device.               │
│                             │
│     [ Allow contacts ]      │
│     [ Not now ]             │
└─────────────────────────────┘
```
- **Interactions:** "Allow" → request `READ_CONTACTS` via `permission_handler` → on grant go S3; on deny show denied state. "Not now" → denied state.
- **States:**
  - default (above)
  - **denied:** "Douu can't show contacts without permission. You can still add people manually, or enable it in system settings." → [Open settings] [Continue without] (→ S6 with empty hub).
- **Edge:** permanently-denied → deep-link to app settings.
- **Acceptance:** ☐ rationale precedes system dialog ☐ graceful denied path that still reaches the app ☐ no crash if denied.

---

### S3 — Importing (loading)
**Purpose:** read + normalize contacts with progress.

```
┌─────────────────────────────┐
│                             │
│   Importing your contacts   │
│                             │
│   ▓▓▓▓▓▓▓▓░░░░░░  612 / 1k   │
│                             │
│   Tidying up phone numbers… │
│                             │
└─────────────────────────────┘
```
- **Logic:** §5.1 in isolate/batches; show count progress. On finish → S4.
- **States:** loading; **error** (read failed) → "Couldn't read contacts" + Retry; **empty** (0 contacts) → skip to S6 with manual-add hint.
- **Acceptance:** ☐ 1000+ contacts import without ANR ☐ E.164 normalization applied ☐ progress shown ☐ error & empty handled.

---

### S4 — Build Family (onboarding bulk-add)
**Purpose:** seed the first group + teach the bulk-add gesture. Shown once.

```
┌─────────────────────────────┐
│  Add people to Family       │
│  Tap everyone who belongs,  │
│  then add them all at once. │
│  ___________________  🔍    │
│ ─────────────────────────── │
│ ● Aanya Mehta          (•)  │
│ ● Rahul Verma          ( )  │
│ ● Priya Nair           (•)  │
│ ● Dev Kapoor           ( )  │
│ ● Meera Iyer           (•)  │
│ … (pre-sorted by importance)│
│ ─────────────────────────── │
│     [ Add 3 to Family ]     │
└─────────────────────────────┘
```
- **Logic:** create the `Family` group on entry (cadenceDays = [PLACEHOLDER] 7). List = all contacts, smart-pre-sorted (§5.1), live-filtered by search. Multi-select. CTA label reflects count; disabled at 0.
- **Interactions:** tap row toggles selection; "Add N" writes `GroupMembership` rows, recompute RAG, → S5.
- **States:** populated; **empty search** ("No matches"); **loading** (shouldn't occur post-import).
- **Acceptance:** ☐ search filters live ☐ multi-select works on long lists ☐ Family created with members ☐ proceeds to S5 ☐ this screen never reappears after onboarding.

---

### S5 — Reminders setup
**Purpose:** notification permission + exact-alarm + OEM battery whitelist (reliability-critical).

```
┌─────────────────────────────┐
│  ← │                        │
│  Get your daily nudge       │
│                             │
│  Douu sends one gentle      │
│  reminder. No spam.         │
│                             │
│  [ Allow notifications ]    │
│                             │
│  For on-time reminders:     │
│  • Allow "Alarms & reminders"│
│    [ Set ]                  │
│  • Keep Douu running in     │
│    background (your phone:  │
│    <OEM-specific steps>)    │
│    [ How to ]               │
│                             │
│         [ Continue ]        │
└─────────────────────────────┘
```
- **Logic:** request notification permission (Android 13+). Detect Android 12+ → surface exact-alarm action. Detect OEM (manufacturer string) → show tailored battery-whitelist instructions (MIUI/Vivo/Oppo/Realme/other).
- **States:** default; each sub-item shows granted/needed state; "Continue" always enabled (none are hard-blocking, but warn if notifications denied).
- **Acceptance:** ☐ notif permission requested ☐ exact-alarm path on Android 12+ ☐ OEM-aware battery guidance ☐ user can proceed even if some denied.

---

### S6 — Onboarding complete
**Purpose:** hand off to the hub.

```
┌─────────────────────────────┐
│        You're set 🎉        │
│                             │
│  Family has 3 people.       │
│  Add more groups anytime    │
│  from your hub.             │
│                             │
│      [ Go to my hub ]       │
└─────────────────────────────┘
```
- **Logic:** set `Settings.onboardingDone = true`; schedule first notification (§5.6). → S7.
- **Acceptance:** ☐ onboardingDone persisted ☐ first reminder scheduled ☐ lands on hub.

---

### S7 — Groups hub (HOME)
**Purpose:** the daily home. List groups (with cadence + 2 scores), create groups, optional ambient quick-sort, entry to today's quest.

```
┌─────────────────────────────┐
│  Douu            ⚙   📊      │
│  ── Today ─────────────────  │
│  [ ▶ Today's quest · 2 of 5 ]│   ← entry to S12; hidden if none due
│  ── Your groups ───────────  │
│ ┌─────────────────────────┐ │
│ │ 👥 Family        3 ppl ▸│ │
│ │ 🔔 Weekly · 🔥5d · ●Healthy││
│ └─────────────────────────┘ │
│ ┌─────────────────────────┐ │
│ │ 👥 College      12 ppl ▸│ │
│ │ 🔔 Monthly · 🔥0d · ●New │ │
│ └─────────────────────────┘ │
│  [ + Create new group ]     │
│  ── Quick sort (optional) ─ │
│ ┌─────────────────────────┐ │
│ │ ● Karan Shah            │ │
│ │ Which group is this?    │ │
│ │ [Family][College][Later]│ │
│ └─────────────────────────┘ │
└─────────────────────────────┘
```
- **Logic:**
  - Top "Today's quest" entry appears only if an active quest with due members exists; shows `reachedCount of N`. → S12.
  - Group cards: name, member count, cadence pill, per-group streak (§5.4), RAG dot (§5.5). Tap card → S10. (Long-press or the chevron may also open S10; tapping the card body → S10, not bulk-add, to avoid surprise — bulk-add is reached via S10's "Add people".) [OPEN] tap-target behavior; default: whole card → S10.
  - "Create new group" → S9.
  - Quick-sort widget shows ONE uncategorized contact (smart-pre-sorted order) with a chip per existing group + "Later". Tap group chip → add membership, advance to next. "Later" → advance without assigning. Never required.
  - Top bar: ⚙ → S15, 📊 → S14.
- **States:**
  - **populated** (above)
  - **empty groups** (deleted all): show only Family-less hint "Create your first group".
  - **quick-sort empty** ("Everyone's sorted. Nothing to do here.") — hide the widget body, keep a calm line.
  - **no quest due:** hide the Today entry entirely (don't show "0 of 0").
- **Acceptance:** ☐ cards show cadence + streak + RAG ☐ quick-sort advances and assigns correctly ☐ chips reflect all current groups ☐ Today entry appears/hides correctly ☐ tapping card → S10.

---

### S8 — Bulk-add (reusable, scoped to a group)
**Purpose:** add many contacts to a specific group on demand. Same gesture as S4 but reachable from any group (S10 → "Add people"). Route `/groups/:id/add`.

```
┌─────────────────────────────┐
│  ← │ Add people to College   │
│  ___________________  🔍    │
│ ─────────────────────────── │
│ ● Ishaan Roy           ( )  │
│ ● Neha Gupta           (•)  │
│ ● Arjun Das            ( )  │
│  (members already in group  │
│   are hidden)               │
│ ─────────────────────────── │
│     [ Add 1 to College ]    │
└─────────────────────────────┘
```
- **Logic:** identical to S4 multi-select but target = `:id`; exclude existing members from the list. On add → write memberships, recompute RAG, pop back to S10.
- **States:** populated / empty search / "everyone already added".
- **Acceptance:** ☐ scoped to correct group ☐ existing members excluded ☐ returns to S10 with updated count.

---

### S9 — Create group (bottom sheet)
**Purpose:** make a new empty group with a cadence.

```
┌─────────────────────────────┐
│  New group                  │
│  Name ____________________  │
│  Remind me to reach out:    │
│   ( ) Weekly                │
│   (•) Monthly               │
│   ( ) Quarterly             │
│   ( ) Custom: __ days       │
│       [ Cancel ] [ Create ] │
└─────────────────────────────┘
```
- **Logic:** validate non-empty, unique name. Map cadence choice → `cadenceDays` (7/30/90/custom). Create group (`ragHealth='grey'`, `streakCount=0`). On create → S10 (the new group) or back to hub [OPEN]; default → S10 so the user can immediately add people.
- **States:** default; **error** (duplicate/empty name) inline.
- **Acceptance:** ☐ unique-name enforced ☐ cadence persisted ☐ new group appears in hub.

---

### S10 — Group detail
**Purpose:** manage one group — members, cadence, scores, add/remove, delete.

```
┌─────────────────────────────┐
│  ← │ Family          ⋮      │
│  🔔 Weekly  🔥5d  ●Healthy   │
│  [ + Add people ]           │
│ ─────────────────────────── │
│ ● Aanya Mehta    7d ago   ▸ │
│ ● Meera Iyer     today    ▸ │
│ ● Priya Nair     never    ▸ │
└─────────────────────────────┘
```
- **Logic:** header shows cadence pill (tap → edit cadence sheet), per-group streak, RAG. "Add people" → S8. Member rows show `lastReachedAt` relative ("today/7d ago/never"); tap → S11. Overflow ⋮ → rename, edit cadence, delete group (confirm; deleting removes memberships, not contacts).
- **States:** populated; **empty** ("No one here yet — add people"); delete-confirm dialog.
- **Acceptance:** ☐ cadence editable & persisted ☐ add/remove members works ☐ delete removes group + memberships only ☐ rows show last-reached.

---

### S11 — Contact detail
**Purpose:** per-person view — info, group membership, last contacted, history, notes, per-contact cadence override, message.

```
┌─────────────────────────────┐
│  ← │ ● Aanya Mehta          │
│  +91 98765 43210            │
│  Groups: [Family ✕] [+ add] │
│  Last reached: 7 days ago   │
│  Cadence: Weekly (from group)│
│   [ override for this person]│
│  ── Notes ────────────────  │
│  ____________________________│
│  ── History ──────────────  │
│  • Reached  · 12 Jun        │
│  • Skipped  · 5 Jun         │
│ ─────────────────────────── │
│   [ 💬 Message on WhatsApp ] │
└─────────────────────────────┘
```
- **Logic:** show contact, memberships (add/remove inline), `lastReachedAt`, effective cadence + override entry (writes `ContactCadenceOverride`). Notes = free text (local, autosave). History = `NudgeLog` for this contact, reverse-chron. "Message" → §5.7 handoff → on return S13.
- **States:** populated; **no valid number** → Message disabled + "No valid WhatsApp number"; **empty history/notes** placeholders.
- **Acceptance:** ☐ memberships editable ☐ cadence override works ☐ notes persist ☐ history accurate ☐ message handoff opens correct chat ☐ invalid number handled.

---

### S12 — Today's quest
**Purpose:** the core action surface — who to reach out to now, with one-tap WhatsApp.

```
┌─────────────────────────────┐
│  ← │ Today's quest   🔥 4 wk │
│  Reach out to any 2 of 5 —  │
│  that's a win. No pressure  │
│  on the rest.               │
│ ─────────────────────────── │
│ ● Rahul Verma  Family       │
│   Due to reconnect          │
│              [💬 Message]    │
│ ● Priya Nair   Family       │
│   Reached ✓                 │
│ ● Dev Kapoor   College      │
│              [💬 Message] [⨯]│
│ … (⨯ = skip, no penalty)    │
│ ─────────────────────────── │
│  ✓ Quest complete — streak  │
│    safe. Message more if you│
│    like.                    │
└─────────────────────────────┘
```
- **Logic:** render active quest pool. Each row: name, source group(s), status. "Message" → §5.7. "⨯" skip → `NudgeLog('skipped')`, removes from today's view (no penalty). Header shows global streak. When `reachedCount >= kThreshold`: show success banner (encouraging copy), keep remaining rows actionable.
- **States:**
  - active/populated (above)
  - **complete** (won): success banner; rows still tappable
  - **all acted** (everyone reached/skipped): "Done for today. See you tomorrow." (no guilt)
  - **none due / no active quest:** "Nothing due right now — you're on top of it." → back to hub
  - **invalid number** on a row: Message disabled inline
- **Acceptance:** ☐ pool matches engine output ☐ message handoff + confirm updates state ☐ skip is penalty-free ☐ win banner at K ☐ no negative copy in any state.

---

### S13 — Reach-out confirmation (bottom sheet)
**Purpose:** capture self-reported completion after returning from WhatsApp.

```
┌─────────────────────────────┐
│  Did you reach out to        │
│  Rahul?                      │
│   [ Yes, done ]  [ Not yet ] │
└─────────────────────────────┘
```
- **Logic:** triggered on app-resume after a `wa.me` launch (track pending contactId). "Yes" → §5.7 reached path (log, lastReachedAt, streaks, RAG, quest count, win check). "Not yet" → dismiss, no change.
- **States:** single. Auto-dismiss if app resumes for an unrelated reason after a timeout [OPEN] — default: only show if resume occurs within N minutes of a launch.
- **Acceptance:** ☐ appears after handoff ☐ "Yes" updates all derived state ☐ "Not yet" is a no-op ☐ never claims the message was actually sent.

---

### S14 — Insights / scores
**Purpose:** read-only overview of momentum and group health. Self-reported framing.

```
┌─────────────────────────────┐
│  ← │ Your momentum           │
│  Current streak   Best       │
│       4 wks       9 wks      │
│  This week: won ✓            │
│  ── Group health ─────────── │
│  Family    ●Healthy  🔥5d    │
│  College   ●Slipping 🔥0d    │
│  Work      ●Neglected 🔥0d   │
│  ── Coverage ─────────────── │
│  78% of grouped people       │
│  contacted within cadence    │
│  (last 90 days)              │
│  ⓘ These are based on what   │
│    you mark as reached.      │
└─────────────────────────────┘
```
- **Logic:** read global streak, per-group RAG + streak, computed coverage %. Honest disclaimer footer.
- **States:** populated; **empty** (no groups/history) → "Sort some people and start reaching out to see your momentum."
- **Acceptance:** ☐ numbers match underlying data ☐ self-reported disclaimer present ☐ no negative framing.

---

### S15 — Settings
**Purpose:** quest config, reminders, templates, privacy, backup entry.

```
┌─────────────────────────────┐
│  ← │ Settings                │
│  ── Quests ──────────────── │
│  Quest type    Daily ▸       │
│  People per quest   5 ▸      │
│  Win at (K)         2 ▸      │
│  ── Reminders ────────────── │
│  Time           9:00 AM ▸    │
│  Quiet hours    Off ▸        │
│  ── Messages ─────────────── │
│  Pre-fill starter   On ▸     │
│  Edit starters         ▸     │
│  ── Cadence defaults ─────── │
│  Weekly / Monthly / Quarterly│
│  ── Data ────────────────── │
│  Backup & restore      ▸     │
│  ── About ───────────────── │
│  Privacy: nothing leaves     │
│  this device.                │
└─────────────────────────────┘
```
- **Logic:** each row edits a `Settings` field (rescheduling notifications on time/quiet-hours change). "Edit starters" manages `MessageTemplate`. Cadence defaults adjust the 7/30/90 constants used for new groups.
- **States:** standard; changing notify time re-schedules (§5.6).
- **Acceptance:** ☐ all settings persist ☐ notification reschedules on relevant change ☐ template editor works ☐ privacy statement present.

---

### S16 — Backup & restore
**Purpose:** manual local export/import (§5.9).

```
┌─────────────────────────────┐
│  ← │ Backup & restore        │
│  Export keeps a copy of your │
│  groups, people & scores.    │
│  Contains names & numbers —  │
│  protect it with a passphrase.│
│   Passphrase ______________  │
│   [ Export backup file ]     │
│ ─────────────────────────── │
│   [ Import from file ]       │
│   ⚠ Import replaces current  │
│     data.                    │
└─────────────────────────────┘
```
- **Logic:** export → build JSON (§5.9), optional AES-GCM with passphrase, `share_plus`. Import → `file_picker`, passphrase if encrypted, validate version, confirm-replace, restore, recompute RAG, reschedule notifications.
- **States:** default; export in-progress; import confirm dialog; **error** (bad passphrase / wrong version / corrupt file) with clear message.
- **Acceptance:** ☐ round-trip export→import restores state ☐ encryption works & wrong passphrase fails gracefully ☐ version mismatch rejected ☐ replace is explicit & confirmed.

---

### Cross-cutting: empty / loading / error patterns
- **Loading:** lightweight centered indicator + one-line context ("Tidying up phone numbers…"). Never a blank screen.
- **Empty:** calm, action-oriented, never guilt ("Nothing due right now — you're on top of it.").
- **Error:** plain-language cause + a single recovery action (Retry / Open settings). Never a raw exception. No error ever implies user fault.
- Build these as reusable `shared/widgets` (`DouuLoading`, `DouuEmpty`, `DouuError`).

---

## 8. Permissions & platform behavior

### 8.1 Android manifest
- `READ_CONTACTS`, `POST_NOTIFICATIONS` (Android 13+), `SCHEDULE_EXACT_ALARM` / `USE_EXACT_ALARM` (Android 12+), `RECEIVE_BOOT_COMPLETED` (reschedule after reboot).

### 8.2 Google Play compliance (if published)
- `READ_CONTACTS` is core functionality (sort-everyone + reminders can't run on the one-contact system picker). Under Play's Contacts Permissions policy (announced 15 Apr 2026; enforced **28 Oct 2026** for apps targeting Android 17 / API 37+), file a **Play Console Developer Declaration** justifying full access. Add to launch checklist.
- Data Safety form: "no data collected, no data shared" (truthful — fast review, marketing asset).
- If this stays a personal/sideloaded app, none of the store declarations apply.

### 8.3 Reliability
- Reschedule all notifications on `BOOT_COMPLETED`.
- OEM battery-killer guidance (S5) is mandatory, not optional — it's the main silent-failure mode in the Indian Android market.

### 8.4 iOS (fast-follow, not v1)
- iOS does NOT guarantee background execution. The reminder must be carried entirely by pre-scheduled local notifications. Do not port the WorkManager fire-path. `NSContactsUsageDescription` must be specific. App must work if contacts denied.

---

## 9. Settings reference (defaults)

| Setting | Default | Notes |
|---|---|---|
| questType | daily | [PLACEHOLDER] |
| questSizeN | 5 | [PLACEHOLDER] |
| kThreshold | 2 | [PLACEHOLDER] |
| notifyHour:Minute | 09:00 local | |
| quietHours | off | |
| prefillStarter | on | |
| cadence: Weekly/Monthly/Quarterly | 7 / 30 / 90 days | [PLACEHOLDER] |
| RAG thresholds | 0.8 / 0.4 | [PLACEHOLDER] |
| streak gap behavior | hold (no reset) | [PLACEHOLDER] |

---

## 10. Non-functional requirements
- **Privacy:** zero network. Verify no dependency opens a socket. No PII in logs.
- **Performance:** import 2,000 contacts without ANR; hub scroll 60fps; quest generation < 100ms typical.
- **Reliability:** notifications survive reboot; degrade (not crash) when any permission denied.
- **Accessibility:** min tap target 48dp; semantic labels on icon-only buttons; dynamic text scaling.
- **Data integrity:** all derived values (RAG, streaks) recomputable from base tables; never the sole source of truth.

---

## 11. Build sequence (milestones)

1. **M1 — Foundation:** project scaffold, theme, `go_router` routes (stubs), Drift schema (§4), Settings/GlobalStreak seed. S0 routing.
2. **M2 — Contacts:** permission flow (S2), import + E.164 normalization (§5.1), S3. Verify normalization on messy Indian formats.
3. **M3 — Groups core:** Family onboarding (S4), hub (S7) with cards, create group (S9), group detail (S10), bulk-add (S8), quick-sort. Per-group cadence.
4. **M4 — Scores:** per-group streak (§5.4), RAG health (§5.5), insights (S14). Wire into cards.
5. **M5 — Quest + WhatsApp:** quest engine (§5.2), global streak (§5.3), today's quest (S12), wa.me handoff (§5.7), confirmation (S13), message starters (§5.8).
6. **M6 — Reminders:** notification service (§5.6), S5, exact-alarm + OEM handling, reboot reschedule.
7. **M7 — Contact detail & settings:** S11 (notes/history/override), S15.
8. **M8 — Backup:** export/import (§5.9), S16.
9. **M9 — Polish:** all empty/error/loading states, accessibility, perf pass, store declaration prep.

Each milestone ends with the relevant §7 acceptance checklists passing.

---

## 12. Open / placeholder decisions (track here)
- [OPEN] Multi-group streak counting — default: count toward all groups a contact is in.
- [OPEN] Global streak long-gap soft-reset — default: never reset.
- [OPEN] Hub card tap target (whole card → group detail) vs split.
- [OPEN] Create-group destination (→ group detail vs → hub) — default: group detail.
- [OPEN] Confirmation auto-dismiss window after resume.
- [OPEN] Include NudgeLog history in backup — default: exclude.
- All [PLACEHOLDER] numeric defaults live in `lib/config/defaults.dart`.

---

## 13. Glossary
- **Group:** user-named set of contacts with its own reminder cadence and two scores.
- **Quest:** a period's (daily/weekly) pool of due contacts; won at K reached.
- **Cadence:** how often a group's members should be reached (days).
- **Global streak:** consecutive won quest-periods (never decreases).
- **Per-group streak:** consecutive days a group had ≥1 contact reached (holds on gaps).
- **RAG health:** red/amber/green indicator of how well a group is maintained vs cadence.
- **Reached:** user self-reported they messaged the person via Douu (not verified).
- **wa.me handoff:** opening a specific WhatsApp chat via deep link; sending is manual.
