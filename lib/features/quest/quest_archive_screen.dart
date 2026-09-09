import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/db/database.dart';
import '../../domain/services/side_quest_engine.dart';
import '../../providers.dart';
import '../../shared/widgets/douu_states.dart';

/// Archive of past quests — daily quests (won/expired) and rotating side
/// quests, each read-only history in its own tab.
class QuestArchiveScreen extends ConsumerStatefulWidget {
  const QuestArchiveScreen({super.key});

  @override
  ConsumerState<QuestArchiveScreen> createState() => _QuestArchiveScreenState();
}

typedef _ArchiveData = (
  List<Quest>,
  Map<int, String>,
  Map<int, Set<int>>,
  List<SideQuest>,
  List<SideQuestPrompt>,
);

class _QuestArchiveScreenState extends ConsumerState<QuestArchiveScreen> {
  late Future<_ArchiveData> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _load();
  }

  Future<_ArchiveData> _load() async {
    final repo = ref.read(repositoryProvider);
    final results = await Future.wait([
      repo.questHistory(),
      repo.allContacts(),
      repo.reachedContactIdsByQuest(),
      repo.sideQuestHistory(),
      SideQuestEngine.loadPrompts(),
    ]);
    final history = results[0] as List<Quest>;
    final contacts = results[1] as List<Contact>;
    final reachedByQuest = results[2] as Map<int, Set<int>>;
    final sideQuests = results[3] as List<SideQuest>;
    final prompts = results[4] as List<SideQuestPrompt>;
    final namesById = {for (final c in contacts) c.id: c.displayName};
    return (history, namesById, reachedByQuest, sideQuests, prompts);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quest archive'),
          bottom: const TabBar(tabs: [
            Tab(text: 'Daily quests'),
            Tab(text: 'Side quests'),
          ]),
        ),
        body: FutureBuilder<_ArchiveData>(
          future: _historyFuture,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const DouuLoading();
            }
            final (quests, namesById, reachedByQuest, sideQuests, prompts) =
                snap.data ??
                    (
                      const <Quest>[],
                      const <int, String>{},
                      const <int, Set<int>>{},
                      const <SideQuest>[],
                      const <SideQuestPrompt>[],
                    );
            return TabBarView(
              children: [
                quests.isEmpty
                    ? const DouuEmpty(
                        message:
                            'No completed quests yet — come back after your first one.',
                        icon: Icons.history,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: quests.length,
                        itemBuilder: (context, i) => _QuestArchiveTile(
                          quest: quests[i],
                          namesById: namesById,
                          reachedIds: reachedByQuest[quests[i].id] ?? const {},
                        ),
                      ),
                sideQuests.isEmpty
                    ? const DouuEmpty(
                        message: 'No side quests yet — check the hub tomorrow.',
                        icon: Icons.auto_awesome,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: sideQuests.length,
                        itemBuilder: (context, i) => _SideQuestArchiveTile(
                          sideQuest: sideQuests[i],
                          namesById: namesById,
                          prompts: prompts,
                        ),
                      ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _QuestArchiveTile extends StatelessWidget {
  const _QuestArchiveTile({
    required this.quest,
    required this.namesById,
    required this.reachedIds,
  });
  final Quest quest;
  final Map<int, String> namesById;
  final Set<int> reachedIds;

  @override
  Widget build(BuildContext context) {
    final won = quest.status == 'won';
    final date =
        DateTime.fromMillisecondsSinceEpoch(quest.periodStart, isUtc: true)
            .toLocal();
    final poolIds = (jsonDecode(quest.poolContactIds) as List).cast<int>();
    final pool = poolIds
        .where((id) => namesById.containsKey(id))
        .map((id) => (id: id, name: namesById[id]!))
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                won ? Icons.check_circle : Icons.cancel_outlined,
                color: won
                    ? const Color(0xFF2F9E44)
                    : Theme.of(context).colorScheme.outline,
              ),
              title: Text(DateFormat('d MMM yyyy').format(date)),
              subtitle: Text(won ? 'Completed' : 'Not completed'),
              trailing: Text('${quest.reachedCount} of ${quest.kThreshold}'),
            ),
            if (pool.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text.rich(
                TextSpan(
                  style: Theme.of(context).textTheme.bodySmall,
                  children: [
                    for (var i = 0; i < pool.length; i++) ...[
                      if (i > 0) const TextSpan(text: ', '),
                      TextSpan(
                        text: pool[i].name,
                        style: reachedIds.contains(pool[i].id)
                            ? const TextStyle(fontWeight: FontWeight.bold)
                            : null,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SideQuestArchiveTile extends StatelessWidget {
  const _SideQuestArchiveTile({
    required this.sideQuest,
    required this.namesById,
    required this.prompts,
  });
  final SideQuest sideQuest;
  final Map<int, String> namesById;
  final List<SideQuestPrompt> prompts;

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(sideQuest.dayKey);
    final done = sideQuest.completedAt != null;
    final prompt = prompts.where((p) => p.id == sideQuest.promptId).firstOrNull;
    final contactName =
        sideQuest.contactId == null ? null : namesById[sideQuest.contactId];

    return Card(
      child: ListTile(
        leading: Icon(
          done ? Icons.check_circle : Icons.radio_button_unchecked,
          color: done
              ? const Color(0xFF2F9E44)
              : Theme.of(context).colorScheme.outline,
        ),
        title: Text(prompt?.title ?? sideQuest.promptId),
        subtitle: Text(
          contactName == null
              ? '${DateFormat('d MMM yyyy').format(date)} — not done'
              : '${DateFormat('d MMM yyyy').format(date)} — completed with $contactName',
        ),
      ),
    );
  }
}
