import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart';
import '../../domain/services/side_quest_engine.dart';
import '../../providers.dart';
import '../../shared/widgets/douu_bits.dart';
import '../../shared/widgets/douu_states.dart';
import 'side_quest_contact_picker.dart';
import 'message_handoff.dart';

/// A rotating, human-judgment prompt (see assets/quest_ideas.json) — the app
/// never picks the contact, the user does. Deliberately separate from the
/// daily quest: no pool, no streak, just "does this framing fit someone in
/// your life today?"
///
/// Self-sufficient like QuestScreen: generates today's side quest itself so
/// this screen works correctly even reached directly, not just from the hub.
class SideQuestScreen extends ConsumerStatefulWidget {
  const SideQuestScreen({super.key});

  @override
  ConsumerState<SideQuestScreen> createState() => _SideQuestScreenState();
}

class _SideQuestScreenState extends ConsumerState<SideQuestScreen>
    with WidgetsBindingObserver, MessageHandoffMixin {
  // How many quick-pick suggestions to show below the main action.
  static const _suggestionCount = 6;
  // How many of the most-overdue contacts to shuffle suggestions from, so
  // they stay relevant without being the exact same 6 every time.
  static const _suggestionPoolSize = 20;

  List<int>? _suggestedIds;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sideQuestEngineProvider).generateForToday();
    });
  }

  List<Contact> _pickSuggestions(List<Contact> contacts) {
    final sorted = [...contacts]..sort((a, b) {
        final aAt = a.lastReachedAt;
        final bAt = b.lastReachedAt;
        if (aAt == null && bAt == null) return 0;
        if (aAt == null) return -1; // never-reached contacts are most "due"
        if (bAt == null) return 1;
        return aAt.compareTo(bAt); // oldest reached-at first
      });
    final pool = sorted.take(_suggestionPoolSize).toList()..shuffle(Random());
    return pool.take(_suggestionCount).toList();
  }

  void _refreshSuggestions(List<Contact> contacts) {
    setState(() {
      _suggestedIds = _pickSuggestions(contacts).map((c) => c.id).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sideQuestAsync = ref.watch(sideQuestForTodayProvider);
    final promptsAsync = ref.watch(sideQuestPromptsProvider);
    final contactsAsync = ref.watch(contactsProvider);

    final sideQuest = sideQuestAsync.valueOrNull;
    final prompts = promptsAsync.valueOrNull;
    final contacts = contactsAsync.valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Side quest')),
      body: SafeArea(
        child: sideQuest == null || prompts == null || contacts == null
            ? const DouuLoading()
            : _buildBody(context, sideQuest, prompts, contacts),
      ),
    );
  }

  Widget _buildBody(BuildContext context, SideQuest sideQuest,
      List<SideQuestPrompt> prompts, List<Contact> contacts) {
    final prompt = prompts.where((p) => p.id == sideQuest.promptId).firstOrNull;
    if (prompt == null) {
      return const DouuError(message: "Could not load today's side quest.");
    }

    final done = sideQuest.completedAt != null;
    final chosenContact = sideQuest.contactId == null
        ? null
        : contacts.where((c) => c.id == sideQuest.contactId).firstOrNull;

    _suggestedIds ??= _pickSuggestions(contacts).map((c) => c.id).toList();
    final contactsById = {for (final c in contacts) c.id: c};
    final suggestions = _suggestedIds!
        .map((id) => contactsById[id])
        .whereType<Contact>()
        .toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome,
                  size: 20, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(prompt.title,
                    style: Theme.of(context).textTheme.titleLarge),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(prompt.prompt, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 20),
          if (done)
            Row(
              children: [
                const Icon(Icons.check_circle,
                    size: 20, color: Color(0xFF2F9E44)),
                const SizedBox(width: 6),
                Text(
                  chosenContact == null
                      ? 'Done for today'
                      : 'Completed with ${chosenContact.displayName}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            )
          else ...[
            OutlinedButton(
              onPressed: () => _choose(context, sideQuest, contacts),
              child: const Text('Choose a contact'),
            ),
            if (suggestions.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Or pick one of these',
                  style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in suggestions)
                    ActionChip(
                      avatar: DouuAvatar(name: c.displayName, radius: 12),
                      label: Text(c.displayName),
                      onPressed: () => _pickContact(sideQuest, c),
                    ),
                ],
              ),
            ],
          ],
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () {
              ref.read(sideQuestEngineProvider).regenerate(sideQuest.id);
              _refreshSuggestions(contacts);
            },
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('New idea'),
          ),
        ],
      ),
    );
  }

  Future<void> _choose(
      BuildContext context, SideQuest sideQuest, List<Contact> contacts) async {
    final chosen =
        await SideQuestContactPicker.show(context, contacts: contacts);
    if (chosen == null) return;
    await _pickContact(sideQuest, chosen);
  }

  Future<void> _pickContact(SideQuest sideQuest, Contact chosen) async {
    final repo = ref.read(repositoryProvider);
    await repo.chooseContactForSideQuest(sideQuest.id, chosen.id);
    await startMessage(chosen);
  }

  @override
  Future<void> onReachConfirmed(Contact contact) async {
    final sideQuest = ref.read(sideQuestForTodayProvider).valueOrNull;
    if (sideQuest?.contactId == contact.id) {
      await ref.read(repositoryProvider).completeSideQuest(sideQuest!.id);
    }
  }
}
