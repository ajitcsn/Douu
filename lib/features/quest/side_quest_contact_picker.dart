import 'package:flutter/material.dart';

import '../../data/db/database.dart';
import '../../domain/services/contacts_import.dart';
import '../../shared/widgets/douu_bits.dart';
import '../../shared/widgets/douu_states.dart';

/// Single-tap contact picker for a side quest — the app never guesses who
/// fits the prompt, the user self-selects from their full contact list.
class SideQuestContactPicker extends StatefulWidget {
  const SideQuestContactPicker({
    super.key,
    required this.contacts,
    this.scrollController,
  });

  final List<Contact> contacts;
  final ScrollController? scrollController;

  static Future<Contact?> show(BuildContext context, {required List<Contact> contacts}) {
    return showModalBottomSheet<Contact>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.92,
        builder: (context, scrollController) => SideQuestContactPicker(
          contacts: contacts,
          scrollController: scrollController,
        ),
      ),
    );
  }

  @override
  State<SideQuestContactPicker> createState() => _SideQuestContactPickerState();
}

class _SideQuestContactPickerState extends State<SideQuestContactPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final available = ContactsImporter.smartSort([...widget.contacts]);
    final filtered = _query.isEmpty
        ? available
        : available
            .where((c) => c.displayName.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return SafeArea(
      top: false,
      child: Column(
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search contacts',
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: filtered.isEmpty
                ? const DouuEmpty(message: 'No matches')
                : ListView.builder(
                    controller: widget.scrollController,
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final c = filtered[i];
                      return ListTile(
                        leading: DouuAvatar(name: c.displayName),
                        title: Text(c.displayName),
                        onTap: () => Navigator.pop(context, c),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
