import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers.dart';
import '../../shared/widgets/douu_states.dart';
import 'contact_picker.dart';

/// S8 — Bulk-add, scoped to a group. Excludes existing members; returns to S10.
class BulkAddScreen extends ConsumerWidget {
  const BulkAddScreen({super.key, required this.groupId});

  final int groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(contactsProvider);
    final repo = ref.read(repositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder(
          future: repo.groupById(groupId),
          builder: (context, snap) =>
              Text('Add people to ${snap.data?.name ?? ''}'),
        ),
      ),
      body: contactsAsync.when(
        loading: () => const DouuLoading(),
        error: (e, _) => const DouuError(message: "Couldn't load contacts."),
        data: (contacts) => FutureBuilder<Set<int>>(
          future: repo.memberIdsOf(groupId),
          builder: (context, snap) {
            if (!snap.hasData) return const DouuLoading();
            return ContactPicker(
              contacts: contacts,
              excludeIds: snap.data!,
              ctaLabelBuilder: (n) => 'Add $n',
              onSubmit: (ids) async {
                await repo.addMemberships(ids, groupId);
                await ref
                    .read(healthServiceProvider)
                    .recomputeGroup(groupId);
                if (context.mounted) context.pop();
              },
            );
          },
        ),
      ),
    );
  }
}
