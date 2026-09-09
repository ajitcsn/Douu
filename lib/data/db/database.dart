import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import '../../config/defaults.dart';
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Contacts,
    Groups,
    GroupMemberships,
    ContactFrequencyOverrides,
    Quests,
    QuestItems,
    NudgeLogs,
    NotificationLedgers,
    SideQuests,
    GlobalStreaks,
    MessageTemplates,
    SettingsTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Test/in-memory constructor.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seed();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // v2: add emoji column to groups table
            await customStatement('ALTER TABLE groups ADD COLUMN emoji TEXT');
          }
          if (from < 3) {
            // v3: rename "cadence" to "frequency" throughout.
            await customStatement(
                'ALTER TABLE groups RENAME COLUMN cadence_days TO frequency_days');
            await customStatement(
                'ALTER TABLE contact_cadence_overrides RENAME TO contact_frequency_overrides');
            await customStatement(
                'ALTER TABLE contact_frequency_overrides RENAME COLUMN cadence_days TO frequency_days');
          }
          if (from < 4) {
            // v4: which app wa.me links launch in — 'auto' | 'whatsapp' | 'business'.
            await customStatement(
                "ALTER TABLE settings ADD COLUMN whatsapp_target TEXT NOT NULL DEFAULT 'auto'");
          }
          if (from < 5) {
            // v5: rotating side quests (separate from the daily Quests table).
            await m.createTable(sideQuests);
          }
          if (from < 6) {
            // v6: persistent quest-item state and notification throttling.
            await m.createTable(questItems);
            await m.createTable(notificationLedgers);
            // Existing databases did not enforce a unique platform contact ID.
            // Preserve the oldest record and repoint memberships/logs before
            // removing later duplicate imports.
            await _deduplicateImportedContacts();
            await customStatement(
              'CREATE UNIQUE INDEX IF NOT EXISTS contacts_system_contact_id_unique '
              'ON contacts(system_contact_id) WHERE system_contact_id IS NOT NULL',
            );
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  /// Seeds the singleton rows + default message templates (§4, §5.8).
  /// Idempotent: uses insertOnConflictUpdate / existence checks.
  Future<void> _seed() async {
    await into(globalStreaks).insertOnConflictUpdate(
      const GlobalStreaksCompanion(id: Value(1)),
    );
    await into(settingsTable).insert(
      const SettingsTableCompanion(
        id: Value(1),
        questType: Value(DouuDefaults.questType),
        questSizeN: Value(DouuDefaults.questSizeN),
        kThreshold: Value(DouuDefaults.kThreshold),
        notifyHour: Value(DouuDefaults.notifyHour),
        notifyMinute: Value(DouuDefaults.notifyMinute),
        prefillStarter: Value(DouuDefaults.prefillStarterEnabled),
      ),
      mode: InsertMode.insertOrIgnore,
    );

    final existingTemplates = await (select(messageTemplates)
          ..where((t) => t.isDefault.equals(true)))
        .get();
    if (existingTemplates.isEmpty) {
      for (final body in DouuDefaults.defaultMessageStarters) {
        await into(messageTemplates).insert(
          MessageTemplatesCompanion.insert(
              body: body, isDefault: const Value(true)),
        );
      }
    }
  }

  Future<void> _deduplicateImportedContacts() async {
    final duplicates = await customSelect(
      'SELECT system_contact_id, MIN(id) AS keep_id FROM contacts '
      'WHERE system_contact_id IS NOT NULL GROUP BY system_contact_id HAVING COUNT(*) > 1',
    ).get();
    for (final duplicate in duplicates) {
      final systemId = duplicate.read<String>('system_contact_id');
      final keepId = duplicate.read<int>('keep_id');
      final rows = await customSelect(
        'SELECT id FROM contacts WHERE system_contact_id = ? AND id != ?',
        variables: [Variable<String>(systemId), Variable<int>(keepId)],
      ).get();
      for (final row in rows) {
        final duplicateId = row.read<int>('id');
        // Keep the useful history from both records before the duplicate is
        // removed. A duplicate was usually created by an old import, so this
        // protects user-written notes, cadence choices, and completed work.
        await customStatement(
          '''UPDATE contacts
             SET last_reached_at = CASE
               WHEN last_reached_at IS NULL THEN (SELECT last_reached_at FROM contacts WHERE id = ?)
               WHEN (SELECT last_reached_at FROM contacts WHERE id = ?) IS NULL THEN last_reached_at
               ELSE MAX(last_reached_at, (SELECT last_reached_at FROM contacts WHERE id = ?))
             END,
             notes = COALESCE(notes, (SELECT notes FROM contacts WHERE id = ?)),
             is_starred_on_import = MAX(is_starred_on_import, (SELECT is_starred_on_import FROM contacts WHERE id = ?))
             WHERE id = ?''',
          [
            duplicateId,
            duplicateId,
            duplicateId,
            duplicateId,
            duplicateId,
            keepId
          ],
        );
        await customStatement(
          'INSERT OR IGNORE INTO group_memberships(contact_id, group_id) '
          'SELECT ?, group_id FROM group_memberships WHERE contact_id = ?',
          [keepId, duplicateId],
        );
        await customStatement(
          'INSERT OR IGNORE INTO contact_frequency_overrides(contact_id, frequency_days) '
          'SELECT ?, frequency_days FROM contact_frequency_overrides WHERE contact_id = ?',
          [keepId, duplicateId],
        );
        await customStatement(
          '''UPDATE contact_frequency_overrides
             SET frequency_days = MIN(frequency_days, (
               SELECT frequency_days FROM contact_frequency_overrides WHERE contact_id = ?
             ))
             WHERE contact_id = ? AND EXISTS (
               SELECT 1 FROM contact_frequency_overrides WHERE contact_id = ?
             )''',
          [duplicateId, keepId, duplicateId],
        );
        await customStatement(
          'INSERT OR IGNORE INTO quest_items(quest_id, contact_id, rank, state, acted_at) '
          'SELECT quest_id, ?, rank, state, acted_at FROM quest_items WHERE contact_id = ?',
          [keepId, duplicateId],
        );
        await customStatement(
          'UPDATE side_quests SET contact_id = ? WHERE contact_id = ?',
          [keepId, duplicateId],
        );
        await customStatement(
          'UPDATE nudge_logs SET contact_id = ? WHERE contact_id = ?',
          [keepId, duplicateId],
        );
        await customStatement(
          'DELETE FROM quest_items WHERE contact_id = ?',
          [duplicateId],
        );
        await customStatement(
          'DELETE FROM contact_frequency_overrides WHERE contact_id = ?',
          [duplicateId],
        );
        await customStatement(
          'DELETE FROM group_memberships WHERE contact_id = ?',
          [duplicateId],
        );
        await customStatement(
            'DELETE FROM contacts WHERE id = ?', [duplicateId]);
      }
    }
  }

  Future<SettingsTableData> getSettings() async {
    return (select(settingsTable)..where((t) => t.id.equals(1))).getSingle();
  }

  Future<GlobalStreak> getGlobalStreak() async {
    return (select(globalStreaks)..where((t) => t.id.equals(1))).getSingle();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'douu.sqlite'));
    // Workaround for old Android sqlite3 / tmpdir issues.
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }
    return NativeDatabase.createInBackground(file);
  });
}
