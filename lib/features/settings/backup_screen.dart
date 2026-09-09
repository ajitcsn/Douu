import 'dart:io';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/services/backup_service.dart';
import '../../providers.dart';

/// S16 — Backup & restore (§5.9). Manual local export/import only.
class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  final _passphraseController = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _passphraseController.dispose();
    super.dispose();
  }

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      final service = ref.read(backupServiceProvider);
      final pass = _passphraseController.text.trim();
      final json =
          await service.exportJson(passphrase: pass.isEmpty ? null : pass);
      final dir = await getTemporaryDirectory();
      final file = File(
          '${dir.path}/douu-backup-${DateTime.now().millisecondsSinceEpoch}.douubak');
      await file.writeAsString(json);
      await Share.shareXFiles([XFile(file.path)], subject: 'Douu backup');
    } catch (e) {
      _snack('Export failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Import replaces current data'),
        content: const Text(
            'Importing will overwrite your current groups, people and scores. '
            'Continue?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Import')),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _busy = true);
    try {
      final result = await FilePicker.platform.pickFiles(withData: true);
      if (result == null) {
        setState(() => _busy = false);
        return;
      }
      final path = result.files.single.path;
      final raw = path != null
          ? await File(path).readAsString()
          : String.fromCharCodes(result.files.single.bytes!);
      final pass = _passphraseController.text.trim();
      await ref
          .read(backupServiceProvider)
          .importJson(raw, passphrase: pass.isEmpty ? null : pass);
      // Pending Android notifications can point at data that was just
      // replaced. Clear them before generating a fresh, restored quest.
      await ref.read(notificationServiceProvider).cancelAll();
      await ref.read(healthServiceProvider).recomputeAll();
      await _scheduleRestoredQuest();
      _snack('Backup restored.');
    } on BackupException catch (e) {
      _snack(e.message);
    } catch (e) {
      _snack('Import failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _scheduleRestoredQuest() async {
    final quest =
        await ref.read(questEngineProvider).generateForCurrentPeriod();
    if (quest?.status != 'active') return;

    final db = ref.read(databaseProvider);
    final settings = await db.getSettings();
    final ids = (jsonDecode(quest!.poolContactIds) as List).cast<int>();
    final repo = ref.read(repositoryProvider);
    final names = <String>[];
    for (final id in ids.take(3)) {
      final contact = await repo.contactById(id);
      if (contact != null) {
        names.add(contact.displayName.trim().split(RegExp(r'\s+')).first);
      }
    }
    await ref.read(notificationServiceProvider).scheduleQuestWithNames(
          firstNames: names,
          hour: settings.notifyHour,
          minute: settings.notifyMinute,
          quietStart: settings.quietHoursStart,
          quietEnd: settings.quietHoursEnd,
        );
  }

  void _snack(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup & restore')),
      body: AbsorbPointer(
        absorbing: _busy,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Export keeps a copy of your groups, people & scores. '
                'It contains names & numbers — protect it with a passphrase.'),
            const SizedBox(height: 16),
            TextField(
              controller: _passphraseController,
              obscureText: true,
              decoration:
                  const InputDecoration(labelText: 'Passphrase (optional)'),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _busy ? null : _export,
              icon: const Icon(Icons.upload_file),
              label: const Text('Export backup file'),
            ),
            const Divider(height: 32),
            OutlinedButton.icon(
              onPressed: _busy ? null : _import,
              icon: const Icon(Icons.download),
              label: const Text('Import from file'),
            ),
            const SizedBox(height: 8),
            Text('⚠ Import replaces current data.',
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
            if (_busy) ...[
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }
}
