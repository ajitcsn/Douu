import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/defaults.dart';
import '../../data/db/database.dart';
import '../../providers.dart';
import '../../shared/widgets/douu_bits.dart';

/// Bottom sheet for viewing and editing reach-out message templates.
/// Can be scoped to a [groupId] (group-specific) or null (global defaults).
class MessageTemplatesSheet extends ConsumerStatefulWidget {
  const MessageTemplatesSheet({super.key, this.groupId});

  final int? groupId;

  static Future<void> show(BuildContext context, {int? groupId}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => MessageTemplatesSheet(groupId: groupId),
    );
  }

  @override
  ConsumerState<MessageTemplatesSheet> createState() =>
      _MessageTemplatesSheetState();
}

class _MessageTemplatesSheetState extends ConsumerState<MessageTemplatesSheet> {
  late Future<List<MessageTemplate>> _templatesFuture;
  final _controller = TextEditingController();
  bool _adding = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _templatesFuture =
        ref.read(repositoryProvider).templatesFor(widget.groupId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title =
        widget.groupId == null ? 'Default messages' : 'Group messages';

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.92,
      builder: (context, scrollController) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          children: [
            // Handle
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(title,
                        style: Theme.of(context).textTheme.titleLarge),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: 'Add message',
                    onPressed: () => setState(() => _adding = !_adding),
                  ),
                ],
              ),
            ),
            // Hint
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Use {name} to personalise. One is chosen at random when you message.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 8),
            if (_adding)
              _AddRow(
                controller: _controller,
                onSave: _saveNew,
                onCancel: () => setState(() {
                  _adding = false;
                  _controller.clear();
                }),
              ),
            Expanded(
              child: FutureBuilder<List<MessageTemplate>>(
                future: _templatesFuture,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final templates = snap.data ?? const [];
                  final items = templates.isEmpty
                      ? DouuDefaults.defaultMessageStarters
                          .map((s) => _TemplateItem(body: s, isDefault: true))
                          .toList()
                      : templates
                          .map((t) => _TemplateItem(body: t.body, id: t.id))
                          .toList();

                  return ListView.builder(
                    controller: scrollController,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final item = items[i];
                      return ListTile(
                        title: Text(item.body),
                        subtitle: item.isDefault
                            ? const Text('Built-in default')
                            : null,
                        trailing: item.id != null
                            ? IconButton(
                                icon: const Icon(Icons.delete_outline),
                                tooltip: 'Remove',
                                onPressed: () => _delete(item.id!),
                              )
                            : null,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveNew() async {
    final body = _controller.text.trim();
    if (body.isEmpty) return;
    final db = ref.read(databaseProvider);
    await db.into(db.messageTemplates).insert(
          MessageTemplatesCompanion.insert(
            body: body,
            groupId: Value(widget.groupId),
            isDefault: Value(widget.groupId == null),
          ),
        );
    _controller.clear();
    setState(() {
      _adding = false;
      _load();
    });
  }

  Future<void> _delete(int id) async {
    final db = ref.read(databaseProvider);
    await (db.delete(db.messageTemplates)..where((t) => t.id.equals(id))).go();
    setState(_load);
  }
}

class _TemplateItem {
  const _TemplateItem({required this.body, this.id, this.isDefault = false});
  final String body;
  final int? id;
  final bool isDefault;
}

// ── Contact message picker ────────────────────────────────────────────
// Shows templates for a group and launches WhatsApp for a specific contact.

class ContactMessagePicker extends ConsumerStatefulWidget {
  const ContactMessagePicker({
    super.key,
    required this.contact,
    required this.onLaunch,
    this.groupId,
  });

  final Contact contact;
  final Future<void> Function(Contact contact, String template) onLaunch;
  final int? groupId;

  static Future<void> show(
    BuildContext context, {
    required Contact contact,
    required Future<void> Function(Contact contact, String template) onLaunch,
    int? groupId,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => ContactMessagePicker(
        contact: contact,
        groupId: groupId,
        onLaunch: onLaunch,
      ),
    );
  }

  @override
  ConsumerState<ContactMessagePicker> createState() =>
      _ContactMessagePickerState();
}

class _ContactMessagePickerState extends ConsumerState<ContactMessagePicker> {
  late Future<List<MessageTemplate>> _templatesFuture;

  @override
  void initState() {
    super.initState();
    // Computed once — DraggableScrollableSheet's builder re-invokes on every
    // frame of the opening/drag animation, so calling templatesFor() inline
    // in build() would hand FutureBuilder a new Future each time, resetting
    // it to "waiting" and tearing down the ListTile/InkWell mid-tap.
    _templatesFuture =
        ref.read(repositoryProvider).templatesFor(widget.groupId);
  }

  @override
  Widget build(BuildContext context) {
    final contact = widget.contact;
    final firstName = contact.displayName.trim().split(RegExp(r'\s+')).first;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.5,
      maxChildSize: 0.85,
      builder: (context, scrollController) => Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                DouuAvatar(name: contact.displayName),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Message $firstName',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        'Tap a template to open in WhatsApp',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
          Expanded(
            child: FutureBuilder<List<MessageTemplate>>(
              future: _templatesFuture,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final templates = snap.data ?? const [];
                final bodies = templates.isEmpty
                    ? DouuDefaults.defaultMessageStarters
                    : templates.map((t) => t.body).toList();

                return ListView.separated(
                  controller: scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: bodies.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 4),
                  itemBuilder: (context, i) {
                    final raw = bodies[i];
                    final preview = raw.replaceAll('{name}', firstName);
                    return Card(
                      child: ListTile(
                        title: Text(preview),
                        trailing: const Icon(Icons.open_in_new, size: 18),
                        onTap: () {
                          Navigator.pop(context);
                          widget.onLaunch(contact, raw);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AddRow extends StatelessWidget {
  const _AddRow({
    required this.controller,
    required this.onSave,
    required this.onCancel,
  });

  final TextEditingController controller;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          TextField(
            controller: controller,
            autofocus: true,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Hey {name}, just thinking of you — how are things?',
              labelText: 'New message',
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: onCancel, child: const Text('Cancel')),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: onSave,
                // Row gives non-Expanded children unbounded width; the app
                // theme's default minimumSize is Size.fromHeight(48) (i.e.
                // minWidth: infinity), which crashes here. Keep this one
                // compact instead of stretching to fill the row.
                style: FilledButton.styleFrom(minimumSize: const Size(64, 40)),
                child: const Text('Add'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
