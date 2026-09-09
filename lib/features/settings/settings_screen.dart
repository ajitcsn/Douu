import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/db/database.dart';
import '../../domain/services/contacts_import.dart';
import '../../features/quest/message_templates_sheet.dart';
import '../../providers.dart';
import '../../shared/widgets/douu_states.dart';
import 'package:permission_handler/permission_handler.dart';

/// S15 — Settings. Quest config, reminders, messages, data, privacy.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: settingsAsync.when(
        loading: () => const DouuLoading(),
        error: (e, _) => const DouuError(message: 'Could not load settings.'),
        data: (s) => ListView(
          children: [
            _header(context, 'Quests'),
            _intTile(context, ref, 'People per quest', s.questSizeN, (v) async {
              await _update(
                ref,
                SettingsTableCompanion(
                  questSizeN: Value(v),
                  kThreshold: Value(s.kThreshold.clamp(1, v)),
                ),
              );
            }),
            _intTile(context, ref, 'Win at (K)', s.kThreshold, (v) {
              _update(
                  ref,
                  SettingsTableCompanion(
                    kThreshold: Value(v.clamp(1, s.questSizeN)),
                  ));
            }, max: s.questSizeN),
            _header(context, 'Reminders'),
            ListTile(
              title: const Text('Time'),
              trailing: Text(_fmtTime(s.notifyHour, s.notifyMinute)),
              onTap: () => _pickTime(context, ref, s),
            ),
            ListTile(
              title: const Text('Quiet hours'),
              trailing: s.quietHoursStart == null || s.quietHoursEnd == null
                  ? const Text('Off')
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_quietHoursLabel(s)),
                        TextButton(
                          onPressed: () => _update(
                            ref,
                            const SettingsTableCompanion(
                              quietHoursStart: Value(null),
                              quietHoursEnd: Value(null),
                            ),
                          ),
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
              onTap: () => _pickQuietHours(context, ref, s),
            ),
            _header(context, 'Messages'),
            SwitchListTile(
              title: const Text('Pre-fill starter'),
              value: s.prefillStarter,
              onChanged: (v) => _update(
                  ref, SettingsTableCompanion(prefillStarter: Value(v))),
            ),
            ListTile(
              title: const Text('Open links in'),
              trailing: Text(_whatsappTargetLabel(s.whatsappTarget)),
              onTap: () => _pickWhatsappTarget(context, ref, s),
            ),
            ListTile(
              title: const Text('Default message starters'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => MessageTemplatesSheet.show(context),
            ),
            _header(context, 'Data'),
            ListTile(
              title: const Text('Sync contacts'),
              subtitle: const Text('Add new phone contacts and update names'),
              trailing: const Icon(Icons.sync),
              onTap: () => _syncContacts(context, ref),
            ),
            ListTile(
              title: const Text('Backup & restore'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings/backup'),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Text(
                  '🔒 We care about your privacy; nothing leaves this device.',
                  style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context, String label) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Text(label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall),
      );

  Widget _intTile(BuildContext context, WidgetRef ref, String label, int value,
      ValueChanged<int> onChanged,
      {int? max}) {
    return ListTile(
      title: Text(label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: value > 1 ? () => onChanged(value - 1) : null,
          ),
          Text('$value'),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed:
                max == null || value < max ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }

  Future<void> _update(WidgetRef ref, SettingsTableCompanion companion) async {
    final db = ref.read(databaseProvider);
    await (db.update(db.settingsTable)..where((t) => t.id.equals(1)))
        .write(companion);
  }

  Future<void> _pickTime(
      BuildContext context, WidgetRef ref, SettingsTableData s) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: s.notifyHour, minute: s.notifyMinute),
    );
    if (picked == null) return;
    await _update(
        ref,
        SettingsTableCompanion(
            notifyHour: Value(picked.hour),
            notifyMinute: Value(picked.minute)));
    // Reschedule on change (§5.6).
    await ref.read(notificationServiceProvider).scheduleQuestWithNames(
      firstNames: const [],
      hour: picked.hour,
      minute: picked.minute,
      quietStart: s.quietHoursStart,
      quietEnd: s.quietHoursEnd,
    );
  }

  String _fmtTime(int hour, int minute) {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final ampm = hour < 12 ? 'AM' : 'PM';
    return '$h:${minute.toString().padLeft(2, '0')} $ampm';
  }

  String _quietHoursLabel(SettingsTableData s) {
    if (s.quietHoursStart == null || s.quietHoursEnd == null) return 'Off';
    return '${_fmtTime(s.quietHoursStart!, 0)} – ${_fmtTime(s.quietHoursEnd!, 0)}';
  }

  Future<void> _pickQuietHours(
      BuildContext context, WidgetRef ref, SettingsTableData s) async {
    final start = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: s.quietHoursStart ?? 22, minute: 0),
      helpText: 'Quiet hours start',
    );
    if (start == null) return;
    if (!context.mounted) return;
    final end = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: s.quietHoursEnd ?? 8, minute: 0),
      helpText: 'Quiet hours end',
    );
    if (end == null) return;
    await _update(
      ref,
      SettingsTableCompanion(
        quietHoursStart: Value(start.hour),
        quietHoursEnd: Value(end.hour),
      ),
    );
  }

  Future<void> _syncContacts(BuildContext context, WidgetRef ref) async {
    final status = await Permission.contacts.request();
    if (!status.isGranted && !status.isLimited) {
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Contacts are off'),
          content: const Text(
              'Allow contact access in device settings, then sync again.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Not now'),
            ),
            FilledButton(
              onPressed: () async {
                await openAppSettings();
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('Open settings'),
            ),
          ],
        ),
      );
      return;
    }

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Syncing contacts…')),
    );
    try {
      final count =
          await ContactsImporter(ref.read(databaseProvider)).importAll();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Synced $count contacts')),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not sync contacts. Try again.')),
      );
    }
  }

  String _whatsappTargetLabel(String target) {
    switch (target) {
      case 'whatsapp':
        return 'WhatsApp';
      case 'business':
        return 'WhatsApp Business';
      default:
        return 'System default';
    }
  }

  Future<void> _pickWhatsappTarget(
      BuildContext context, WidgetRef ref, SettingsTableData s) async {
    final options = {
      'System default': 'auto',
      'WhatsApp': 'whatsapp',
      'WhatsApp Business': 'business',
    };
    final picked = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final e in options.entries)
              ListTile(
                title: Text(e.key),
                trailing: s.whatsappTarget == e.value
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => Navigator.pop(context, e.value),
              ),
          ],
        ),
      ),
    );
    if (picked != null) {
      await _update(ref, SettingsTableCompanion(whatsappTarget: Value(picked)));
    }
  }
}
