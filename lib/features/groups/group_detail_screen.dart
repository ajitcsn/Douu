import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/db/database.dart';
import '../../providers.dart';
import '../../shared/widgets/douu_bits.dart';
import '../../shared/widgets/douu_states.dart';
import '../groups/create_group_sheet.dart' show EmojiPicker;
import '../quest/message_handoff.dart';
import '../quest/message_templates_sheet.dart';

/// S10 — Group detail. Members, frequency, scores, add/remove, rename, delete.
class GroupDetailScreen extends ConsumerStatefulWidget {
  const GroupDetailScreen({super.key, required this.groupId});

  final int groupId;

  @override
  ConsumerState<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends ConsumerState<GroupDetailScreen>
    with WidgetsBindingObserver, MessageHandoffMixin {
  @override
  Widget build(BuildContext context) {
    final groupsAsync = ref.watch(groupsProvider);
    final membersAsync = ref.watch(groupMembersProvider(widget.groupId));

    final group = groupsAsync.maybeWhen(
      data: (gs) => gs.where((g) => g.id == widget.groupId).firstOrNull,
      orElse: () => null,
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (group?.emoji != null) ...[
              Text(group!.emoji!, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
            ],
            Text(group?.name ?? 'Community'),
          ],
        ),
        actions: [
          if (group != null)
            PopupMenuButton<String>(
              onSelected: (v) => _onMenu(context, ref, group, v),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'rename', child: Text('Rename')),
                PopupMenuItem(value: 'emoji', child: Text('Change icon')),
                PopupMenuItem(
                    value: 'frequency', child: Text('Edit frequency')),
                PopupMenuItem(
                    value: 'messages', child: Text('Message templates')),
                PopupMenuItem(value: 'delete', child: Text('Delete community')),
              ],
            ),
        ],
      ),
      body: group == null
          ? const DouuLoading()
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      FrequencyPill(
                        frequencyDays: group.frequencyDays,
                        onTap: () => _editFrequency(context, ref, group),
                      ),
                      const SizedBox(width: 12),
                      StreakChip(days: group.streakCount),
                      const SizedBox(width: 12),
                      RagDot(rag: group.ragHealth),
                      const SizedBox(width: 4),
                      Text(RagDot.label(group.ragHealth)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FilledButton.tonalIcon(
                    onPressed: () =>
                        context.push('/groups/${widget.groupId}/add'),
                    icon: const Icon(Icons.add),
                    label: const Text('Add members'),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: membersAsync.when(
                    loading: () => const DouuLoading(),
                    error: (e, _) =>
                        const DouuError(message: 'Could not load members.'),
                    data: (members) => members.isEmpty
                        ? const DouuEmpty(
                            message: 'No one here yet — add people.',
                            icon: Icons.person_add_outlined,
                          )
                        : ListView.builder(
                            itemCount: members.length,
                            itemBuilder: (context, i) {
                              final c = members[i];
                              final launcher =
                                  ref.read(whatsappLauncherProvider);
                              final canMessage =
                                  launcher.canMessage(c.phoneE164);
                              return ListTile(
                                leading: DouuAvatar(name: c.displayName),
                                title: Text(c.displayName),
                                subtitle:
                                    Text(relativeLastReached(c.lastReachedAt)),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                          Icons.text_snippet_outlined),
                                      tooltip: 'Send with template',
                                      onPressed: () =>
                                          ContactMessagePicker.show(
                                        context,
                                        contact: c,
                                        groupId: widget.groupId,
                                        onLaunch: (contact, template) =>
                                            startMessage(
                                          contact,
                                          templateOverride: template,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.send_outlined),
                                      tooltip: 'Message directly on WhatsApp',
                                      onPressed: canMessage
                                          ? () => startMessage(c,
                                              prefillTemplate: false)
                                          : null,
                                    ),
                                  ],
                                ),
                                onTap: () => context.push('/contacts/${c.id}'),
                              );
                            },
                          ),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: OutlinedButton.icon(
                      onPressed: () => MessageTemplatesSheet.show(context,
                          groupId: group.id),
                      icon: const Icon(Icons.text_snippet_outlined),
                      label: const Text('Create templates'),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _onMenu(
      BuildContext context, WidgetRef ref, Group group, String action) async {
    switch (action) {
      case 'rename':
        await _rename(context, ref, group);
      case 'emoji':
        await _editEmoji(context, ref, group);
      case 'frequency':
        await _editFrequency(context, ref, group);
      case 'messages':
        await MessageTemplatesSheet.show(context, groupId: group.id);
      case 'delete':
        await _confirmDelete(context, ref, group);
    }
  }

  Future<void> _editEmoji(
      BuildContext context, WidgetRef ref, Group group) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const EmojiPicker(),
    );
    if (picked != null) {
      await ref.read(repositoryProvider).setGroupEmoji(group.id, picked);
    }
  }

  Future<void> _rename(BuildContext context, WidgetRef ref, Group group) async {
    final controller = TextEditingController(text: group.name);
    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rename group'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Save')),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      await ref.read(repositoryProvider).renameGroup(group.id, name);
    }
  }

  Future<void> _editFrequency(
      BuildContext context, WidgetRef ref, Group group) async {
    final options = {
      'Daily': 1,
      'Weekdays': 5,
      'Weekly': 7,
      'Biweekly': 14,
      'Monthly': 30
    };
    final picked = await showModalBottomSheet<int>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final e in options.entries)
              ListTile(
                title: Text(e.key),
                trailing: group.frequencyDays == e.value
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => Navigator.pop(context, e.value),
              ),
          ],
        ),
      ),
    );
    if (picked != null) {
      await ref.read(repositoryProvider).setGroupFrequency(group.id, picked);
      await ref.read(healthServiceProvider).recomputeGroup(group.id);
    }
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, Group group) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete ${group.name}?'),
        content: const Text(
            'This removes the group and its memberships. Your contacts are '
            'not deleted.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(repositoryProvider).deleteGroup(group.id);
      if (context.mounted) context.pop();
    }
  }
}
