import 'dart:convert';

import 'package:drift/drift.dart';

import '../db/database.dart';

/// Thin repository exposing domain operations over the Drift database.
/// UI talks to this (via providers); no business logic lives in widgets.
class DouuRepository {
  DouuRepository(this.db);

  final AppDatabase db;

  // ── Contacts ───────────────────────────────────────────────────────
  Future<List<Contact>> allContacts() => db.select(db.contacts).get();

  Stream<List<Contact>> watchContacts() => db.select(db.contacts).watch();

  Future<Contact?> contactById(int id) =>
      (db.select(db.contacts)..where((c) => c.id.equals(id))).getSingleOrNull();

  Future<int> upsertContact(ContactsCompanion c) =>
      db.into(db.contacts).insertOnConflictUpdate(c);

  Future<void> setContactNotes(int contactId, String notes) {
    return (db.update(db.contacts)..where((c) => c.id.equals(contactId)))
        .write(ContactsCompanion(notes: Value(notes)));
  }

  // ── Groups ─────────────────────────────────────────────────────────
  Stream<List<Group>> watchGroups() => (db.select(db.groups)
        ..orderBy([(g) => OrderingTerm(expression: g.sortOrder)]))
      .watch();

  Future<Group?> groupById(int id) =>
      (db.select(db.groups)..where((g) => g.id.equals(id))).getSingleOrNull();

  Future<Group?> groupByName(String name) =>
      (db.select(db.groups)..where((g) => g.name.equals(name)))
          .getSingleOrNull();

  Future<int> createGroup({
    required String name,
    required int frequencyDays,
    String? emoji,
  }) {
    return db.into(db.groups).insert(
          GroupsCompanion.insert(
            name: name,
            frequencyDays: frequencyDays,
            emoji: Value(emoji),
            createdAt: DateTime.now().toUtc().millisecondsSinceEpoch,
          ),
        );
  }

  Future<void> renameGroup(int id, String name) {
    return (db.update(db.groups)..where((g) => g.id.equals(id)))
        .write(GroupsCompanion(name: Value(name)));
  }

  Future<void> setGroupEmoji(int id, String? emoji) {
    return (db.update(db.groups)..where((g) => g.id.equals(id)))
        .write(GroupsCompanion(emoji: Value(emoji)));
  }

  Future<void> setGroupFrequency(int id, int frequencyDays) {
    return (db.update(db.groups)..where((g) => g.id.equals(id)))
        .write(GroupsCompanion(frequencyDays: Value(frequencyDays)));
  }

  Future<void> deleteGroup(int id) {
    // Memberships cascade; contacts are untouched (§S10).
    return (db.delete(db.groups)..where((g) => g.id.equals(id))).go();
  }

  // ── Memberships ────────────────────────────────────────────────────
  Future<List<Contact>> membersOf(int groupId) {
    final query = db.select(db.contacts).join([
      innerJoin(
        db.groupMemberships,
        db.groupMemberships.contactId.equalsExp(db.contacts.id),
      ),
    ])
      ..where(db.groupMemberships.groupId.equals(groupId));
    return query.map((row) => row.readTable(db.contacts)).get();
  }

  Stream<List<Contact>> watchMembersOf(int groupId) {
    final query = db.select(db.contacts).join([
      innerJoin(
        db.groupMemberships,
        db.groupMemberships.contactId.equalsExp(db.contacts.id),
      ),
    ])
      ..where(db.groupMemberships.groupId.equals(groupId));
    return query.map((row) => row.readTable(db.contacts)).watch();
  }

  Future<List<Group>> groupsForContact(int contactId) {
    final query = db.select(db.groups).join([
      innerJoin(
        db.groupMemberships,
        db.groupMemberships.groupId.equalsExp(db.groups.id),
      ),
    ])
      ..where(db.groupMemberships.contactId.equals(contactId));
    return query.map((row) => row.readTable(db.groups)).get();
  }

  Stream<List<Group>> watchGroupsForContact(int contactId) {
    final query = db.select(db.groups).join([
      innerJoin(
        db.groupMemberships,
        db.groupMemberships.groupId.equalsExp(db.groups.id),
      ),
    ])
      ..where(db.groupMemberships.contactId.equals(contactId));
    return query.map((row) => row.readTable(db.groups)).watch();
  }

  Future<void> addMembership(int contactId, int groupId) {
    return db.into(db.groupMemberships).insert(
          GroupMembershipsCompanion.insert(
            contactId: contactId,
            groupId: groupId,
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> addMemberships(List<int> contactIds, int groupId) async {
    await db.batch((b) {
      for (final id in contactIds) {
        b.insert(
          db.groupMemberships,
          GroupMembershipsCompanion.insert(contactId: id, groupId: groupId),
          mode: InsertMode.insertOrIgnore,
        );
      }
    });
  }

  Future<void> removeMembership(int contactId, int groupId) {
    return (db.delete(db.groupMemberships)
          ..where(
              (m) => m.contactId.equals(contactId) & m.groupId.equals(groupId)))
        .go();
  }

  /// contactIds already in [groupId] — for excluding from bulk-add (S8).
  Future<Set<int>> memberIdsOf(int groupId) async {
    final rows = await (db.select(db.groupMemberships)
          ..where((m) => m.groupId.equals(groupId)))
        .get();
    return rows.map((r) => r.contactId).toSet();
  }

  /// Contacts that belong to no group — used for quick-sort count + notifs.
  Future<List<Contact>> uncategorizedContacts() async {
    final all = await allContacts();
    final memberships = await db.select(db.groupMemberships).get();
    final categorized = memberships.map((m) => m.contactId).toSet();
    return all.where((c) => !categorized.contains(c.id)).toList();
  }

  // ── Contact frequency override (§5.2) ──────────────────────────────
  Future<int?> frequencyOverrideFor(int contactId) async {
    final row = await (db.select(db.contactFrequencyOverrides)
          ..where((o) => o.contactId.equals(contactId)))
        .getSingleOrNull();
    return row?.frequencyDays;
  }

  Future<void> setFrequencyOverride(int contactId, int? frequencyDays) async {
    if (frequencyDays == null) {
      await (db.delete(db.contactFrequencyOverrides)
            ..where((o) => o.contactId.equals(contactId)))
          .go();
    } else {
      await db.into(db.contactFrequencyOverrides).insertOnConflictUpdate(
            ContactFrequencyOverridesCompanion.insert(
              contactId: Value(contactId),
              frequencyDays: frequencyDays,
            ),
          );
    }
  }

  // ── Quests & logs ──────────────────────────────────────────────────
  Future<Quest?> activeQuest() => (db.select(db.quests)
        ..where((q) => q.status.equals('active'))
        ..orderBy([(q) => OrderingTerm.desc(q.periodStart)])
        ..limit(1))
      .getSingleOrNull();

  Stream<Quest?> watchActiveQuest() => (db.select(db.quests)
        ..where((q) => q.status.equals('active'))
        ..orderBy([(q) => OrderingTerm.desc(q.periodStart)])
        ..limit(1))
      .watchSingleOrNull();

  /// The one quest for a calendar period, including a completed quest. The UI
  /// must continue to show a won quest instead of treating it as no quest.
  Future<Quest?> questForPeriod(int periodStart) {
    return (db.select(db.quests)
          ..where((q) => q.periodStart.equals(periodStart))
          ..orderBy([(q) => OrderingTerm.desc(q.id)])
          ..limit(1))
        .getSingleOrNull();
  }

  Stream<Quest?> watchQuestForPeriod(int periodStart) {
    return (db.select(db.quests)
          ..where((q) => q.periodStart.equals(periodStart))
          ..orderBy([(q) => OrderingTerm.desc(q.id)])
          ..limit(1))
        .watchSingleOrNull();
  }

  Future<List<QuestItem>> questItemsFor(int questId) {
    return (db.select(db.questItems)
          ..where((i) => i.questId.equals(questId))
          ..orderBy([(i) => OrderingTerm.asc(i.rank)]))
        .get();
  }

  Stream<List<QuestItem>> watchQuestItemsFor(int questId) {
    return (db.select(db.questItems)
          ..where((i) => i.questId.equals(questId))
          ..orderBy([(i) => OrderingTerm.asc(i.rank)]))
        .watch();
  }

  /// Backfills item rows for a quest created by a pre-v6 database. This keeps
  /// an installed user's current quest usable immediately after migration.
  Future<List<QuestItem>> ensureQuestItems(Quest quest) async {
    final existing = await questItemsFor(quest.id);
    if (existing.isNotEmpty) return existing;
    final ids = (jsonDecode(quest.poolContactIds) as List).cast<int>();
    await db.batch((batch) {
      for (var index = 0; index < ids.length; index++) {
        batch.insert(
          db.questItems,
          QuestItemsCompanion.insert(
            questId: quest.id,
            contactId: ids[index],
            rank: index,
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
    });
    return questItemsFor(quest.id);
  }

  /// Lifetime count of won quests — for the momentum card (§S7).
  Stream<int> watchTotalQuestsWon() {
    final count = db.quests.id.count();
    final query = db.selectOnly(db.quests)
      ..addColumns([count])
      ..where(db.quests.status.equals('won'));
    return query.watchSingle().map((row) => row.read(count) ?? 0);
  }

  /// Past completed/expired quests, most recent first — for the archive screen.
  Future<List<Quest>> questHistory() {
    return (db.select(db.quests)
          ..where((q) => q.status.isIn(['won', 'expired']))
          ..orderBy([(q) => OrderingTerm.desc(q.periodStart)]))
        .get();
  }

  Future<List<NudgeLog>> logsForContact(int contactId) {
    return (db.select(db.nudgeLogs)
          ..where((l) => l.contactId.equals(contactId))
          ..orderBy([(l) => OrderingTerm.desc(l.actionAt)]))
        .get();
  }

  /// Reached contact ids grouped by quest — for bolding "reached" names in
  /// the archive.
  Future<Map<int, Set<int>>> reachedContactIdsByQuest() async {
    final rows = await (db.select(db.nudgeLogs)
          ..where((l) => l.action.equals('reached')))
        .get();
    final map = <int, Set<int>>{};
    for (final r in rows) {
      final questId = r.questId;
      if (questId == null) continue;
      map.putIfAbsent(questId, () => {}).add(r.contactId);
    }
    return map;
  }

  // ── Side quests ────────────────────────────────────────────────────
  Stream<SideQuest?> watchSideQuestFor(String dayKey) {
    return (db.select(db.sideQuests)..where((s) => s.dayKey.equals(dayKey)))
        .watchSingleOrNull();
  }

  Future<void> chooseContactForSideQuest(int id, int contactId) {
    return (db.update(db.sideQuests)..where((s) => s.id.equals(id)))
        .write(SideQuestsCompanion(contactId: Value(contactId)));
  }

  Future<void> completeSideQuest(int id, {DateTime? now}) {
    final nowMs = (now ?? DateTime.now()).toUtc().millisecondsSinceEpoch;
    return (db.update(db.sideQuests)..where((s) => s.id.equals(id)))
        .write(SideQuestsCompanion(completedAt: Value(nowMs)));
  }

  /// Past side quests, most recent first — for the archive screen.
  Future<List<SideQuest>> sideQuestHistory() {
    return (db.select(db.sideQuests)
          ..orderBy([(s) => OrderingTerm.desc(s.dayKey)]))
        .get();
  }

  // ── Notification throttling ───────────────────────────────────────
  Future<int?> notificationLastScheduled(String kind, String subjectKey) async {
    final row = await (db.select(db.notificationLedgers)
          ..where((l) => l.kind.equals(kind) & l.subjectKey.equals(subjectKey)))
        .getSingleOrNull();
    return row?.lastScheduledAt;
  }

  Future<void> recordNotificationScheduled(
      String kind, String subjectKey, int atMs) {
    return db.into(db.notificationLedgers).insertOnConflictUpdate(
          NotificationLedgersCompanion.insert(
            kind: kind,
            subjectKey: subjectKey,
            lastScheduledAt: atMs,
          ),
        );
  }

  // ── Message templates (§5.8) ───────────────────────────────────────
  Future<List<MessageTemplate>> templatesFor(int? groupId) {
    if (groupId == null) {
      return (db.select(db.messageTemplates)
            ..where((t) => t.isDefault.equals(true)))
          .get();
    }
    return (db.select(db.messageTemplates)
          ..where((t) => t.groupId.equals(groupId)))
        .get();
  }
}
