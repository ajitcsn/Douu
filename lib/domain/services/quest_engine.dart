import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';

import '../../data/db/database.dart';
import '../../data/repositories/douu_repository.dart';
import 'health_service.dart';
import 'streak_service.dart';

/// Quest generation + the reach/skip action path (§5.2, §5.3, §5.4, §5.7).
class QuestEngine {
  QuestEngine(this.db, this.repo);

  final AppDatabase db;
  final DouuRepository repo;

  static const _msPerDay = 24 * 60 * 60 * 1000;

  // ── Period boundaries ──────────────────────────────────────────────
  // Always a single calendar day — one quest per day (§5.2).
  ({int start, int end}) currentPeriod({DateTime? now}) {
    final n = now ?? DateTime.now();
    final start = DateTime(n.year, n.month, n.day);
    final end = start.add(const Duration(days: 1));
    return (
      start: start.toUtc().millisecondsSinceEpoch,
      end: end.toUtc().millisecondsSinceEpoch
    );
  }

  /// Effective frequency for a contact = override, else MIN frequency among groups.
  int _effectiveFrequency(
    int contactId,
    Map<int, List<int>> groupsForContact,
    Map<int, Group> groupsById,
    Map<int, int> overrides,
  ) {
    if (overrides.containsKey(contactId)) return overrides[contactId]!;
    final gids = groupsForContact[contactId] ?? const [];
    final frequencies =
        gids.map((id) => groupsById[id]?.frequencyDays).whereType<int>();
    if (frequencies.isEmpty) {
      return 1 << 30; // not grouped → effectively never due
    }
    return frequencies.reduce((a, b) => a < b ? a : b);
  }

  /// §5.2 — generate (or return existing) active quest for the current period.
  /// Expires the previous quest and writes rollover logs for un-acted members.
  Future<Quest?> generateForCurrentPeriod({DateTime? now}) {
    // The hub and quest screens both call this independently on mount, so
    // without a transaction two concurrent calls can each see "no active
    // quest" and insert their own — leaving two active rows, which breaks
    // watchSingleOrNull() permanently. The transaction serializes them.
    return db.transaction(() => _generateForCurrentPeriod(now: now));
  }

  Future<Quest?> _generateForCurrentPeriod({DateTime? now}) async {
    final n = now ?? DateTime.now();
    final settings = await db.getSettings();
    final period = currentPeriod(now: n);
    final nowMs = n.toUtc().millisecondsSinceEpoch;

    // A completed quest still owns this calendar day. Creating another quest
    // after a win was the source of duplicate same-day quests.
    final current = await repo.questForPeriod(period.start);
    if (current != null) {
      await repo.ensureQuestItems(current);
      return current;
    }

    // Expire a stale active quest + write rollover logs (§5.2).
    final rolledOver = <int>{};
    final existing = await (db.select(db.quests)
          ..where((q) =>
              q.status.equals('active') &
              q.periodStart.isSmallerThanValue(period.start))
          ..orderBy([(q) => OrderingTerm.desc(q.periodStart)])
          ..limit(1))
        .getSingleOrNull();
    if (existing != null) {
      final items = await repo.ensureQuestItems(existing);
      for (final item in items) {
        if (item.state == 'pending') {
          final cid = item.contactId;
          rolledOver.add(cid);
          await db.into(db.nudgeLogs).insert(NudgeLogsCompanion.insert(
                contactId: cid,
                questId: Value(existing.id),
                dueDate: existing.periodStart,
                action: 'rolled_over',
                actionAt: nowMs,
              ));
        }
      }
      await (db.update(db.quests)..where((q) => q.id.equals(existing.id)))
          .write(const QuestsCompanion(status: Value('expired')));
    }

    // Build the due set.
    final groups = await db.select(db.groups).get();
    final groupsById = {for (final g in groups) g.id: g};
    final memberships = await db.select(db.groupMemberships).get();
    final groupsForContact = <int, List<int>>{};
    for (final m in memberships) {
      groupsForContact.putIfAbsent(m.contactId, () => []).add(m.groupId);
    }
    if (groupsForContact.isEmpty) return null;

    final overrides = {
      for (final o in await db.select(db.contactFrequencyOverrides).get())
        o.contactId: o.frequencyDays
    };
    final contacts = await db.select(db.contacts).get();
    final contactsById = {for (final c in contacts) c.id: c};

    final questHistory = {
      for (final q in await db.select(db.quests).get()) q.id: q
    };
    final itemHistory = await db.select(db.questItems).get();
    final lastShownAt = <int, int>{};
    const historyWindowDays = 7;
    for (final item in itemHistory) {
      final prior = questHistory[item.questId];
      if (prior == null || prior.periodStart >= period.start) continue;
      if (period.start - prior.periodStart > historyWindowDays * _msPerDay) {
        continue;
      }
      final previous = lastShownAt[item.contactId];
      if (previous == null || prior.periodStart > previous) {
        lastShownAt[item.contactId] = prior.periodStart;
      }
    }
    final skippedAt = <int, int>{};
    final skippedLogs = await (db.select(db.nudgeLogs)
          ..where((l) => l.action.equals('skipped')))
        .get();
    for (final log in skippedLogs) {
      final previous = skippedAt[log.contactId];
      if (previous == null || log.actionAt > previous) {
        skippedAt[log.contactId] = log.actionAt;
      }
    }

    final due = <_DueCandidate>[];
    for (final cid in groupsForContact.keys) {
      final c = contactsById[cid];
      if (c == null) continue;
      final memberGroupIds = groupsForContact[cid]!;
      final primaryGroupId = memberGroupIds.reduce((a, b) => a < b ? a : b);
      final frequency =
          _effectiveFrequency(cid, groupsForContact, groupsById, overrides);
      if (c.lastReachedAt == null) {
        due.add(_DueCandidate(
          id: cid,
          overdueDays: 61,
          primaryGroupId: primaryGroupId,
          lastShownAt: lastShownAt[cid],
          lastSkippedAt: skippedAt[cid],
          rolledOver: rolledOver.contains(cid),
        ));
      } else {
        final elapsedDays = (nowMs - c.lastReachedAt!) / _msPerDay;
        if (elapsedDays >= frequency) {
          due.add(_DueCandidate(
            id: cid,
            overdueDays: elapsedDays - frequency,
            primaryGroupId: primaryGroupId,
            lastShownAt: lastShownAt[cid],
            lastSkippedAt: skippedAt[cid],
            rolledOver: rolledOver.contains(cid),
          ));
        }
      }
    }
    if (due.isEmpty) return null;

    // Variety first: avoid the last two appearances and a recent explicit
    // skip when enough other people are due. If the pool is genuinely small,
    // relax the cooldown instead of returning an empty quest.
    const suggestionCooldownDays = 2;
    final cooled = due.where((candidate) {
      final recentlyShown = candidate.lastShownAt != null &&
          nowMs - candidate.lastShownAt! < suggestionCooldownDays * _msPerDay;
      final recentlySkipped = candidate.lastSkippedAt != null &&
          nowMs - candidate.lastSkippedAt! < suggestionCooldownDays * _msPerDay;
      return !recentlyShown && !recentlySkipped;
    }).toList();
    final candidates =
        cooled.length >= min(settings.questSizeN, due.length) ? cooled : due;

    // Shuffle once before a stable comparator. Randomness inside a comparator
    // is non-transitive and can keep surfacing the same people unpredictably.
    candidates.shuffle(Random(period.start));
    candidates.sort((a, b) => b.score(nowMs).compareTo(a.score(nowMs)));

    // First pass gives communities representation; second pass fills the
    // remaining slots by relevance. The same person can be in many groups,
    // but their lowest-id group provides a stable diversity bucket.
    final selected = <_DueCandidate>[];
    final representedGroups = <int>{};
    for (final candidate in candidates) {
      if (selected.length >= settings.questSizeN) break;
      if (representedGroups.add(candidate.primaryGroupId)) {
        selected.add(candidate);
      }
    }
    for (final candidate in candidates) {
      if (selected.length >= settings.questSizeN) break;
      if (!selected.contains(candidate)) selected.add(candidate);
    }

    final poolIds = selected.map((e) => e.id).toList();
    final k = min(settings.kThreshold, poolIds.length);

    final id = await db.into(db.quests).insert(QuestsCompanion.insert(
          periodStart: period.start,
          periodEnd: period.end,
          type: 'daily',
          poolContactIds: jsonEncode(poolIds),
          kThreshold: k,
          status: 'active',
          createdAt: nowMs,
        ));

    await db.batch((batch) {
      for (var rank = 0; rank < poolIds.length; rank++) {
        batch.insert(
          db.questItems,
          QuestItemsCompanion.insert(
            questId: id,
            contactId: poolIds[rank],
            rank: rank,
          ),
        );
      }
    });
    return (db.select(db.quests)..where((q) => q.id.equals(id))).getSingle();
  }

  // ── Actions (§5.7) ─────────────────────────────────────────────────

  /// User self-reported reaching [contactId]. Updates lastReachedAt, logs,
  /// per-group streak, RAG, quest count, and checks for a win.
  Future<void> markReached(int contactId, {DateTime? now}) async {
    final n = now ?? DateTime.now();
    final nowMs = n.toUtc().millisecondsSinceEpoch;
    var newlyReached = true;
    await db.transaction(() async {
      final period = currentPeriod(now: n);
      final quest = await repo.questForPeriod(period.start);
      QuestItem? item;
      if (quest != null) {
        await repo.ensureQuestItems(quest);
        item = await (db.select(db.questItems)
              ..where((i) =>
                  i.questId.equals(quest.id) & i.contactId.equals(contactId)))
            .getSingleOrNull();
        newlyReached = item?.state != 'reached';
      }
      if (!newlyReached) return;

      await (db.update(db.contacts)..where((c) => c.id.equals(contactId)))
          .write(ContactsCompanion(lastReachedAt: Value(nowMs)));
      await db.into(db.nudgeLogs).insert(NudgeLogsCompanion.insert(
            contactId: contactId,
            questId: Value(quest?.id),
            dueDate: quest?.periodStart ?? nowMs,
            action: 'reached',
            actionAt: nowMs,
          ));

      if (quest == null || item == null) return;
      await (db.update(db.questItems)..where((i) => i.id.equals(item!.id)))
          .write(QuestItemsCompanion(
        state: const Value('reached'),
        actedAt: Value(nowMs),
      ));
      final reachedCount = db.questItems.id.count();
      final countRow = await (db.selectOnly(db.questItems)
            ..addColumns([reachedCount])
            ..where(db.questItems.questId.equals(quest.id) &
                db.questItems.state.equals('reached')))
          .getSingle();
      final count = countRow.read(reachedCount) ?? 0;
      final won = quest.status == 'active' && count >= quest.kThreshold;
      await (db.update(db.quests)..where((q) => q.id.equals(quest.id))).write(
        QuestsCompanion(
          reachedCount: Value(count),
          status: Value(won ? 'won' : quest.status),
        ),
      );
      if (won) {
        await StreakService(db).onQuestWon(
          periodStart: quest.periodStart,
          previousPeriodStart: _previousPeriodStart(quest),
        );
      }
    });

    if (!newlyReached) return;
    await StreakService(db).onContactReached(contactId, now: n);
    final groups = await repo.groupsForContact(contactId);
    final health = HealthService(db);
    for (final g in groups) {
      await health.recomputeGroup(g.id, now: n);
    }
  }

  /// User skipped [contactId] — penalty-free (§5.7, S12).
  Future<void> markSkipped(int contactId, {DateTime? now}) async {
    final nowMs = (now ?? DateTime.now()).toUtc().millisecondsSinceEpoch;
    await db.transaction(() async {
      final period = currentPeriod(now: now);
      final quest = await repo.questForPeriod(period.start);
      if (quest == null) return;
      await repo.ensureQuestItems(quest);
      final item = await (db.select(db.questItems)
            ..where((i) =>
                i.questId.equals(quest.id) & i.contactId.equals(contactId)))
          .getSingleOrNull();
      if (item == null || item.state != 'pending') return;
      await (db.update(db.questItems)..where((i) => i.id.equals(item.id)))
          .write(
        QuestItemsCompanion(
          state: const Value('skipped'),
          actedAt: Value(nowMs),
        ),
      );
      // A skip should never turn a quest into an impossible obligation. Keep
      // the goal where it is when enough people remain, otherwise lower it to
      // the remaining actionable count. Skipping everyone still does not win.
      final actionableCount = db.questItems.id.count();
      final actionableRow = await (db.selectOnly(db.questItems)
            ..addColumns([actionableCount])
            ..where(db.questItems.questId.equals(quest.id) &
                db.questItems.state.isNotValue('skipped')))
          .getSingle();
      final actionable = actionableRow.read(actionableCount) ?? 0;
      if (actionable > 0 && actionable < quest.kThreshold) {
        await (db.update(db.quests)..where((q) => q.id.equals(quest.id)))
            .write(QuestsCompanion(kThreshold: Value(actionable)));
      }
      await db.into(db.nudgeLogs).insert(NudgeLogsCompanion.insert(
            contactId: contactId,
            questId: Value(quest.id),
            dueDate: quest.periodStart,
            action: 'skipped',
            actionAt: nowMs,
          ));
    });
  }

  int _previousPeriodStart(Quest quest) {
    final span = quest.periodEnd - quest.periodStart;
    return quest.periodStart - span;
  }
}

class _DueCandidate {
  const _DueCandidate({
    required this.id,
    required this.overdueDays,
    required this.primaryGroupId,
    required this.lastShownAt,
    required this.lastSkippedAt,
    required this.rolledOver,
  });

  final int id;
  final double overdueDays;
  final int primaryGroupId;
  final int? lastShownAt;
  final int? lastSkippedAt;
  final bool rolledOver;

  double score(int nowMs) {
    final urgency = overdueDays.clamp(0, 61).toDouble();
    final unseenBonus = lastShownAt == null
        ? 8.0
        : (nowMs - lastShownAt!) / QuestEngine._msPerDay;
    final rolloverBonus = rolledOver ? 2.0 : 0.0;
    return urgency + unseenBonus + rolloverBonus;
  }
}
