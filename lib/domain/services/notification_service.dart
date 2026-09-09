import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// All notification tiers for Douu (§5.6).
///
/// Tier 1 — Daily nudge:  name-led curiosity copy, rescheduled after quest
///           generates so the name is always fresh.
/// Tier 2 — Streak rescue: fires at 19:00 if quest still incomplete and
///           streak ≥ 3. Cancelled when quest is won.
/// Tier 3 — Group going red: one-shot per group when RAG flips amber→red.
/// Tier 4 — Streak milestone: 7 / 14 / 30 / 60 / 100 days.
/// Tier 5 — Re-engagement: scheduled 4 days out, reset on every hub open.
/// Tier 6 — Unsorted contacts: fires next morning when ≥ 5 unsorted.
class NotificationService {
  NotificationService({this.onRoute});

  /// Route notification taps through the app router, including cold starts.
  final void Function(String route)? onRoute;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // ── IDs ───────────────────────────────────────────────────────────
  static const _idDailyNudge = 1001;
  static const _idStreakRescue = 1002;
  static const _idReengagement = 1003;
  static const _idUnsorted = 1004;
  static const _idMilestone = 1005;
  static const _idSortQuestion = 1006;
  // Group-red IDs: 2000 + groupId (allows up to 999 groups)

  // ── Channels ──────────────────────────────────────────────────────
  static const _chActionId = 'douu_quest';
  static const _chActionName = 'Daily reminders';
  static const _chCelebId = 'douu_celebrate';
  static const _chCelebName = 'Milestones & achievements';

  static const _milestones = {7, 14, 30, 60, 100};

  bool _initialized = false;

  // ── Init ──────────────────────────────────────────────────────────

  Future<void> init() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    try {
      final timezoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneName));
    } catch (_) {}
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        final route = response.payload;
        if (route != null && route.isNotEmpty) onRoute?.call(route);
      },
    );
    _initialized = true;
    final launch = await _plugin.getNotificationAppLaunchDetails();
    final route = launch?.notificationResponse?.payload;
    if (launch?.didNotificationLaunchApp == true && route != null) {
      Future<void>.microtask(() => onRoute?.call(route));
    }
  }

  Future<bool> requestPermission() async {
    await init();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return await android?.requestNotificationsPermission() ?? false;
  }

  Future<bool> canScheduleExactAlarms() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return await android?.canScheduleExactNotifications() ?? true;
  }

  Future<void> requestExactAlarmPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestExactAlarmsPermission();
  }

  // ── Tier 1: Daily nudge ───────────────────────────────────────────

  /// Schedule (or reschedule) the daily nudge with actual first names from the
  /// quest pool. Call this every time a quest is generated so copy stays fresh.
  Future<void> scheduleQuestWithNames({
    required List<String> firstNames,
    required int hour,
    required int minute,
    int? quietStart,
    int? quietEnd,
  }) async {
    await init();
    var effectiveHour = hour;
    if (_inQuietHours(hour, quietStart, quietEnd) && quietEnd != null) {
      effectiveHour = quietEnd;
    }
    final now = tz.TZDateTime.now(tz.local);
    final today = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, effectiveHour, minute);
    // A quest generated after the chosen reminder time must not put today's
    // names into tomorrow's notification. Tomorrow gets a neutral prompt and
    // creates its own fresh quest when opened.
    final scheduled =
        today.isAfter(now) ? today : today.add(const Duration(days: 1));
    final copyNames = today.isAfter(now) ? firstNames : const <String>[];
    final exact = await canScheduleExactAlarms();

    await _plugin.zonedSchedule(
      _idDailyNudge,
      "Douu · your people",
      _nudgeBody(copyNames),
      scheduled,
      _actionDetails(),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: exact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      payload: '/quest',
    );
  }

  String _nudgeBody(List<String> names) {
    if (names.isEmpty) return "A few people would love to hear from you today.";
    if (names.length == 1) {
      return _pick([
        "What's ${names[0]} been up to lately?",
        "Wonder how ${names[0]} is doing.",
        "${names[0]} could use a hello today.",
      ]);
    }
    if (names.length == 2) {
      return "${names[0]} and ${names[1]} are on your list today.";
    }
    return "${names[0]}, ${names[1]} and ${names.length - 2} more to catch up with.";
  }

  // ── Tier 2: Streak rescue ─────────────────────────────────────────

  /// Schedule a same-day rescue notification at 19:00 if currentStreak ≥ 3.
  /// Pass [firstName] for personalised copy. Cancel when quest is won.
  Future<void> scheduleStreakRescue({
    required int currentStreak,
    String? firstName,
    int rescueHour = 19,
  }) async {
    if (currentStreak < 3) return;
    await init();
    final now = tz.TZDateTime.now(tz.local);
    var fire =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, rescueHour, 0);
    if (!fire.isAfter(now)) return; // already past 7pm — skip today

    final body = firstName != null
        ? "If it feels right, $firstName is here for a quick hello."
        : "If it feels right, there is still time for a quick hello.";
    final exact = await canScheduleExactAlarms();

    await _plugin.zonedSchedule(
      _idStreakRescue,
      "A gentle reminder",
      body,
      fire,
      _actionDetails(),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: exact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      payload: '/quest',
    );
  }

  Future<void> cancelStreakRescue() async {
    await init();
    await _plugin.cancel(_idStreakRescue);
  }

  Future<void> cancelQuestNudge() async {
    await init();
    await _plugin.cancel(_idDailyNudge);
  }

  Future<void> cancelSortQuestion() async {
    await init();
    await _plugin.cancel(_idSortQuestion);
  }

  // ── Tier 3: Group going red ───────────────────────────────────────

  Future<void> notifyGroupRed({
    required int groupId,
    required String groupName,
  }) async {
    await init();
    final body = _pick([
      "A small moment to connect with $groupName.",
      "A warm hello can go a long way in $groupName.",
      "If it feels right, say hello to someone in $groupName.",
    ]);
    await _plugin.show(
      2000 + groupId,
      "A community moment",
      body,
      _celebDetails(),
      payload: '/groups/$groupId',
    );
  }

  // ── Tier 4: Streak milestone ──────────────────────────────────────

  Future<void> notifyStreakMilestone(int days) async {
    if (!_milestones.contains(days)) return;
    await init();
    final body = _milestoneBody(days);
    await _plugin.show(
      _idMilestone,
      "🏆 $days-day streak",
      body,
      _celebDetails(),
    );
  }

  String _milestoneBody(int days) {
    return switch (days) {
      7 => "One week in. The habit is starting to stick.",
      14 => "Two weeks. Your people know you care.",
      30 => "A month of showing up. That's real.",
      60 => "Two months of staying in touch. Remarkable.",
      100 => "100 days. You've built something rare here.",
      _ =>
        "$days days of staying connected. That means something.", // unreachable given milestones set
    };
  }

  // ── Tier 5: Re-engagement ─────────────────────────────────────────

  /// Cancel any existing re-engagement notification and reschedule 4 days out.
  /// Call this on every hub open so the countdown always resets.
  Future<void> scheduleReengagement({
    int daysFromNow = 4,
    String? firstName,
  }) async {
    await init();
    await _plugin.cancel(_idReengagement);
    final fire = tz.TZDateTime.now(tz.local).add(Duration(days: daysFromNow));
    final body = firstName != null
        ? "If it feels right, send $firstName a quick hello."
        : "A small hello can be a lovely thing.";

    await _plugin.zonedSchedule(
      _idReengagement,
      "Still thinking of you",
      body,
      fire,
      _celebDetails(),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: '/',
    );
  }

  // ── Tier 6: Unsorted contacts ─────────────────────────────────────

  /// Schedule a next-morning prompt if [count] ≥ 5 unsorted contacts exist.
  Future<void> scheduleUnsortedPrompt({
    required int count,
    required int notifyHour,
    required int notifyMinute,
    String? sampleName,
  }) async {
    await init();
    if (count < 5) {
      await _plugin.cancel(_idUnsorted);
      return;
    }
    // Schedule for tomorrow at the user's notify time
    final now = tz.TZDateTime.now(tz.local);
    final tomorrow = tz.TZDateTime(
        tz.local, now.year, now.month, now.day + 1, notifyHour, notifyMinute);

    final body = sampleName != null
        ? "$sampleName and ${count - 1} others have no group — they won't appear in your quests."
        : "$count people with no group yet. Worth 2 minutes to sort them?";

    await _plugin.zonedSchedule(
      _idUnsorted,
      "Unsorted contacts",
      body,
      tomorrow,
      _actionDetails(),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: '/',
    );
  }

  Future<void> cancelAll() => _plugin.cancelAll();

  /// A low-pressure, local-only classification nudge for a contact who has
  /// not been assigned to a community. It opens a focused sorting screen;
  /// the notification itself never mutates membership data.
  Future<void> scheduleSortQuestion({
    required String contactName,
    required String groupName,
    required int contactId,
    required int groupId,
    required int hour,
    required int minute,
    int? quietStart,
    int? quietEnd,
  }) async {
    await init();
    var effectiveHour = hour;
    if (_inQuietHours(hour, quietStart, quietEnd) && quietEnd != null) {
      effectiveHour = quietEnd;
    }
    await _plugin.zonedSchedule(
      _idSortQuestion,
      'A quick sorting question',
      'Is $contactName part of $groupName?',
      _nextInstanceOf(effectiveHour, minute),
      _actionDetails(),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: '/sort-contacts?contactId=$contactId&groupId=$groupId',
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────

  NotificationDetails _actionDetails() => const NotificationDetails(
        android: AndroidNotificationDetails(
          _chActionId,
          _chActionName,
          channelDescription: 'Gentle daily nudges.',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      );

  NotificationDetails _celebDetails() => const NotificationDetails(
        android: AndroidNotificationDetails(
          _chCelebId,
          _chCelebName,
          channelDescription: 'Milestones and health alerts.',
          importance: Importance.low,
          priority: Priority.low,
        ),
      );

  bool _inQuietHours(int hour, int? start, int? end) {
    if (start == null || end == null) return false;
    if (start <= end) return hour >= start && hour < end;
    return hour >= start || hour < end;
  }

  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  String _pick(List<String> options) =>
      options[Random().nextInt(options.length)];
}
