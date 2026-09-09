/// All tunable [PLACEHOLDER] constants live here so they can be changed in one
/// place (per the spec, §0). Nothing in this file is a researched value.
library;

class DouuDefaults {
  DouuDefaults._();

  // ── Quests (§5.2, §9) ──────────────────────────────────────────────
  /// 'daily' | 'weekly'
  static const String questType = 'daily';

  /// How many due people are pooled into one quest.
  static const int questSizeN = 5;

  /// Reaching this many wins the quest.
  static const int kThreshold = 2;

  // ── Reminders (§5.6, §9) ───────────────────────────────────────────
  static const int notifyHour = 9; // local 0–23
  static const int notifyMinute = 0;

  // ── Frequency presets in days (§9) ──────────────────────────────────
  static const int frequencyDaily = 1;
  static const int frequencyWeekdays = 5;
  static const int frequencyWeekly = 7;
  static const int frequencyBiweekly = 14;
  static const int frequencyMonthly = 30;

  /// Frequency assigned to the Family group created during onboarding (S4).
  static const int familyFrequencyDays = frequencyWeekly;

  // ── Relationship health RAG thresholds (§5.5) ──────────────────────
  static const double ragGreenAtOrAbove = 0.8;
  static const double ragAmberAtOrAbove = 0.4;

  // ── Streak behavior (§5.4) ─────────────────────────────────────────
  /// Per the no-penalty rule the default is to HOLD streaks across gap days.
  /// Flip to true to restore classic reset-on-gap behavior later.
  static const bool hardResetGroupStreakOnGap = false;

  // ── Messaging (§5.8) ───────────────────────────────────────────────
  static const bool prefillStarterEnabled = true;

  static const List<String> defaultMessageStarters = [
    'Hey {name}, you crossed my mind today — how have you been?',
    'Hi {name}! It\'s been a while. How are things?',
    '{name}! Long time. Hope you\'re doing well :)',
  ];

  // ── Confirmation (S13) ─────────────────────────────────────────────
  /// Only show the reach-out confirmation if the app resumes within this
  /// window of a wa.me launch. [OPEN] auto-dismiss window.
  static const Duration confirmationResumeWindow = Duration(minutes: 10);

  // ── Contacts / phone normalization (§5.1) ──────────────────────────
  /// Default region for E.164 normalization.
  static const String defaultPhoneRegion = 'IN';

  // ── Backup (§5.9) ──────────────────────────────────────────────────
  // v3 adds side-quest restoration. Imports remain compatible with v2.
  static const int backupVersion = 3;

  /// [OPEN] default = exclude NudgeLog history from backups.
  static const bool includeLogsInBackup = false;
}
