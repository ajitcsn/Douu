import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../providers.dart';

/// S5 — Reminders setup: notification permission + exact-alarm + OEM battery.
/// Reliability-critical; nothing here hard-blocks proceeding.
class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen> {
  bool _notifGranted = false;
  bool _exactGranted = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  Future<void> _refresh() async {
    final notif = await Permission.notification.status;
    final exact = await ref.read(notificationServiceProvider).canScheduleExactAlarms();
    if (mounted) {
      setState(() {
        _notifGranted = notif.isGranted;
        _exactGranted = exact;
      });
    }
  }

  Future<void> _requestNotif() async {
    await ref.read(notificationServiceProvider).init();
    await ref.read(notificationServiceProvider).requestPermission();
    await Permission.notification.request();
    await _refresh();
  }

  Future<void> _requestExact() async {
    await ref.read(notificationServiceProvider).requestExactAlarmPermission();
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Get your daily nudge', style: text.headlineSmall),
              const SizedBox(height: 12),
              Text('Douu sends one gentle reminder. No spam.',
                  style: text.bodyLarge),
              const SizedBox(height: 24),
              _Item(
                label: 'Allow notifications',
                granted: _notifGranted,
                onAction: _requestNotif,
              ),
              const SizedBox(height: 8),
              Text('For on-time reminders:', style: text.titleSmall),
              const SizedBox(height: 8),
              _Item(
                label: 'Allow "Alarms & reminders"',
                granted: _exactGranted,
                onAction: _requestExact,
              ),
              const SizedBox(height: 8),
              _Item(
                label: 'Keep Douu running in the background',
                granted: false,
                actionLabel: 'How to',
                onAction: () => _showBatteryGuidance(context),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => context.go('/onboarding/done'),
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBatteryGuidance(BuildContext context) {
    // OEM battery-killers (MIUI/Vivo/Oppo/Realme) silently kill reminders.
    // §8.3 — mandatory guidance for the Indian Android market.
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Keep reminders alive',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text('Some phones aggressively stop background apps, which can '
                'silently cancel your reminders. To prevent this:'),
            SizedBox(height: 12),
            Text('• Xiaomi/MIUI: Settings → Apps → Douu → Autostart (on) + '
                'Battery saver → No restrictions'),
            Text('• Vivo/Oppo/Realme: Battery → High background power / '
                'Allow auto-launch'),
            Text('• Samsung: Battery → Unrestricted'),
            Text('• Others: disable battery optimization for Douu'),
          ],
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.label,
    required this.granted,
    required this.onAction,
    this.actionLabel,
  });

  final String label;
  final bool granted;
  final String? actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(granted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: granted ? Theme.of(context).colorScheme.primary : null),
        const SizedBox(width: 12),
        Expanded(child: Text(label)),
        if (!granted)
          TextButton(onPressed: onAction, child: Text(actionLabel ?? 'Set')),
      ],
    );
  }
}
