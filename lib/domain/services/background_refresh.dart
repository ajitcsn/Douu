import 'dart:convert';
import 'dart:io';

import 'package:workmanager/workmanager.dart';

import '../../data/db/database.dart';
import '../../data/repositories/douu_repository.dart';
import 'health_service.dart';
import 'notification_service.dart';
import 'quest_engine.dart';

const _refreshWorkName = 'douu-daily-refresh';
const _refreshTaskName = 'refresh-daily-quest';

/// Android catch-up for a new day's quest. Local notification scheduling is
/// still the primary reminder path, because WorkManager is intentionally
/// inexact and may be delayed by the operating system.
class BackgroundRefresh {
  static Future<void> initialize() async {
    if (!Platform.isAndroid) return;
    try {
      await Workmanager().initialize(backgroundRefreshDispatcher);
      await Workmanager().registerPeriodicTask(
        _refreshWorkName,
        _refreshTaskName,
        frequency: const Duration(hours: 24),
        flexInterval: const Duration(hours: 1),
        initialDelay: _untilNextRefresh(),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      );
    } catch (_) {
      // A failed catch-up job must never prevent the foreground app opening.
    }
  }

  static Duration _untilNextRefresh() {
    final now = DateTime.now();
    var next = DateTime(now.year, now.month, now.day, 3);
    if (!next.isAfter(now)) next = next.add(const Duration(days: 1));
    return next.difference(now);
  }
}

/// WorkManager enters through a separate isolate, so this must remain a
/// top-level entry point and build its own database/service instances.
@pragma('vm:entry-point')
void backgroundRefreshDispatcher() {
  Workmanager().executeTask((taskName, _) async {
    if (taskName != _refreshTaskName) return true;

    final db = AppDatabase();
    try {
      final settings = await db.getSettings();
      if (!settings.onboardingDone) return true;

      final repo = DouuRepository(db);
      await HealthService(db).recomputeAll();
      final quest = await QuestEngine(db, repo).generateForCurrentPeriod();
      if (quest?.status == 'active') {
        final ids = (jsonDecode(quest!.poolContactIds) as List).cast<int>();
        final names = <String>[];
        for (final id in ids.take(3)) {
          final contact = await repo.contactById(id);
          if (contact != null) {
            names.add(contact.displayName.trim().split(RegExp(r'\s+')).first);
          }
        }
        await NotificationService().scheduleQuestWithNames(
          firstNames: names,
          hour: settings.notifyHour,
          minute: settings.notifyMinute,
          quietStart: settings.quietHoursStart,
          quietEnd: settings.quietHoursEnd,
        );
      }
      return true;
    } catch (_) {
      return false;
    } finally {
      await db.close();
    }
  });
}
