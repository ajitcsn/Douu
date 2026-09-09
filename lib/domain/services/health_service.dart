import 'package:drift/drift.dart';

import '../../config/defaults.dart';
import '../../data/db/database.dart';

/// Relationship health RAG (§5.5). Derived from how many members were reached
/// within their effective frequency; cached into Group.ragHealth.
class HealthService {
  HealthService(this.db);

  final AppDatabase db;

  /// Recompute and cache RAG for a single group.
  Future<String> recomputeGroup(int groupId, {DateTime? now}) async {
    final nowMs = (now ?? DateTime.now()).toUtc().millisecondsSinceEpoch;

    final group = await (db.select(db.groups)..where((g) => g.id.equals(groupId)))
        .getSingleOrNull();
    if (group == null) return 'grey';

    final members = await (db.select(db.contacts).join([
      innerJoin(db.groupMemberships,
          db.groupMemberships.contactId.equalsExp(db.contacts.id)),
    ])
          ..where(db.groupMemberships.groupId.equals(groupId)))
        .map((row) => row.readTable(db.contacts))
        .get();

    String rag;
    if (members.isEmpty) {
      rag = 'grey';
    } else {
      final overrides = {
        for (final o in await db.select(db.contactFrequencyOverrides).get())
          o.contactId: o.frequencyDays
      };
      var within = 0;
      for (final m in members) {
        final frequency = overrides[m.id] ?? group.frequencyDays;
        final windowMs = frequency * 24 * 60 * 60 * 1000;
        if (m.lastReachedAt != null && (nowMs - m.lastReachedAt!) <= windowMs) {
          within++;
        }
      }
      final ratio = within / members.length;
      if (ratio >= DouuDefaults.ragGreenAtOrAbove) {
        rag = 'green';
      } else if (ratio >= DouuDefaults.ragAmberAtOrAbove) {
        rag = 'amber';
      } else {
        rag = 'red';
      }
    }

    await (db.update(db.groups)..where((g) => g.id.equals(groupId)))
        .write(GroupsCompanion(ragHealth: Value(rag)));
    return rag;
  }

  /// Recompute every group (daily recompute / after import or restore).
  Future<void> recomputeAll({DateTime? now}) async {
    final groups = await db.select(db.groups).get();
    for (final g in groups) {
      await recomputeGroup(g.id, now: now);
    }
  }

  /// §S14 coverage: % of grouped contacts reached within their frequency.
  Future<double> coverage({DateTime? now}) async {
    final nowMs = (now ?? DateTime.now()).toUtc().millisecondsSinceEpoch;
    final grouped = await (db.select(db.contacts).join([
      innerJoin(db.groupMemberships,
          db.groupMemberships.contactId.equalsExp(db.contacts.id)),
    ]))
        .map((row) => row.readTable(db.contacts))
        .get();
    final unique = {for (final c in grouped) c.id: c}.values.toList();
    if (unique.isEmpty) return 0;

    final groupsById = {for (final g in await db.select(db.groups).get()) g.id: g};
    final memberships = await db.select(db.groupMemberships).get();
    final groupsForContact = <int, List<int>>{};
    for (final m in memberships) {
      groupsForContact.putIfAbsent(m.contactId, () => []).add(m.groupId);
    }
    final overrides = {
      for (final o in await db.select(db.contactFrequencyOverrides).get())
        o.contactId: o.frequencyDays
    };

    var within = 0;
    for (final c in unique) {
      final gids = groupsForContact[c.id] ?? const [];
      final groupFrequencies =
          gids.map((id) => groupsById[id]?.frequencyDays).whereType<int>();
      final frequency = overrides[c.id] ??
          (groupFrequencies.isEmpty
              ? 30
              : groupFrequencies.reduce((a, b) => a < b ? a : b));
      final windowMs = frequency * 24 * 60 * 60 * 1000;
      if (c.lastReachedAt != null && (nowMs - c.lastReachedAt!) <= windowMs) {
        within++;
      }
    }
    return within / unique.length;
  }
}
