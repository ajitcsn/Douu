import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/db/database.dart';
import '../../providers.dart';
import '../../shared/widgets/douu_bits.dart';
import '../../shared/widgets/douu_states.dart';
import 'message_handoff.dart';

/// S12 — Today's quest. Core action surface. One-tap WhatsApp, penalty-free
/// skip, encouraging win banner.
class QuestScreen extends ConsumerStatefulWidget {
  const QuestScreen({super.key});

  @override
  ConsumerState<QuestScreen> createState() => _QuestScreenState();
}

class _QuestScreenState extends ConsumerState<QuestScreen>
    with WidgetsBindingObserver, MessageHandoffMixin {
  @override
  void initState() {
    super.initState(); // MessageHandoffMixin registers the lifecycle observer
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Generate a quest if none exists for this period yet.
      // The hub also does this on open, but the quest screen must be
      // self-sufficient so the user can reach it via notification deep-link.
      ref.read(questEngineProvider).generateForCurrentPeriod();
    });
  }

  @override
  Widget build(BuildContext context) {
    final questAsync = ref.watch(todayQuestProvider);
    final streakAsync = ref.watch(globalStreakProvider);
    final contactsAsync = ref.watch(contactsProvider);
    final groupsAsync = ref.watch(groupsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's quest"),
        actions: [
          streakAsync.maybeWhen(
            data: (s) => Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                  child: Text('🔥 ${s.currentStreak}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16))),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: SafeArea(
        child: DotBackground(
          child: _buildBody(context, groupsAsync, questAsync, contactsAsync),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AsyncValue<List<Group>> groupsAsync,
    AsyncValue<Quest?> questAsync,
    AsyncValue<List<Contact>> contactsAsync,
  ) {
    return groupsAsync.when(
      loading: () => const DouuLoading(),
      error: (_, __) => const DouuError(message: 'Something went wrong.'),
      data: (groups) {
        if (groups.isEmpty) {
          return _FirstDayQuest(groups: groups);
        }
        return _buildQuestBody(context, questAsync, contactsAsync);
      },
    );
  }

  Widget _buildQuestBody(
    BuildContext context,
    AsyncValue<Quest?> questAsync,
    AsyncValue<List<Contact>> contactsAsync,
  ) {
    return questAsync.when(
      loading: () => const DouuLoading(),
      error: (e, _) => const DouuError(message: 'Could not load your quest.'),
      data: (quest) {
        if (quest == null) {
          return const DouuEmpty(
            message: "Nothing due right now — you're on top of it.",
            icon: Icons.check_circle_outline,
          );
        }

        final itemsAsync = ref.watch(questItemsProvider(quest.id));
        return itemsAsync.when(
          loading: () => const DouuLoading(),
          error: (_, __) =>
              const DouuError(message: 'Could not load your quest.'),
          data: (items) => contactsAsync.when(
            loading: () => const DouuLoading(),
            error: (_, __) =>
                const DouuError(message: 'Could not load contacts.'),
            data: (allContacts) {
              final contactMap = {for (final c in allContacts) c.id: c};
              final visibleItems =
                  items.where((item) => item.state != 'skipped').toList();
              final won = quest.status == 'won' ||
                  items.where((item) => item.state == 'reached').length >=
                      quest.kThreshold;

              if (visibleItems.isEmpty && !won) {
                return const DouuEmpty(
                  message: 'Done for today. See you tomorrow.',
                  icon: Icons.nightlight_outlined,
                );
              }
              final resolvedRows = visibleItems
                  .map((item) => (
                        item: item,
                        contact: contactMap[item.contactId],
                      ))
                  .where((row) => row.contact != null)
                  .toList();

              if (resolvedRows.isEmpty && !won) {
                return const DouuEmpty(
                  message: "Nothing due right now — you're on top of it.",
                  icon: Icons.check_circle_outline,
                );
              }

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  Text(
                    'Message ${quest.kThreshold} out of ${items.length} to '
                    "complete today's quest. The rest are always optional.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  for (final row in resolvedRows)
                    _QuestRow(
                      contact: row.contact!,
                      itemState: row.item.state,
                      screen: this,
                    ),
                  if (won) ...[
                    const SizedBox(height: 16),
                    _WinBanner(),
                  ],
                ],
              );
            },
          ),
        );
      },
    );
  }
}

// ── Win banner ────────────────────────────────────────────────────────

class _WinBanner extends StatefulWidget {
  @override
  State<_WinBanner> createState() => _WinBannerState();
}

class _WinBannerState extends State<_WinBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _slide = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
          .animate(_slide),
      child: FadeTransition(
        opacity: _ctrl,
        child: Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '✓ Quest complete. Message more if you feel like it.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Quest row ─────────────────────────────────────────────────────────

class _QuestRow extends ConsumerWidget {
  const _QuestRow({
    required this.contact,
    required this.itemState,
    required this.screen,
  });

  final Contact contact;
  final String itemState;
  final _QuestScreenState screen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final launcher = ref.read(whatsappLauncherProvider);
    final canMessage = launcher.canMessage(contact.phoneE164);
    final reached = itemState == 'reached';

    final groupsAsync = ref.watch(contactGroupsProvider(contact.id));
    final groups = [...groupsAsync.valueOrNull ?? const <Group>[]]
      ..sort((a, b) => a.id.compareTo(b.id));
    final primaryGroup = groups.isEmpty ? null : groups.first;
    final communityNames = groups.map((g) => g.name).join(', ');

    final subtitle = reached
        ? 'Reached ✓'
        : canMessage
            ? 'Due to reconnect'
            : 'No valid WhatsApp number';

    return Card(
      color: primaryGroup == null ? null : groupCardColor(primaryGroup.id),
      shape: primaryGroup == null
          ? null
          : RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: groupBorderColor(primaryGroup.id)),
            ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            DouuAvatar(name: contact.displayName),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(contact.displayName,
                      style: Theme.of(context).textTheme.titleMedium),
                  Text(communityNames.isEmpty
                      ? subtitle
                      : '$subtitle · $communityNames'),
                ],
              ),
            ),
            if (!reached) ...[
              IconButton.filledTonal(
                tooltip: 'Message on WhatsApp',
                icon: const Icon(Icons.send, size: 18),
                onPressed:
                    canMessage ? () => screen.startMessage(contact) : null,
              ),
              _AnimatedSkipButton(
                onPressed: () async {
                  await ref.read(questEngineProvider).markSkipped(contact.id);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Animated skip button ──────────────────────────────────────────────

class _AnimatedSkipButton extends StatefulWidget {
  const _AnimatedSkipButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_AnimatedSkipButton> createState() => _AnimatedSkipButtonState();
}

class _AnimatedSkipButtonState extends State<_AnimatedSkipButton>
    with TickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _rotation = Tween<double>(begin: 0, end: 0.5)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _press() async {
    await _ctrl.forward();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _rotation,
      child: IconButton(
        tooltip: 'Skip (no penalty)',
        icon: const Icon(Icons.close),
        onPressed: _press,
      ),
    );
  }
}

// ── First-day quest ───────────────────────────────────────────────────

class _FirstDayQuest extends StatelessWidget {
  const _FirstDayQuest({required this.groups});

  final List<Group> groups;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final familyDone = groups.any((g) => g.name.toLowerCase() == 'family');
    final friendsDone = groups.any((g) => g.name.toLowerCase() == 'friends');
    final completedCount = (familyDone ? 1 : 0) + (friendsDone ? 1 : 0);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Your first quest', style: text.headlineSmall),
        const SizedBox(height: 6),
        Text(
          'Set up your first two communities to unlock daily quests.',
          style:
              text.bodyMedium?.copyWith(color: scheme.onSurface.withAlpha(180)),
        ),
        const SizedBox(height: 16),
        // Progress tracker
        Row(
          children: [
            Icon(
              completedCount == 2
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              size: 18,
              color: completedCount == 2
                  ? const Color(0xFF2F9E44)
                  : scheme.onSurface.withAlpha(120),
            ),
            const SizedBox(width: 8),
            Text(
              '$completedCount of 2 communities created',
              style: text.bodySmall?.copyWith(
                color: completedCount == 2
                    ? const Color(0xFF2F9E44)
                    : scheme.onSurface.withAlpha(160),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _SetupStep(
          done: familyDone,
          emoji: '👨‍👩‍👧',
          title: 'Start community of Family',
          subtitle: familyDone
              ? 'Done — your Family community is ready.'
              : 'People who matter most, reached often.',
          action: familyDone
              ? null
              : FilledButton(
                  onPressed: () => context.push('/groups/new'),
                  child: const Text('Create'),
                ),
        ),
        const SizedBox(height: 12),
        _SetupStep(
          done: friendsDone,
          emoji: '👯',
          title: 'Start community of Friends',
          subtitle: friendsDone
              ? 'Done — your Friends community is ready.'
              : 'Close friends you want to keep in touch with.',
          action: friendsDone
              ? null
              : FilledButton(
                  onPressed: () => context.push('/groups/new'),
                  child: const Text('Create'),
                ),
        ),
        const SizedBox(height: 32),
        if (completedCount < 2)
          Text(
            'Once both communities are set up, your daily quests will appear here.',
            style: text.bodySmall
                ?.copyWith(color: scheme.onSurface.withAlpha(140)),
            textAlign: TextAlign.center,
          ),
        if (completedCount == 2)
          Text(
            "You're all set! Your quests will appear here once you have contacts in your communities.",
            style: text.bodySmall?.copyWith(
              color: const Color(0xFF2F9E44),
            ),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }
}

class _SetupStep extends StatelessWidget {
  const _SetupStep({
    required this.done,
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.action,
  });

  final bool done;
  final String emoji;
  final String title;
  final String subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: done
                    ? const Color(0xFF2F9E44).withAlpha(30)
                    : scheme.surfaceContainerHighest,
                shape: BoxShape.circle,
                border: Border.all(
                  color: done ? const Color(0xFF2F9E44) : scheme.outlineVariant,
                ),
              ),
              child: Center(
                child: done
                    ? const Icon(Icons.check,
                        size: 18, color: Color(0xFF2F9E44))
                    : Text(emoji, style: const TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          decoration: done ? TextDecoration.lineThrough : null,
                          color:
                              done ? scheme.onSurface.withAlpha(120) : null)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                  if (action != null) ...[
                    const SizedBox(height: 12),
                    action!,
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
