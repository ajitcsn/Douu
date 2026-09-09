import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/db/database.dart';
import 'data/repositories/douu_repository.dart';
import 'domain/services/backup_service.dart';
import 'domain/services/health_service.dart';
import 'domain/services/notification_service.dart';
import 'domain/services/quest_engine.dart';
import 'domain/services/side_quest_engine.dart';
import 'domain/services/streak_service.dart';
import 'domain/services/whatsapp_launcher.dart';

/// Overridden in main() with the concrete instance created at startup.
final databaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('databaseProvider must be overridden'),
);

final repositoryProvider = Provider<DouuRepository>(
  (ref) => DouuRepository(ref.watch(databaseProvider)),
);

final streakServiceProvider = Provider<StreakService>(
  (ref) => StreakService(ref.watch(databaseProvider)),
);

final healthServiceProvider = Provider<HealthService>(
  (ref) => HealthService(ref.watch(databaseProvider)),
);

final questEngineProvider = Provider<QuestEngine>(
  (ref) => QuestEngine(
    ref.watch(databaseProvider),
    ref.watch(repositoryProvider),
  ),
);

final sideQuestEngineProvider = Provider<SideQuestEngine>(
  (ref) => SideQuestEngine(ref.watch(databaseProvider)),
);

final whatsappLauncherProvider = Provider<WhatsappLauncher>(
  (ref) => WhatsappLauncher(ref.watch(databaseProvider)),
);

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(),
);

final backupServiceProvider = Provider<BackupService>(
  (ref) => BackupService(ref.watch(databaseProvider)),
);

// ── Reactive streams for the UI ──────────────────────────────────────
final settingsProvider = StreamProvider<SettingsTableData>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.settingsTable)..where((t) => t.id.equals(1)))
      .watchSingle();
});

final groupsProvider = StreamProvider<List<Group>>((ref) {
  return ref.watch(repositoryProvider).watchGroups();
});

final contactsProvider = StreamProvider<List<Contact>>((ref) {
  return ref.watch(repositoryProvider).watchContacts();
});

final activeQuestProvider = StreamProvider<Quest?>((ref) {
  return ref.watch(repositoryProvider).watchActiveQuest();
});

/// Today's quest stays visible after it is won so the success state and any
/// remaining optional contacts are not replaced by an empty screen.
final todayQuestProvider = StreamProvider<Quest?>((ref) {
  final period = ref.read(questEngineProvider).currentPeriod();
  return ref.watch(repositoryProvider).watchQuestForPeriod(period.start);
});

final questItemsProvider =
    StreamProvider.family<List<QuestItem>, int>((ref, questId) {
  return ref.watch(repositoryProvider).watchQuestItemsFor(questId);
});

final groupMembersProvider =
    StreamProvider.family<List<Contact>, int>((ref, groupId) {
  return ref.watch(repositoryProvider).watchMembersOf(groupId);
});

/// All group memberships — watched so the quick-sort and contact detail
/// screens can react to changes without async FutureBuilders.
final groupMembershipsProvider = StreamProvider<List<GroupMembership>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.groupMemberships).watch();
});

/// Groups a specific contact belongs to — reactive stream.
final contactGroupsProvider =
    StreamProvider.family<List<Group>, int>((ref, contactId) {
  return ref.watch(repositoryProvider).watchGroupsForContact(contactId);
});

final globalStreakProvider = StreamProvider<GlobalStreak>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.globalStreaks)..where((t) => t.id.equals(1)))
      .watchSingle();
});

final totalQuestsWonProvider = StreamProvider<int>((ref) {
  return ref.watch(repositoryProvider).watchTotalQuestsWon();
});

final sideQuestPromptsProvider = FutureProvider<List<SideQuestPrompt>>((ref) {
  return SideQuestEngine.loadPrompts();
});

final sideQuestForTodayProvider = StreamProvider<SideQuest?>((ref) {
  final today = StreakService.dayKey(DateTime.now());
  return ref.watch(repositoryProvider).watchSideQuestFor(today);
});
