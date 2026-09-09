import 'package:flutter/material.dart';

import '../../data/db/database.dart';
import '../../domain/services/contacts_import.dart';
import '../../shared/widgets/douu_bits.dart';
import '../../shared/widgets/douu_states.dart';

/// Reusable multi-select contact picker used by S4 (Family onboarding) and
/// S8 (bulk-add to a group). Smart pre-sorted, live-filtered, count-aware CTA.
class ContactPicker extends StatefulWidget {
  const ContactPicker({
    super.key,
    required this.contacts,
    required this.ctaLabelBuilder,
    required this.onSubmit,
    this.excludeIds = const {},
  });

  final List<Contact> contacts;
  final Set<int> excludeIds;

  /// Builds the CTA label from the current selection count, e.g. "Add 3 …".
  final String Function(int count) ctaLabelBuilder;
  final void Function(List<int> selectedIds) onSubmit;

  @override
  State<ContactPicker> createState() => _ContactPickerState();
}

class _ContactPickerState extends State<ContactPicker> {
  final _selected = <int>{};
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final available = ContactsImporter.smartSort(
      widget.contacts.where((c) => !widget.excludeIds.contains(c.id)).toList(),
    );
    final filtered = _query.isEmpty
        ? available
        : available
            .where((c) =>
                c.displayName.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search',
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: available.isEmpty
              ? const DouuEmpty(message: 'Everyone is already added here.')
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
                          subtitle: c.phoneE164 == null
                              ? const Text('No valid WhatsApp number')
                              : Text(c.phoneE164!),
                        );
                      },
                    ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: _selected.isEmpty
                  ? null
                  : () => widget.onSubmit(_selected.toList()),
              child: Text(widget.ctaLabelBuilder(_selected.length)),
            ),
          ),
        ),
      ],
    );
  }
}
