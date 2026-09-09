import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/db/database.dart';
import '../../providers.dart';
import '../../shared/widgets/douu_bits.dart';
import '../../shared/widgets/douu_states.dart';

/// S7 — Groups hub (HOME). Momentum strip, groups, quest entry, quick-sort.
class HubScreen extends ConsumerStatefulWidget {
  const HubScreen({super.key});

  @override
  ConsumerState<HubScreen> createState() => _HubScreenState();
}

class _HubScreenState extends ConsumerState<HubScreen> {
  // Track previous RAG per group to detect amber→red flips (Tier 3).
  final Map<int, String> _prevRags = {};
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(healthServiceProvider).recomputeAll();
      final quest =
          await ref.read(questEngineProvider).generateForCurrentPeriod();
      await _scheduleNotifications(quest);
      await ref.read(sideQuestEngineProvider).generateForToday();
    });
  }

  Future<void> _scheduleNotifications(Quest? quest) async {
    final notif = ref.read(notificationServiceProvider);
    final repo = ref.read(repositoryProvider);
    final db = ref.read(databaseProvider);
    final settings = await db.getSettings();

    // Daily quest nudge only exists while there is an actionable quest. A
    // completed quest should not produce a stale repeat notification.
    final names = await _firstNamesFromQuest(quest);
    if (quest?.status == 'active') {
      await notif.scheduleQuestWithNames(
        firstNames: names,
        hour: settings.notifyHour,
        minute: settings.notifyMinute,
        quietStart: settings.quietHoursStart,
        quietEnd: settings.quietHoursEnd,
      );
    } else {
      await notif.cancelQuestNudge();
    }

    // A classification question is useful only when no Daily Quest is waiting.
    // It is throttled per contact/community pair for a week.
    final uncategorized = await repo.uncategorizedContacts();
    if (quest?.status != 'active' && uncategorized.isNotEmpty) {
      final groups = await repo.watchGroups().first;
      if (groups.isNotEmpty) {
        final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;
        const weekMs = 7 * 24 * 60 * 60 * 1000;
        ({Contact contact, Group group})? candidate;
        for (final contact in uncategorized) {
          for (final group in groups) {
            final key = '${contact.id}:${group.id}';
            final last =
                await repo.notificationLastScheduled('sort-question', key);
            if (last == null || nowMs - last >= weekMs) {
              candidate = (contact: contact, group: group);
              break;
            }
          }
          if (candidate != null) break;
        }
        if (candidate != null) {
          final contact = candidate.contact;
          final group = candidate.group;
          final key = '${contact.id}:${group.id}';
          await notif.scheduleSortQuestion(
            contactName: contact.displayName.trim().split(RegExp(r'\s+')).first,
            groupName: group.name,
            contactId: contact.id,
            groupId: group.id,
            hour: settings.notifyHour,
            minute: settings.notifyMinute,
            quietStart: settings.quietHoursStart,
            quietEnd: settings.quietHoursEnd,
          );
          await repo.recordNotificationScheduled('sort-question', key, nowMs);
        }
      }
    }
  }

  Future<List<String>> _firstNamesFromQuest(Quest? quest) async {
    if (quest == null) return const [];
    final pool = (jsonDecode(quest.poolContactIds) as List).cast<int>();
    final repo = ref.read(repositoryProvider);
    final names = <String>[];
    for (final id in pool.take(3)) {
      final c = await repo.contactById(id);
      if (c != null) {
        names.add(c.displayName.trim().split(RegExp(r'\s+')).first);
      }
    }
    return names;
  }

  void _checkGroupReds(List<Group> groups) {
    final notif = ref.read(notificationServiceProvider);
    for (final g in groups) {
      final prev = _prevRags[g.id];
      if (prev != null && prev != 'red' && g.ragHealth == 'red') {
        notif.notifyGroupRed(groupId: g.id, groupName: g.name);
      }
      _prevRags[g.id] = g.ragHealth;
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupsAsync = ref.watch(groupsProvider);
    final questAsync = ref.watch(todayQuestProvider);
    final streakAsync = ref.watch(globalStreakProvider);
    final totalWonAsync = ref.watch(totalQuestsWonProvider);

    // Tier 3: detect any group flipping to red and fire a notification.
    ref.listen<AsyncValue<List<Group>>>(groupsProvider, (_, next) {
      next.whenData(_checkGroupReds);
    });

    return Scaffold(
      appBar: AppBar(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            const Text('Douu'),
            const SizedBox(width: 8),
            Text(
              DateFormat('EEE, d MMM').format(DateTime.now()),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Quest archive',
            icon: const Icon(Icons.history),
            onPressed: () => context.push('/quest/archive'),
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
          IconButton(
            tooltip: 'Insights',
            icon: const Icon(Icons.insights_outlined),
            onPressed: () => context.push('/insights'),
          ),
        ],
      ),
      body: DotBackground(
        child: groupsAsync.when(
          loading: () => const DouuLoading(),
          error: (e, _) => const DouuError(message: 'Something went wrong.'),
          data: (groups) {
            // Prime the transition detector without alerting for pre-existing
            // red communities when the hub first opens.
            for (final group in groups) {
              _prevRags.putIfAbsent(group.id, () => group.ragHealth);
            }
            return ListView(
              controller: _scrollCtrl,
              padding: EdgeInsets.fromLTRB(
                  16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
              children: [
                // ── Momentum strip ─────────────────────────────────────────
                streakAsync.maybeWhen(
                  data: (s) => _MomentumCard(
                    totalWon: totalWonAsync.valueOrNull ?? 0,
                    currentStreak: s.currentStreak,
                    bestStreak: s.bestStreak,
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
                const SizedBox(height: 8),

                // ── Today's quest entry ────────────────────────────────────
                questAsync.maybeWhen(
                  data: (quest) {
                    if (quest == null) return const SizedBox.shrink();
                    final n = _poolSize(quest);
                    if (n == 0) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _AnimatedQuestButton(
                        reached: quest.reachedCount,
                        total: n,
                        onTap: () => context.push('/quest'),
                      ),
                    );
                  },
                  orElse: () => const SizedBox.shrink(),
                ),

                // ── Side quest / Sort contacts entry points ────────────────
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: _HubIconLink(
                          icon: Icons.auto_awesome,
                          label: 'Side quest',
                          route: '/side-quest',
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _HubIconLink(
                          icon: Icons.grid_view_rounded,
                          label: 'Sort contacts',
                          route: '/sort-contacts',
                        ),
                      ),
                    ],
                  ),
                ),

                const _SectionHeader('Your communities'),
                if (groups.isEmpty)
                  const DouuEmpty(
                    message:
                        'Create your first community to start staying in touch.',
                    icon: Icons.group_add_outlined,
                  )
                else
                  ...groups.map((g) => _GroupCard(group: g)),
                const SizedBox(height: 8),
                _AnimatedOutlineButton(
                  onPressed: () => context.push('/groups/new'),
                  icon: Icons.add,
                  label: 'Create new community',
                ),
                const SizedBox(height: 32),
                // Quick-sort — no label, just the card at the bottom
                const _QuickSort(),
              ],
            );
          },
        ),
      ),
    );
  }

  int _poolSize(Quest q) {
    final s = q.poolContactIds.trim();
    if (s == '[]' || s.isEmpty) return 0;
    return ','.allMatches(s).length + 1;
  }
}

// ── Momentum card ─────────────────────────────────────────────────────

class _MomentumCard extends StatefulWidget {
  const _MomentumCard({
    required this.totalWon,
    required this.currentStreak,
    required this.bestStreak,
  });

  final int totalWon;
  final int currentStreak;
  final int bestStreak;

  @override
  State<_MomentumCard> createState() => _MomentumCardState();
}

class _MomentumCardState extends State<_MomentumCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const cardColor = Color(0xFFDCEEF8);
    const textDark = Color(0xFF1A3A54);

    return ScaleTransition(
      scale: _scale,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFBDD9F0), width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: Row(
            children: [
              Expanded(
                child: _StreakStat(
                  value: widget.totalWon,
                  label: 'Completed',
                  emoji: '🎯',
                  textColor: textDark,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: const Color(0xFFBDD9F0),
              ),
              Expanded(
                child: _StreakStat(
                  value: widget.currentStreak,
                  label: 'Current',
                  emoji: '🔥',
                  textColor: textDark,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: const Color(0xFFBDD9F0),
              ),
              Expanded(
                child: _StreakStat(
                  value: widget.bestStreak,
                  label: 'Best',
                  emoji: '🏆',
                  textColor: textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StreakStat extends StatelessWidget {
  const _StreakStat({
    required this.value,
    required this.label,
    required this.emoji,
    required this.textColor,
  });

  final int value;
  final String label;
  final String emoji;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 2),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: textColor,
            height: 1,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            color: textColor.withAlpha(180),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ── Animated quest button ─────────────────────────────────────────────

class _AnimatedQuestButton extends StatefulWidget {
  const _AnimatedQuestButton({
    required this.reached,
    required this.total,
    required this.onTap,
  });

  final int reached;
  final int total;
  final VoidCallback onTap;

  @override
  State<_AnimatedQuestButton> createState() => _AnimatedQuestButtonState();
}

class _AnimatedQuestButtonState extends State<_AnimatedQuestButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) => setState(() => _scale = 0.96);
  void _onTapUp(_) {
    setState(() => _scale = 1.0);
    widget.onTap();
  }

  void _onTapCancel() => setState(() => _scale = 1.0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: FilledButton(
          onPressed: widget.onTap,
          child: Text("Today's quest · ${widget.reached} of ${widget.total}"),
        ),
      ),
    );
  }
}

// ── Animated outline button ───────────────────────────────────────────

class _AnimatedOutlineButton extends StatefulWidget {
  const _AnimatedOutlineButton({
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final String label;

  @override
  State<_AnimatedOutlineButton> createState() => _AnimatedOutlineButtonState();
}

class _AnimatedOutlineButtonState extends State<_AnimatedOutlineButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: OutlinedButton.icon(
          onPressed: widget.onPressed,
          icon: Icon(widget.icon),
          label: Text(widget.label),
        ),
      ),
    );
  }
}

// ── Hub icon link (Side quest / Sort contacts entry points) ───────────

class _HubIconLink extends StatefulWidget {
  const _HubIconLink({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;

  @override
  State<_HubIconLink> createState() => _HubIconLinkState();
}

class _HubIconLinkState extends State<_HubIconLink> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        context.push(widget.route);
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: scheme.secondaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: scheme.onSecondaryContainer),
              const SizedBox(height: 4),
              Text(
                widget.label,
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: scheme.onSecondaryContainer),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(label.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall),
    );
  }
}

// ── Group card ────────────────────────────────────────────────────────

class _GroupCard extends ConsumerStatefulWidget {
  const _GroupCard({required this.group});
  final Group group;

  @override
  ConsumerState<_GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends ConsumerState<_GroupCard>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(groupMembersProvider(widget.group.id));
    final count =
        membersAsync.maybeWhen(data: (m) => m.length, orElse: () => 0);

    final cardColor = groupCardColor(widget.group.id);
    final borderColor = groupBorderColor(widget.group.id);

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        context.push('/groups/${widget.group.id}');
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('${widget.group.emoji ?? '👥'} '),
                    Expanded(
                      child: Text(widget.group.name,
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    Text('$count ${count == 1 ? "person" : "ppl"}'),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FrequencyPill(frequencyDays: widget.group.frequencyDays),
                    StreakChip(days: widget.group.streakCount),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RagDot(rag: widget.group.ragHealth),
                        const SizedBox(width: 4),
                        Text(RagDot.label(widget.group.ragHealth),
                            style: Theme.of(context).textTheme.labelMedium),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Quick-sort ────────────────────────────────────────────────────────
// Asks about one community at a time with pure swipe UX.
// Right swipe → add to that community (green ✓).
// Left swipe  → not this community / skip (red ✗).
// Uses reactive streams so there is no FutureBuilder async gap that
// would cause the ListView to scroll back to the top.

class _QuickSort extends ConsumerStatefulWidget {
  const _QuickSort();

  @override
  ConsumerState<_QuickSort> createState() => _QuickSortState();
}

class _QuickSortState extends ConsumerState<_QuickSort> {
  // Contacts fully exhausted this session (asked about every community).
  final _skippedContacts = <int>{};
  // Per-contact: communities already decided (accepted or declined) this
  // session, so a contact keeps getting asked about its *other* communities
  // instead of disappearing after the first swipe — a contact can belong to
  // more than one community.
  final _decidedGroupIds = <int, Set<int>>{};
  List<int>? _shuffledIds;

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(contactsProvider);
    final membershipsAsync = ref.watch(groupMembershipsProvider);
    final groupsAsync = ref.watch(groupsProvider);

    // All three streams must be ready before we render anything.
    final contacts = contactsAsync.valueOrNull;
    final memberships = membershipsAsync.valueOrNull;
    final groups = groupsAsync.valueOrNull;
    if (contacts == null || memberships == null || groups == null) {
      return const SizedBox.shrink();
    }
    if (groups.isEmpty) return const SizedBox.shrink();

    // Stable shuffle — recompute only when the contact set changes.
    final ids = contacts.map((c) => c.id).toList();
    if (_shuffledIds == null || !_sameSet(_shuffledIds!, ids)) {
      _shuffledIds = List.of(ids)..shuffle(Random());
    }

    // Existing memberships per contact — a contact is only fully "sorted"
    // once every community has been either joined or declined this session,
    // not after its first membership (a contact can be in several).
    final existingGroupIdsByContact = <int, Set<int>>{};
    for (final m in memberships) {
      existingGroupIdsByContact
          .putIfAbsent(m.contactId, () => {})
          .add(m.groupId);
    }
    final sortedGroups = [...groups]..sort((a, b) => a.id.compareTo(b.id));

    // Pick the first un-skipped contact in shuffle order that still has a
    // community it hasn't been asked about, and the next such community.
    final contactsById = {for (final c in contacts) c.id: c};
    Contact? contact;
    Group? nextGroup;
    for (final id in _shuffledIds!) {
      if (_skippedContacts.contains(id)) continue;
      final existing = existingGroupIdsByContact[id] ?? const <int>{};
      final decided = _decidedGroupIds[id] ?? const <int>{};
      final remaining = sortedGroups
          .where((g) => !existing.contains(g.id) && !decided.contains(g.id));
      if (remaining.isEmpty) {
        _skippedContacts.add(id);
        continue;
      }
      final candidate = contactsById[id];
      // Contact may have vanished from the stream (e.g. deleted); skip
      // rather than falling back to an arbitrary contact, which could
      // resurrect a just-dismissed Dismissible with the same key.
      if (candidate == null) continue;
      contact = candidate;
      nextGroup = remaining.first;
      break;
    }

    if (contact == null || nextGroup == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader('Suggested contact'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text("Everyone's sorted.",
                  style: Theme.of(context).textTheme.bodyMedium),
            ),
          ),
        ],
      );
    }

    // Capture primitive values before closures — contact/nextGroup are
    // nullable so the analyser won't promote them inside lambdas even after
    // the null check above.
    final contactId = contact.id;
    final groupId = nextGroup.id;
    final groupName = nextGroup.name;
    final firstName = contact.displayName.trim().split(RegExp(r'\s+')).first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('Suggested contact'),
        Dismissible(
          key: ValueKey('qs_${contactId}_$groupId'),
          direction: DismissDirection.horizontal,
          // null (not Duration.zero) — a zero-duration resize animation fires its
          // completion callback synchronously mid-frame, reentering the tree
          // before the dismissed element is torn down and tripping the
          // "still part of the tree" assert. null skips the resize phase
          // entirely and calls onDismissed once, after the swipe animation.
          resizeDuration: null,
          onDismissed: (direction) {
            // Either way this community is decided for this contact —
            // move on to their next undecided community, if any, rather
            // than dropping the contact from the queue entirely.
            setState(() {
              _decidedGroupIds.putIfAbsent(contactId, () => {}).add(groupId);
            });
            if (direction == DismissDirection.startToEnd) {
              _assign(contactId, groupId);
            }
          },
          // Right-swipe reveal: green accept
          background: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade400,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 24),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white, size: 32),
                SizedBox(height: 4),
                Text('Add',
                    style: TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
          ),
          // Left-swipe reveal: red skip
          secondaryBackground: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.shade300,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.close, color: Colors.white, size: 32),
                SizedBox(height: 4),
                Text('Skip',
                    style: TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
          ),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  DouuAvatar(name: contact.displayName, radius: 22),
                  const SizedBox(height: 8),
                  Text(
                    contact.displayName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Is $firstName in $groupName?',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_back,
                              size: 14, color: Colors.red.shade400),
                          const SizedBox(width: 4),
                          Text('<- swipe to skip',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red.shade400,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('swipe to add ->',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green.shade600,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward,
                              size: 14, color: Colors.green.shade600),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool _sameSet(List<int> a, List<int> b) =>
      a.length == b.length && a.toSet().containsAll(b);

  Future<void> _assign(int contactId, int groupId) async {
    await ref.read(repositoryProvider).addMembership(contactId, groupId);
    await ref.read(healthServiceProvider).recomputeGroup(groupId);
    // membershipsProvider stream updates automatically → no setState needed.
  }
}
