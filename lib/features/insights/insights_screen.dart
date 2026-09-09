import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/services/contacts_import.dart';
import '../../providers.dart';
import '../../shared/widgets/douu_bits.dart';
import '../../shared/widgets/douu_states.dart';

/// S14 — Insights / scores. Read-only momentum + group health. Self-reported
/// framing with an honest disclaimer.
class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(globalStreakProvider);
    final groupsAsync = ref.watch(groupsProvider);
    final contactsAsync = ref.watch(contactsProvider);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Your momentum')),
      body: groupsAsync.when(
        loading: () => const DouuLoading(),
        error: (e, _) => const DouuError(message: 'Could not load insights.'),
        data: (groups) {
          if (groups.isEmpty) {
            return const DouuEmpty(
              message:
                  'Sort some people and start reaching out to see your momentum.',
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              streakAsync.maybeWhen(
                data: (s) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _Stat(label: 'Current streak', value: '${s.currentStreak}'),
                    _Stat(label: 'Best', value: '${s.bestStreak}'),
                  ],
                ),
                orElse: () => const SizedBox.shrink(),
              ),
              const Divider(height: 32),
              Text('Community health', style: text.titleMedium),
              const SizedBox(height: 8),
              for (final g in groups)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: RagDot(rag: g.ragHealth, size: 14),
                  title: Text(g.name),
                  subtitle: Text(RagDot.label(g.ragHealth)),
                  trailing: StreakChip(days: g.streakCount),
                ),
              const Divider(height: 32),
              Text('Coverage', style: text.titleMedium),
              const SizedBox(height: 8),
              FutureBuilder<double>(
                future: ref.read(healthServiceProvider).coverage(),
                builder: (context, snap) {
                  final pct = ((snap.data ?? 0) * 100).round();
                  final scheme = Theme.of(context).colorScheme;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$pct% of your contacts are being reached within their frequency.',
                        style: text.bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: (snap.data ?? 0).clamp(0.0, 1.0),
                          minHeight: 10,
                          backgroundColor: scheme.outlineVariant,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            pct >= 80
                                ? const Color(0xFF2F9E44)
                                : pct >= 40
                                    ? const Color(0xFFF59F00)
                                    : const Color(0xFFE03131),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        pct >= 80
                            ? 'Great — you\'re staying on top of your relationships.'
                            : pct >= 40
                                ? 'Some people are slipping through. A few messages would go a long way.'
                                : 'Most of your contacts haven\'t heard from you in a while.',
                        style: text.bodySmall,
                      ),
                      const SizedBox(height: 6),
                      FutureBuilder<int>(
                        future: ContactsImporter(ref.read(databaseProvider))
                            .deviceContactsCount(),
                        builder: (context, phoneSnap) {
                          final douuCount = contactsAsync.valueOrNull?.length;
                          final phoneCount = phoneSnap.data;
                          if (douuCount == null ||
                              phoneCount == null ||
                              phoneCount == 0) {
                            return const SizedBox.shrink();
                          }
                          final onDouuPct =
                              ((douuCount / phoneCount) * 100).round();
                          return Text(
                            '$douuCount of $phoneCount phone contacts '
                            '($onDouuPct%) are on Douu.',
                            style: text.bodyMedium,
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'These are based on what you mark as reached.',
                      style: text.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(value, style: text.displaySmall),
        Text(label, style: text.bodyMedium),
      ],
    );
  }
}
