import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/defaults.dart';
import '../../providers.dart';


/// S9 — Create group. Name + frequency + optional emoji; unique name enforced.
class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final _nameController = TextEditingController();
  final _customController = TextEditingController();
  int _frequency = DouuDefaults.frequencyMonthly;
  bool _custom = false;
  String? _emoji;
  String? _error;

  static const _presets = [
    ('Daily', DouuDefaults.frequencyDaily),
    ('Weekdays', DouuDefaults.frequencyWeekdays),
    ('Weekly', DouuDefaults.frequencyWeekly),
    ('Biweekly', DouuDefaults.frequencyBiweekly),
    ('Monthly', DouuDefaults.frequencyMonthly),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _customController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Please enter a name.');
      return;
    }
    final repo = ref.read(repositoryProvider);
    if (await repo.groupByName(name) != null) {
      setState(() => _error = 'A community with this name already exists.');
      return;
    }
    var frequency = _frequency;
    if (_custom) {
      final parsed = int.tryParse(_customController.text.trim());
      if (parsed == null || parsed < 1) {
        setState(() => _error = 'Enter a valid number of days.');
        return;
      }
      frequency = parsed;
    }
    final id = await repo.createGroup(
      name: name,
      frequencyDays: frequency,
      emoji: _emoji,
    );
    if (mounted) context.pushReplacement('/groups/$id');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New community')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Emoji + Name row ──────────────────────────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: _pickEmoji,
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color:
                                    Theme.of(context).colorScheme.outlineVariant,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                _emoji ?? '👥',
                                style: const TextStyle(fontSize: 26),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _nameController,
                            decoration:
                                const InputDecoration(labelText: 'Name'),
                            autofocus: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap the icon to pick an emoji',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withAlpha(120),
                          ),
                    ),
                    const SizedBox(height: 24),
                    Text('Remind me to reach out:',
                        style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final (label, days) in _presets)
                          ChoiceChip(
                            label: Text(label),
                            selected: !_custom && _frequency == days,
                            onSelected: (_) => setState(() {
                              _frequency = days;
                              _custom = false;
                            }),
                          ),
                        ChoiceChip(
                          label: const Text('Custom'),
                          selected: _custom,
                          onSelected: (_) => setState(() => _custom = true),
                        ),
                      ],
                    ),
                    if (_custom) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 160,
                        child: TextField(
                          controller: _customController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Every N days',
                            suffixText: 'days',
                          ),
                        ),
                      ),
                    ],
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error)),
                    ],
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                        onPressed: _create, child: const Text('Create')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickEmoji() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const EmojiPicker(),
    );
    if (picked != null) setState(() => _emoji = picked);
  }
}

/// Free-text emoji entry — no preset list, just type or paste any emoji.
class EmojiPicker extends StatefulWidget {
  const EmojiPicker({super.key});

  @override
  State<EmojiPicker> createState() => _EmojiPickerState();
}

class _EmojiPickerState extends State<EmojiPicker> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _confirm() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    // Take only the first grapheme cluster (one emoji / character).
    final first = text.characters.first;
    Navigator.pop(context, first);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pick an icon',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('Type or paste any emoji below',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    maxLength: 8,
                    style: const TextStyle(fontSize: 28),
                    decoration: const InputDecoration(
                      hintText: '😊',
                      counterText: '',
                    ),
                    onSubmitted: (_) => _confirm(),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: _confirm,
                  // Row gives non-Expanded children unbounded width; the app
                  // theme's default minimumSize is Size.fromHeight(48) (i.e.
                  // minWidth: infinity), which crashes here. Keep this one
                  // compact instead of stretching to fill the row.
                  style: FilledButton.styleFrom(minimumSize: const Size(64, 48)),
                  child: const Text('Use'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
