# Douu — Design System Input

Compiled from a full audit of the codebase as of this branch, for a team about to
redesign colors, screens, and interactions. Douu is a 100% local, no-backend
relationship-maintenance app: import phone contacts, sort them into "communities"
(groups) with a reach-out frequency, get one daily "quest" nudging you to message K of
N overdue contacts, tap through to WhatsApp, self-report completion. Full original spec
lives in `PRDs/v0 PRDs/douu_technical_spec.md` — this document doesn't repeat product
scope, it documents *how the current UI is actually built*, warts and all, so a redesign
knows exactly what it's replacing.

## Non-negotiables (carried over from the original spec — do not redesign away)
- 100% local. No network calls, ever, except the user-initiated `wa.me` WhatsApp
  handoff and explicit backup export/import.
- No message automation — Douu never sends anything; it only opens WhatsApp with
  (optionally) a pre-filled draft the user must send themselves.
- **No penalties, ever.** Streaks never decrease. Skipping is always free. No guilt
  copy anywhere. This is a hard content/tone constraint on top of whatever visual
  language the redesign lands on.
- Completion is self-reported, never verified — copy should never imply otherwise.
- Contacts not sorted into a community generate zero reminders.
- Screen numbering (S0–S16) and the three cross-cutting state-widget names
  (`DouuLoading`/`DouuEmpty`/`DouuError`) are established contracts — keep them stable
  even if their visuals change completely.

---

## 1. Navigation map

| Route | Screen | Notes |
|---|---|---|
| `/` | Splash | Silent router, not a destination |
| `/onboarding/welcome` → `.../contacts` → `.../importing` → `.../family` → `.../reminders` → `.../done` | Onboarding (S1–S6) | Linear, one-way, unreachable again after first run |
| `/hub` | Hub (S7, home) | Momentum stats, today's quest entry, side-quest/sort-contacts shortcuts, community list, inline swipe-sort |
| `/groups/new` | Create community (S9) | Full-screen push despite being called a "sheet" in code |
| `/groups/:id` | Community detail (S10) | Members, frequency, health, templates |
| `/groups/:id/add` | Bulk add (S8) | |
| `/contacts/:id` | Contact detail (S11) | |
| `/quest` | Today's quest (S12) | The core daily loop |
| `/quest/archive` | Quest archive | Read-only history, two tabs (daily / side quests) |
| `/side-quest` | Side quest | A second, human-judgment-driven prompt, separate from the daily quest |
| `/sort-contacts` | Sort contacts | Drag-and-drop alternative to the Hub's swipe-sort |
| `/insights` | Insights (S14) | Read-only momentum + health dashboard |
| `/settings` | Settings (S15) | |
| `/settings/backup` | Backup & restore (S16) | |

**Reachable in one tap from Hub**: quest archive, settings, insights, today's quest,
side quest, sort contacts, any community, create-community, quick-sort (inline).
**Buried 2+ taps deep**: bulk-add, contact detail, message templates, backup, side-quest
contact picker, emoji picker.
**Not routed at all** (bottom sheets/embedded widgets only): `SideQuestContactPicker`,
`ContactPicker`, `MessageTemplatesSheet`/`ContactMessagePicker`, `EmojiPicker`, the S13
reach-out confirmation sheet.

---

## 2. Screen-by-screen summary

*(Full detail — layout structure, every interactive element, quirks — is in the research
transcript this doc was compiled from; this table is the scannable index. Ask if you
want the full per-screen writeups expanded back out into this file.)*

| Screen | Purpose | Current visual treatment |
|---|---|---|
| Splash | Loading router | Wordmark + spinner, zero personality |
| Welcome / Contacts permission / Importing / Family / Reminders / Done (onboarding) | First-run setup | Plain white `Scaffold`s, no AppBar branding, no card style, no dot-texture background — **visually disconnected from the rest of the app** |
| Hub | Home | Dot-texture background, pastel community cards, 4 different tap-scale animated widgets, inline swipe-to-sort card |
| Create community | New group form | Choice chips for frequency, free-text emoji entry (no emoji grid) |
| Community detail | Manage one group | 5 different modal patterns on one screen (popup menu, 2 bottom-sheet pickers, 2 alert dialogs, 1 draggable sheet) |
| Bulk add | Multi-add contacts | Delegates to shared `ContactPicker`; slight title-flicker from nested FutureBuilders |
| Contact detail | Contact profile | **Empty AppBar (no title)**; notes field auto-saves with no debounce; uses a manual `markNeedsBuild()` rebuild hack |
| Today's quest | Core daily loop | Dot-texture background, per-row pastel tint by primary community, animated skip (180° flip), animated win banner; has its own duplicate "first-time setup" checklist UI |
| Quest archive | History | Plain generic-looking list/cards, two tabs, fully read-only (no drill-down) |
| Side quest | Secondary human-judgment prompt | Visually near-identical structure to Today's Quest — no distinct identity despite being conceptually different |
| Sort contacts | Drag-and-drop sort | Same problem as Hub's swipe-sort, solved a completely different way |
| Insights | Momentum dashboard | One `LinearProgressIndicator` is the only "chart" despite the name |
| Settings | Config | Flattest, least-branded screen — plain default `ListTile`s |
| Backup & restore | Export/import | Only other `AlertDialog` usage outside community delete/rename |

---

## 3. Color system — current state

### Central theme (`lib/config/theme.dart`)
Material 3, soft-blue brand: seed `#5BA4CF`, pale card wash `#DCEEF8`/`#BDD9F0` (light),
deep navy `#0D1B2A`/`#1A3250`/`#254A6E` (dark). RAG semantic colors: green `#2F9E44`,
amber `#F59F00`, red `#E03131`, grey `#ADB5BD`, exposed via a clean `DouuTheme.ragColor()`
helper. Cards: 16px radius, 1px border, flat. Buttons: 48px min-height forced on both
`FilledButton` and `OutlinedButton` (`Size.fromHeight(48)` = infinite width) — this is a
real friction point, already required ad hoc per-instance overrides (documented in code
comments) anywhere a compact button is needed inside a `Row`. **A dark theme is fully
defined but never wired up** — `app.dart` hardcodes `ThemeMode.light` with no `darkTheme`
param, and a code comment explicitly says the palette "is designed for a light
background." Three `streak*` gradient color constants are defined and never used anywhere.

### Group/community palette (`douu_bits.dart`)
8 pastel fill+border pairs (rose, mint, lavender, peach, sky, pink, teal, lemon), assigned
by `groupId % 8`, shared correctly across hub cards/quest rows/sort-contacts drop
targets. Lives entirely **outside** the ColorScheme/dark-mode system — untested against
dark mode, no documented contrast/accessibility governance.

### The real problem: hardcoded colors bypassing both systems
- **RAG green `#2F9E44` is re-hardcoded as a raw literal 6+ times across 4 files**
  (`quest_screen.dart`, `quest_archive_screen.dart`, `side_quest_screen.dart`,
  `insights_screen.dart`) instead of calling `DouuTheme.ragGreen`/`ragColor()`. Amber/red
  are similarly re-hardcoded once each in `insights_screen.dart`.
- **A second, unrelated green/red pair** — `Colors.green.shade400/600` and
  `Colors.red.shade300/400` — is used for the Hub's swipe-sort card accept/skip
  backgrounds, meaning the app has at least 4 distinct "greens" and 3 distinct "reds"
  in active use.
- **The Hub's momentum card re-hardcodes the theme's own blue values** (`#DCEEF8`,
  `#BDD9F0`, `#1A3A54`) as local constants instead of reading `colorScheme` — it will
  not adapt if the theme changes or dark mode ships.
- **Settings' privacy disclaimer uses raw `Colors.grey`** instead of
  `colorScheme.onSurfaceVariant`/`outline` — same class of bug, will look muddy in dark
  mode.
- Ad hoc `.withAlpha(n)` values (120/140/160/180/30) are scattered per-screen for
  "muted text" with no shared opacity scale/token.

**Bottom line for the redesign**: the theme file itself is clean and worth keeping as a
base, but at least 5 screens silently bypass it with hardcoded colors — a real color
redesign needs to audit and eliminate every one of these, not just repaint the theme file.

---

## 4. Typography
No custom font — relies entirely on default platform Material type (Roboto/system).
`Theme.textTheme` is used at 34 call sites but only ~10 of the full Material 3 type
scale are ever touched (no `headlineLarge/Medium`, `labelLarge`). Color/weight is very
often layered on top via inline `.copyWith(color: <hardcoded color>)` rather than
themed text styles — meaning even "correct" textTheme usage still reintroduces the
color-inconsistency problem above. A few places (`hub_screen.dart` streak numbers,
`settings_screen.dart` caption, `create_group_sheet.dart` emoji size) use raw
`TextStyle(fontSize: ...)` disconnected from the type scale entirely.

---

## 5. Component library (`lib/shared/widgets/`)

Small and disciplined, but stops at static primitives — **no shared interactive or
animated component exists**; every animated/gestural affordance is hand-rolled per
screen (see §6).

**`douu_bits.dart`**: `DouuAvatar` (initials circle, 9 call sites), `RagDot` (3 sites),
`FrequencyPill` (2 sites — note: code calls it "Frequency", spec/README call the same
concept "Cadence," a naming drift), `StreakChip` (3 sites), `DotBackground` (2 sites,
Hub + Quest only), `groupCardColor`/`groupBorderColor` (3–4 sites each),
`relativeLastReached()` (2 sites).

**`douu_states.dart`** — the three PRD-mandated state widgets, and the most-reused code
in the app: `DouuLoading` (17 call sites), `DouuEmpty` (12 sites), `DouuError` (12
sites). These three are the strongest, most consistent existing pattern — preserve the
concept, redesign the visuals.

---

## 6. Interaction & animation patterns

No shared animated component exists; the following are each hand-rolled, once or
multiple times:

| Pattern | Where | Feedback |
|---|---|---|
| Tap-scale button (4 separate re-implementations) | Hub: `_AnimatedQuestButton`, `_AnimatedOutlineButton`, `_HubIconLink`, `_GroupCard` | `GestureDetector` + `AnimatedScale` to 0.96–0.97, 100–120ms — identical logic copy-pasted 4×, one variant carries a fully vestigial unused `AnimationController` |
| Swipe-to-sort card | Hub `_QuickSort` (`Dismissible`) | Green/red reveal backgrounds, on-card directional hint text, one group asked at a time |
| Drag-and-drop sort | `sort_contacts_screen.dart` (`Draggable`/`DragTarget`) | Ghost-chip feedback at 0.7 opacity, dashed-border-on-hover via a hand-written `CustomPainter`; drag handle deliberately isolated from the row to avoid stealing scrollbar gestures |
| Win banner | Quest `_WinBanner` | Slide-up + fade-in, `easeOutBack`, 500ms, plays once |
| Skip flip | Quest `_AnimatedSkipButton` | 180° `RotationTransition`, 300ms — visual finishes *before* the state actually changes |
| Momentum card entrance | Hub `_MomentumCard` | `elasticOut` bounce scale-in, 600ms, plays once on mount |
| Emoji picker tap target | `create_group_sheet.dart` | **No feedback at all** — the one tappable surface in the app with zero press animation, inconsistent with every other tappable surface |

**Redesign takeaway**: the tap-scale pattern is used often enough and consistently
enough in *intent* that it should become one shared `DouuPressable`/similar component
rather than 4 hand-rolled copies — the single clearest "extract a component" finding
in this whole audit.

---

## 7. Icon usage
~35 distinct icons, inconsistently split between filled and `_outlined` variants with
no governing rule. Direct clashes: `Icons.check_circle` (filled, archive/side-quest) vs
`Icons.check_circle_outline` (quest screen/Hub swipe-sort) for the *same* "done/confirm"
concept; `Icons.send` (quest screen) vs `Icons.send_outlined` (community detail) for the
same "message" action. A redesign should pick one rule (e.g. outlined = default state,
filled = active/selected) and apply it everywhere.

---

## 8. Modal surfaces
Fairly consistent split, worth formalizing rather than discarding: `showDialog`/
`AlertDialog` is reserved for destructive or text-input confirmations only (community
rename, community delete, backup-import overwrite confirm — 3 call sites, 2 files).
`showModalBottomSheet` is used for everything else — pickers, editors, the S13 reach-out
confirmation (11 call sites, 8 files). Two of the bottom sheets
(`MessageTemplatesSheet`/`ContactMessagePicker`) duplicate the same drag-handle/header
boilerplate and could become one shared sheet-scaffold component.

---

## 9. Cross-cutting issues — prioritized for the redesign

1. **Two ways to do the same thing**: Hub's swipe-sort card and the standalone
   Sort Contacts screen both categorize uncategorized contacts, via completely
   different interaction models, reachable from adjacent Hub buttons. Pick one.
2. **Three "pick a contact from a list" patterns** (checkbox multi-select, single-tap
   picker, plain group-membership picker) with no shared visual language.
3. **Hardcoded colors bypass the theme** in at least 2 places (Hub momentum card,
   Settings caption) — will break if/when dark mode ships.
4. **Onboarding looks like a different app** — no dot-texture, no card style, no
   pastel palette, no AppBar branding, next to the Hub/Quest cluster which has all of
   those.
5. **Destructive-action confirmation is inconsistent** — group delete and backup
   import confirm via dialog; removing a group-membership chip or deleting a message
   template does not confirm at all.
6. **Three overlapping "you don't have 2 groups yet" UIs** — the real onboarding flow,
   the Hub's empty state, and Quest screen's own `_FirstDayQuest` checklist all handle
   this differently.
7. **`ContactDetailScreen` has a completely empty AppBar** — no title until you scroll
   into the body.
8. **Settings/Insights/Archive/Backup are visually flat** next to Hub/Quest's
   pastel-and-animation treatment — an unintentional "fun screens vs. utility screens"
   split.
9. **Insights has no real chart** despite being framed as an analytics/momentum
   destination — one progress bar is the only visualization.
10. **The 48px-min-height forced button size** causes ad hoc per-instance overrides
    wherever a compact button is needed — a redesign should define explicit compact vs.
    full-width button variants instead.
11. **Terminology drift**: code says "Frequency"/"Community", spec and some UI copy say
    "Cadence"/"Group" — worth a single naming decision applied everywhere.
12. Two documented open decisions from the original spec (§12) were never explicitly
    revisited — worth checking they still hold before the redesign locks in new ones.

---

## What to keep vs. what's most worth revisiting
**Keep**: the three-state (`Loading`/`Empty`/`Error`) discipline, the dialog-vs-sheet
modal split, the pastel per-community color *concept* (even if the exact 8 colors
change), the no-penalty/no-guilt tone rules, the tap-scale micro-interaction *intent*.

**Most worth revisiting**: the actual color values and their governance (theme vs.
ad hoc hardcoding), onboarding's visual disconnect from the main app, the duplicated
sort-contacts mental model, and consolidating 4 hand-rolled tap-scale widgets into one
component.
