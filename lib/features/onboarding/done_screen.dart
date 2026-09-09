import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/db/database.dart';
import '../../providers.dart';

/// S6 — Onboarding complete. Persists onboardingDone, schedules first
/// notification, hands off to the hub.
class DoneScreen extends ConsumerStatefulWidget {
  const DoneScreen({super.key});

  @override
  ConsumerState<DoneScreen> createState() => _DoneScreenState();
}

class _DoneScreenState extends ConsumerState<DoneScreen> {
  String _summary = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _finish());
  }

  Future<void> _finish() async {
    final db = ref.read(databaseProvider);
    await (db.update(db.settingsTable)..where((s) => s.id.equals(1)))
        .write(const SettingsTableCompanion(onboardingDone: Value(true)));

    final settings = await db.getSettings();
    // Schedule the first quest reminder (§5.6). Best-effort; never blocks.
    try {
      await ref.read(notificationServiceProvider).scheduleQuestWithNames(
            firstNames: const [],
            hour: settings.notifyHour,
            minute: settings.notifyMinute,
            quietStart: settings.quietHoursStart,
            quietEnd: settings.quietHoursEnd,
          );
    } catch (_) {}

    final family = await ref.read(repositoryProvider).groupByName('Family');
    final count = family == null
        ? 0
        : (await ref.read(repositoryProvider).membersOf(family.id)).length;
    if (mounted) {
      setState(() => _summary =
          family == null ? '' : 'Family has $count ${count == 1 ? "person" : "people"}.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("You're set 🎉", style: text.headlineMedium),
              const SizedBox(height: 16),
              if (_summary.isNotEmpty) Text(_summary, style: text.bodyLarge),
              const SizedBox(height: 8),
              Text('Add more groups anytime from your hub.',
                  style: text.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () => context.go('/hub'),
                child: const Text('Go to my hub'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
