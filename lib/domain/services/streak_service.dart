import 'package:drift/drift.dart';

import '../../data/db/database.dart';

/// Global quest streak (§5.3) and per-group streak (§5.4).
/// No-penalty rule: nothing here ever decrements a streak.
class StreakService {
  StreakService(this.db);

  final AppDatabase db;

  static String dayKey(DateTime local) {
    final d = local;
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  /// §5.3 — called when a quest reaches `won`.
  /// A win advances the no-penalty streak. Missed periods pause it rather than
  /// resetting it, so [previousPeriodStart] is retained only as future policy
  /// context.
  Future<void> onQuestWon({
    required int periodStart,
    required int previousPeriodStart,
  }) async {
    final gs = await db.getGlobalStreak();
    // Douu is deliberately no-penalty. A missed period can pause progress but
    // must never lower it when the user comes back.
    final newCurrent = gs.currentStreak + 1;
    final newBest = newCurrent > gs.bestStreak ? newCurrent : gs.bestStreak;

    await (db.update(db.globalStreaks)..where((t) => t.id.equals(1))).write(
      GlobalStreaksCompanion(
        currentStreak: Value(newCurrent),
        bestStreak: Value(newBest),
        lastWinPeriod: Value(periodStart),
      ),
    );
  }

  /// §5.4 — called when a contact is marked `reached`. Advances every group
  /// the contact belongs to (multi-group default = count toward all).
  // OPEN: primary-group-only counting could be a config switch later.
  Future<void> onContactReached(int contactId, {DateTime? now}) async {
    final today = dayKey(now ?? DateTime.now());

    final groups = await (db.select(db.groups).join([
      innerJoin(db.groupMemberships,
          db.groupMemberships.groupId.equalsExp(db.groups.id)),
    ])
          ..where(db.groupMemberships.contactId.equals(contactId)))
        .map((row) => row.readTable(db.groups))
        .get();

    for (final g in groups) {
      if (g.streakLastDay == today) continue; // already counted today
      await (db.update(db.groups)..where((t) => t.id.equals(g.id))).write(
        GroupsCompanion(
          streakCount: Value(g.streakCount + 1),
          streakLastDay: Value(today),
        ),
      );
    }
  }
}
