import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/db/database.dart';
import '../../providers.dart';
import '../../shared/widgets/douu_bits.dart';
import '../../shared/widgets/douu_states.dart';
import '../quest/message_handoff.dart';

/// S11 — Contact detail. Info, memberships, last reached, frequency override,
/// notes, history, message handoff.
class ContactDetailScreen extends ConsumerStatefulWidget {
  const ContactDetailScreen({super.key, required this.contactId});

  final int contactId;

  @override
  ConsumerState<ContactDetailScreen> createState() =>
      _ContactDetailScreenState();
}

class _ContactDetailScreenState extends ConsumerState<ContactDetailScreen>
    with WidgetsBindingObserver, MessageHandoffMixin {
  final _notesController = TextEditingController();
  bool _notesLoaded = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(repositoryProvider);
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<Contact?>(
        future: repo.contactById(widget.contactId),
        builder: (context, snap) {
          final c = snap.data;
          if (c == null) return const DouuLoading();
          if (!_notesLoaded) {
            _notesController.text = c.notes ?? '';
            _notesLoaded = true;
          }
          final canMessage =
              ref.read(whatsappLauncherProvider).canMessage(c.phoneE164);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  DouuAvatar(name: c.displayName, radius: 28),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.displayName,
                            style: Theme.of(context).textTheme.headlineSmall),
                        Text(c.phoneE164 ?? c.phoneRaw ?? 'No number'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _GroupsRow(contactId: c.id),
              const SizedBox(height: 8),
              Text('Last reached: ${relativeLastReached(c.lastReachedAt)}'),
              const SizedBox(height: 8),
              _FrequencyOverride(contactId: c.id),
              const Divider(height: 32),
              Text('Notes', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                    hintText: 'Add a note (saved on this device)'),
                onChanged: (v) => repo.setContactNotes(c.id, v),
              ),
              const Divider(height: 32),
              Text('History', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              _History(contactId: c.id),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: canMessage ? () => startMessage(c) : null,
                icon: const Icon(Icons.chat),
                label: Text(canMessage
                    ? 'Message on WhatsApp'
                    : 'No valid WhatsApp number'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GroupsRow extends ConsumerWidget {
  const _GroupsRow({required this.contactId});
  final int contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the reactive stream — updates instantly when memberships change.
    final groupsAsync = ref.watch(contactGroupsProvider(contactId));
    final groups = groupsAsync.valueOrNull ?? const [];
    final repo = ref.read(repositoryProvider);

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        const Text('Communities: '),
        for (final g in groups)
          InputChip(
            label: Text(g.name),
            onDeleted: () async {
              await repo.removeMembership(contactId, g.id);
              await ref.read(healthServiceProvider).recomputeGroup(g.id);
              // No markNeedsBuild needed — contactGroupsProvider stream
              // emits the updated list automatically.
            },
          ),
        ActionChip(
          avatar: const Icon(Icons.add, size: 16),
          label: const Text('add'),
          onPressed: () => _addToGroup(context, ref),
        ),
      ],
    );
  }

  Future<void> _addToGroup(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(repositoryProvider);
    final groups = await repo.watchGroups().first;
    if (!context.mounted) return;
    final picked = await showModalBottomSheet<int>(
      context: context,
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final g in groups)
              ListTile(
                title: Text(g.name),
                onTap: () => Navigator.pop(context, g.id),
              ),
          ],
        ),
      ),
    );
    if (picked != null) {
      await repo.addMembership(contactId, picked);
      await ref.read(healthServiceProvider).recomputeGroup(picked);
    }
  }
}

class _FrequencyOverride extends ConsumerWidget {
  const _FrequencyOverride({required this.contactId});
  final int contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(repositoryProvider);
    return FutureBuilder<int?>(
      future: repo.frequencyOverrideFor(contactId),
      builder: (context, snap) {
        final override = snap.data;
        return Row(
          children: [
            Text(override == null
                ? 'Frequency: from group'
                : 'Frequency: ${FrequencyPill.labelFor(override)} (override)'),
            const Spacer(),
            TextButton(
              onPressed: () => _pick(context, ref, override),
              child: Text(override == null ? 'Override' : 'Edit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pick(
      BuildContext context, WidgetRef ref, int? current) async {
    final options = {'Use group default': null, 'Daily': 1, 'Weekdays': 5, 'Weekly': 7, 'Biweekly': 14, 'Monthly': 30};
    final picked = await showModalBottomSheet<Object?>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final e in options.entries)
              ListTile(
                title: Text(e.key),
                onTap: () => Navigator.pop(context, e.value ?? 'null'),
              ),
          ],
        ),
      ),
    );
    if (picked == null) return; // dismissed
    final value = picked == 'null' ? null : picked as int;
    await ref.read(repositoryProvider).setFrequencyOverride(contactId, value);
    final groups = await ref.read(repositoryProvider).groupsForContact(contactId);
    for (final g in groups) {
      await ref.read(healthServiceProvider).recomputeGroup(g.id);
    }
    if (context.mounted) (context as Element).markNeedsBuild();
  }
}

class _History extends ConsumerWidget {
  const _History({required this.contactId});
  final int contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(repositoryProvider);
    return FutureBuilder<List<NudgeLog>>(
      future: repo.logsForContact(contactId),
      builder: (context, snap) {
        final logs = snap.data ?? const [];
        if (logs.isEmpty) {
          return const Text('No history yet.');
        }
        final fmt = DateFormat('d MMM');
        return Column(
          children: [
            for (final l in logs)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(_iconFor(l.action), size: 18),
                title: Text(_labelFor(l.action)),
                trailing: Text(fmt.format(
                    DateTime.fromMillisecondsSinceEpoch(l.actionAt,
                            isUtc: true)
                        .toLocal())),
              ),
          ],
        );
      },
    );
  }

  IconData _iconFor(String action) => switch (action) {
        'reached' => Icons.check,
        'skipped' => Icons.close,
        _ => Icons.repeat,
      };

  String _labelFor(String action) => switch (action) {
        'reached' => 'Reached',
        'skipped' => 'Skipped',
        _ => 'Rolled over',
      };
}
