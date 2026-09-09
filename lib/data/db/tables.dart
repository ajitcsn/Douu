import 'package:drift/drift.dart';

// Data model per spec §4. All timestamps are UTC epoch millis (int).
// Day-keys for streaks are stored as 'YYYY-MM-DD' text.

class Contacts extends Table {
  IntColumn get id => integer().autoIncrement()();
  /// Platform contact IDs make repeated local imports an upsert, not a second
  /// copy of every person. SQLite permits multiple null values here for manual
  /// contacts that have no platform record.
  TextColumn get systemContactId => text().nullable().unique()();
  TextColumn get displayName => text()();
  TextColumn get phoneE164 => text().nullable()();
  TextColumn get phoneRaw => text().nullable()();
  TextColumn get photoUri => text().nullable()();
  BoolColumn get isStarredOnImport =>
      boolean().withDefault(const Constant(false))();
  IntColumn get lastReachedAt => integer().nullable()();
  TextColumn get notes => text().nullable()();
  IntColumn get createdAt => integer()();
}

class Groups extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  TextColumn get emoji => text().nullable()();
  IntColumn get frequencyDays => integer()();
  IntColumn get streakCount => integer().withDefault(const Constant(0))();
  TextColumn get streakLastDay => text().nullable()();
  TextColumn get ragHealth => text().withDefault(const Constant('grey'))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  IntColumn get createdAt => integer()();
}

class GroupMemberships extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get contactId =>
      integer().references(Contacts, #id, onDelete: KeyAction.cascade)();
  IntColumn get groupId =>
      integer().references(Groups, #id, onDelete: KeyAction.cascade)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {contactId, groupId}
      ];
}

class ContactFrequencyOverrides extends Table {
  IntColumn get contactId =>
      integer().references(Contacts, #id, onDelete: KeyAction.cascade)();
  IntColumn get frequencyDays => integer()();

  @override
  Set<Column> get primaryKey => {contactId};
}

class Quests extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get periodStart => integer()();
  IntColumn get periodEnd => integer()();
  TextColumn get type => text()(); // 'daily' | 'weekly'
  TextColumn get poolContactIds => text()(); // JSON array of contactIds
  IntColumn get kThreshold => integer()();
  IntColumn get reachedCount => integer().withDefault(const Constant(0))();
  TextColumn get status => text()(); // 'active' | 'won' | 'expired'
  IntColumn get createdAt => integer()();
}

/// The durable state of one person inside one quest. Keeping this normalized
/// avoids using a contact's lifetime [lastReachedAt] as a proxy for whether
/// they acted in today's quest.
class QuestItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get questId =>
      integer().references(Quests, #id, onDelete: KeyAction.cascade)();
  IntColumn get contactId =>
      integer().references(Contacts, #id, onDelete: KeyAction.cascade)();
  IntColumn get rank => integer()();
  TextColumn get state => text().withDefault(const Constant('pending'))();
  IntColumn get actedAt => integer().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {questId, contactId},
      ];
}

class NudgeLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get contactId =>
      integer().references(Contacts, #id, onDelete: KeyAction.cascade)();
  IntColumn get questId =>
      integer().nullable().references(Quests, #id, onDelete: KeyAction.setNull)();
  IntColumn get dueDate => integer()();
  TextColumn get action => text()(); // 'reached' | 'skipped' | 'rolled_over'
  IntColumn get actionAt => integer()();
}

/// Local-only record used to throttle notification categories and prevent the
/// same contact/community question from appearing over and over.
class NotificationLedgers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get kind => text()();
  TextColumn get subjectKey => text()();
  IntColumn get lastScheduledAt => integer()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {kind, subjectKey},
      ];
}

/// One rotating side quest per calendar day — a human-judgment prompt (see
/// assets/quest_ideas.json) rather than an algorithmically-picked contact.
/// Deliberately separate from Quests: it never touches the daily quest's
/// single-active-row invariant and carries no streak/win semantics.
class SideQuests extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get dayKey => text().unique()(); // 'YYYY-MM-DD', local
  TextColumn get promptId => text()(); // references assets/quest_ideas.json
  IntColumn get contactId =>
      integer().nullable().references(Contacts, #id, onDelete: KeyAction.setNull)();
  IntColumn get completedAt => integer().nullable()();
  IntColumn get createdAt => integer()();
}

class GlobalStreaks extends Table {
  IntColumn get id => integer()(); // always 1
  IntColumn get currentStreak => integer().withDefault(const Constant(0))();
  IntColumn get bestStreak => integer().withDefault(const Constant(0))();
  IntColumn get lastWinPeriod => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class MessageTemplates extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get groupId =>
      integer().nullable().references(Groups, #id, onDelete: KeyAction.cascade)();
  TextColumn get body => text()(); // may contain {name}
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
}

class SettingsTable extends Table {
  @override
  String get tableName => 'settings';

  IntColumn get id => integer()(); // always 1
  TextColumn get questType => text().withDefault(const Constant('daily'))();
  IntColumn get questSizeN => integer().withDefault(const Constant(5))();
  IntColumn get kThreshold => integer().withDefault(const Constant(2))();
  IntColumn get notifyHour => integer().withDefault(const Constant(9))();
  IntColumn get notifyMinute => integer().withDefault(const Constant(0))();
  IntColumn get quietHoursStart => integer().nullable()();
  IntColumn get quietHoursEnd => integer().nullable()();
  BoolColumn get prefillStarter =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get onboardingDone =>
      boolean().withDefault(const Constant(false))();
  // 'auto' | 'whatsapp' | 'business' — which app wa.me links launch in (§5.7).
  TextColumn get whatsappTarget =>
      text().withDefault(const Constant('auto'))();

  @override
  Set<Column> get primaryKey => {id};
}
