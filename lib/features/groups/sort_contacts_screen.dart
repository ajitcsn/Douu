import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart';
import '../../domain/services/contacts_import.dart';
import '../../providers.dart';
import '../../shared/widgets/douu_bits.dart';
import '../../shared/widgets/douu_states.dart';

/// A fast way to clear the uncategorized-contacts backlog: multi-select as
/// many people as belong to the same community, then tap that community once
/// to bulk-assign them all — sorting is a batch operation, not a
/// one-at-a-time drag.
class SortContactsScreen extends ConsumerStatefulWidget {
  const SortContactsScreen({
    super.key,
    this.initialContactId,
    this.initialGroupId,
  });

  final int? initialContactId;
  final int? initialGroupId;

  @override
  ConsumerState<SortContactsScreen> createState() => _SortContactsScreenState();
}

class _SortContactsScreenState extends ConsumerState<SortContactsScreen> {
  final _selected = <int>{};
  final _selectedGroups = <int>{};
  String _query = '';
  bool _classificationAnswered = false;
  // Off by default so the backlog-clearing flow stays focused on brand-new
  // contacts; flip on to also assign already-sorted contacts to another
  // community (a contact can belong to more than one).
  bool _showAlreadySorted = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialContactId != null) {
      _selected.add(widget.initialContactId!);
    }
    if (widget.initialGroupId != null) {
      _selectedGroups.add(widget.initialGroupId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(contactsProvider);
    final membershipsAsync = ref.watch(groupMembershipsProvider);
    final groupsAsync = ref.watch(groupsProvider);

    final canConfirm = _selected.isNotEmpty && _selectedGroups.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sort contacts'),
        actions: [
          IconButton(
            tooltip: 'Done',
            icon: const Icon(Icons.check),
            onPressed: canConfirm
                ? () => _confirmAssignment(groupsAsync.valueOrNull ?? const [])
                : null,
          ),
        ],
      ),
      body: SafeArea(
        child:
            _buildBody(context, contactsAsync, membershipsAsync, groupsAsync),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AsyncValue<List<Contact>> contactsAsync,
    AsyncValue<List<GroupMembership>> membershipsAsync,
    AsyncValue<List<Group>> groupsAsync,
  ) {
    final contacts = contactsAsync.valueOrNull;
    final memberships = membershipsAsync.valueOrNull;
    final groups = groupsAsync.valueOrNull;
    if (contacts == null || memberships == null || groups == null) {
      return const DouuLoading();
    }
    if (groups.isEmpty) {
      return const DouuEmpty(
        message: 'Create your first community to start sorting contacts.',
        icon: Icons.group_add_outlined,
      );
    }

    final categorisedIds = memberships.map((m) => m.contactId).toSet();
    final unsorted = ContactsImporter.smartSort(
      contacts
          .where((c) => _showAlreadySorted || !categorisedIds.contains(c.id))
          .toList(),
    );
    final filtered = _query.isEmpty
        ? unsorted
        : unsorted
            .where((c) =>
                c.displayName.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!_classificationAnswered &&
            widget.initialContactId != null &&
            widget.initialGroupId != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _classificationPrompt(contacts, groups),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: () => _answerClassification(true),
                            child: const Text('Yes, add'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _answerClassification(false),
                            child: const Text('Not this group'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Select contacts and one or more communities, then tap Done.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: const Text('Show already-sorted contacts'),
            subtitle: const Text('Lets you add someone to another community'),
            value: _showAlreadySorted,
            onChanged: (v) => setState(() => _showAlreadySorted = v),
          ),
        ),
        SizedBox(
          height: 96,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: groups.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) => _CommunityAssignButton(
              group: groups[i],
              selected: _selectedGroups.contains(groups[i].id),
              onTap: () => setState(() {
                _selectedGroups.contains(groups[i].id)
                    ? _selectedGroups.remove(groups[i].id)
                    : _selectedGroups.add(groups[i].id);
              }),
            ),
          ),
        ),
        const Divider(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search',
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: filtered.isEmpty
                    ? null
                    : () => setState(
                        () => _selected.addAll(filtered.map((c) => c.id))),
                child: const Text('Select all'),
              ),
            ],
          ),
        ),
        Expanded(
          child: unsorted.isEmpty
              ? const DouuEmpty(message: "Everyone's sorted.")
              : filtered.isEmpty
                  ? const DouuEmpty(message: 'No matches')
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, i) {
                        final c = filtered[i];
                        final selected = _selected.contains(c.id);
                        return CheckboxListTile(
                          value: selected,
                          onChanged: (_) => setState(() {
                            selected
                                ? _selected.remove(c.id)
                                : _selected.add(c.id);
                          }),
                          secondary: DouuAvatar(name: c.displayName),
                          title: Text(c.displayName),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  String _classificationPrompt(List<Contact> contacts, List<Group> groups) {
    final contact = contacts.where((c) => c.id == widget.initialContactId);
    final group = groups.where((g) => g.id == widget.initialGroupId);
    if (contact.isEmpty || group.isEmpty) {
      return 'A quick question from your reminder is ready below.';
    }
    return 'Is ${contact.first.displayName} part of ${group.first.name}? '
        'Choose an answer below.';
  }

  Future<void> _confirmAssignment(List<Group> groups) async {
    final ids = _selected.toList();
    final groupIds = _selectedGroups.toList();
    if (ids.isEmpty || groupIds.isEmpty) return;
    final repo = ref.read(repositoryProvider);
    final health = ref.read(healthServiceProvider);
    final groupsById = {for (final g in groups) g.id: g};

    setState(() {
      _selected.clear();
      _selectedGroups.clear();
    });

    for (final groupId in groupIds) {
      await repo.addMemberships(ids, groupId);
      await health.recomputeGroup(groupId);
    }
    if (widget.initialContactId != null &&
        ids.contains(widget.initialContactId)) {
      await ref.read(notificationServiceProvider).cancelSortQuestion();
    }

    if (!mounted) return;
    final names = groupIds.map((id) => groupsById[id]?.name ?? '?').join(', ');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${ids.length} to $names'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            for (final groupId in groupIds) {
              for (final id in ids) {
                await repo.removeMembership(id, groupId);
              }
              await health.recomputeGroup(groupId);
            }
          },
        ),
      ),
    );
  }

  Future<void> _answerClassification(bool isMember) async {
    final contactId = widget.initialContactId;
    final groupId = widget.initialGroupId;
    if (contactId == null || groupId == null) return;

    if (isMember) {
      final repo = ref.read(repositoryProvider);
      await repo.addMembership(contactId, groupId);
      await ref.read(healthServiceProvider).recomputeGroup(groupId);
    }
    await ref.read(notificationServiceProvider).cancelSortQuestion();
    if (!mounted) return;
    setState(() {
      _selected.remove(contactId);
      _selectedGroups.remove(groupId);
      _classificationAnswered = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              isMember ? 'Added to the community' : 'Okay, not adding them')),
    );
  }
}

class _CommunityAssignButton extends ConsumerWidget {
  const _CommunityAssignButton({
    required this.group,
    required this.selected,
    required this.onTap,
  });

  final Group group;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(groupMembersProvider(group.id));
    final count = membersAsync.valueOrNull?.length ?? 0;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: 96,
        decoration: BoxDecoration(
          color: groupCardColor(group.id),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : groupBorderColor(group.id),
            width: selected ? 2.5 : 1.2,
          ),
        ),
        child: Stack(
          children: [
            if (selected)
              Positioned(
                top: 4,
                right: 4,
                child: Icon(Icons.check_circle,
                    size: 16, color: Theme.of(context).colorScheme.primary),
              ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(group.emoji ?? '👥',
                      style: const TextStyle(fontSize: 22)),
                  const SizedBox(height: 4),
                  Text(
                    group.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  Text(
                    '$count',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
