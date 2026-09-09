import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:douu/data/db/database.dart';
import 'package:douu/data/repositories/douu_repository.dart';
import 'package:douu/domain/services/quest_engine.dart';
import 'package:douu/domain/services/streak_service.dart';

void main() {
  late AppDatabase db;
  late DouuRepository repo;
  late QuestEngine engine;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = DouuRepository(db);
    engine = QuestEngine(db, repo);
    await db.getSettings();
  });

  tearDown(() => db.close());

  Future<int> addDueContact(String name) async {
    final contactId = await db.into(db.contacts).insert(
          ContactsCompanion.insert(
            displayName: name,
            createdAt: 1,
          ),
        );
    final groupId = await repo.createGroup(
      name: 'Group $name',
      frequencyDays: 1,
    );
    await repo.addMembership(contactId, groupId);
    return contactId;
  }

  test('a won quest remains the only quest for its day', () async {
    await addDueContact('Ari');
    await addDueContact('Bo');
    await (db.update(db.settingsTable)..where((t) => t.id.equals(1))).write(
      const SettingsTableCompanion(questSizeN: Value(2), kThreshold: Value(1)),
    );
    final morning = DateTime(2026, 9, 8, 9);

    final first = await engine.generateForCurrentPeriod(now: morning);
    expect(first, isNotNull);
    final item = (await repo.questItemsFor(first!.id)).first;
    await engine.markReached(item.contactId,
        now: morning.add(const Duration(hours: 1)));

    final afterWin = await engine.generateForCurrentPeriod(
      now: morning.add(const Duration(hours: 6)),
    );
    expect(afterWin!.id, first.id);
    expect(afterWin.status, 'won');
    expect(await db.select(db.quests).get(), hasLength(1));
  });

  test('skipping is durable and recently skipped people rotate out', () async {
    await addDueContact('Ari');
    await addDueContact('Bo');
    await addDueContact('Cy');
    await addDueContact('Dee');
    await (db.update(db.settingsTable)..where((t) => t.id.equals(1))).write(
      const SettingsTableCompanion(questSizeN: Value(2), kThreshold: Value(2)),
    );
    final today = DateTime(2026, 9, 8, 9);
    final first = await engine.generateForCurrentPeriod(now: today);
    final skippedId = (await repo.questItemsFor(first!.id)).first.contactId;

    await engine.markSkipped(skippedId,
        now: today.add(const Duration(hours: 1)));
    final skipped = await repo.questItemsFor(first.id);
    expect(skipped.firstWhere((item) => item.contactId == skippedId).state,
        'skipped');

    final tomorrow = await engine.generateForCurrentPeriod(
      now: today.add(const Duration(days: 1)),
    );
    final tomorrowIds = (await repo.questItemsFor(tomorrow!.id))
        .map((item) => item.contactId)
        .toSet();
    expect(tomorrowIds, isNot(contains(skippedId)));
  });

  test('skipping never leaves a quest with an impossible target', () async {
    await addDueContact('Ari');
    await addDueContact('Bo');
    await (db.update(db.settingsTable)..where((t) => t.id.equals(1))).write(
      const SettingsTableCompanion(questSizeN: Value(2), kThreshold: Value(2)),
    );
    final quest = await engine.generateForCurrentPeriod(
      now: DateTime(2026, 9, 8, 9),
    );
    final skippedId = (await repo.questItemsFor(quest!.id)).first.contactId;

    await engine.markSkipped(skippedId, now: DateTime(2026, 9, 8, 10));

    final updated = await repo.questForPeriod(quest.periodStart);
    expect(updated!.kThreshold, 1);
  });

  test('a new day uses unseen due contacts when the pool is large enough',
      () async {
    for (final name in ['Ari', 'Bo', 'Cy', 'Dee', 'Eli', 'Flo']) {
      await addDueContact(name);
    }
    await (db.update(db.settingsTable)..where((t) => t.id.equals(1))).write(
      const SettingsTableCompanion(questSizeN: Value(2), kThreshold: Value(2)),
    );
    final today = DateTime(2026, 9, 8, 9);
    final first = await engine.generateForCurrentPeriod(now: today);
    final firstIds = (await repo.questItemsFor(first!.id))
        .map((item) => item.contactId)
        .toSet();

    final tomorrow = await engine.generateForCurrentPeriod(
      now: today.add(const Duration(days: 1)),
    );
    final tomorrowIds = (await repo.questItemsFor(tomorrow!.id))
        .map((item) => item.contactId)
        .toSet();

    expect(tomorrowIds.intersection(firstIds), isEmpty);
  });

  test('reaching the same quest item twice logs one action', () async {
    await addDueContact('Ari');
    final now = DateTime(2026, 9, 8, 9);
    final quest = await engine.generateForCurrentPeriod(now: now);
    final contactId = (await repo.questItemsFor(quest!.id)).single.contactId;

    await engine.markReached(contactId, now: now);
    await engine.markReached(contactId,
        now: now.add(const Duration(minutes: 1)));

    final logs = await repo.logsForContact(contactId);
    expect(logs.where((log) => log.action == 'reached'), hasLength(1));
  });

  test('a missed day pauses the global streak instead of resetting it',
      () async {
    await (db.update(db.globalStreaks)..where((row) => row.id.equals(1))).write(
      const GlobalStreaksCompanion(
        currentStreak: Value(4),
        bestStreak: Value(4),
        lastWinPeriod: Value(1),
      ),
    );

    await StreakService(db).onQuestWon(
      periodStart: 100,
      previousPeriodStart: 99,
    );

    final streak = await db.getGlobalStreak();
    expect(streak.currentStreak, 5);
    expect(streak.bestStreak, 5);
  });
}
