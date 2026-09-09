import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/defaults.dart';
import '../../data/db/database.dart';
import '../../providers.dart';

/// Mixin for screens with a "Message on WhatsApp" button. Handles the wa.me
/// handoff (§5.7) and shows the reach-out confirmation (S13) on app resume.
mixin MessageHandoffMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T>, WidgetsBindingObserver {
  Contact? _pendingContact;
  DateTime? _launchedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _maybeConfirm();
    }
  }

  Future<void> startMessage(
    Contact contact, {
    bool prefillTemplate = true,
    String? templateOverride,
  }) async {
    final launcher = ref.read(whatsappLauncherProvider);
    if (!launcher.canMessage(contact.phoneE164)) return;

    final settings = await ref.read(databaseProvider).getSettings();
    String? template;
    if (templateOverride != null) {
      // An explicit template choice always wins over the global auto-prefill
      // setting. The setting only controls automatic suggestions.
      template = templateOverride;
    } else if (prefillTemplate && settings.prefillStarter) {
      final groups =
          await ref.read(repositoryProvider).groupsForContact(contact.id);
      template = await _resolveTemplate(groups.map((g) => g.id).toList());
    }

    final ok = await launcher.launch(
      phoneE164: contact.phoneE164,
      displayName: contact.displayName,
      template: template,
    );
    if (ok) {
      _pendingContact = contact;
      _launchedAt = DateTime.now();
    }
  }

  Future<String?> _resolveTemplate(List<int> groupIds) async {
    final repo = ref.read(repositoryProvider);
    // group-specific (random pick) → global default
    for (final gid in groupIds) {
      final t = await repo.templatesFor(gid);
      if (t.isNotEmpty) {
        t.shuffle();
        return t.first.body;
      }
    }
    final defaults = await repo.templatesFor(null);
    if (defaults.isEmpty) return null;
    defaults.shuffle();
    return defaults.first.body;
  }

  Future<void> _maybeConfirm() async {
    final contact = _pendingContact;
    final launchedAt = _launchedAt;
    if (contact == null || launchedAt == null) return;
    if (DateTime.now().difference(launchedAt) >
        DouuDefaults.confirmationResumeWindow) {
      _pendingContact = null;
      _launchedAt = null;
      return;
    }
    _pendingContact = null;
    _launchedAt = null;

    if (!mounted) return;
    final reached = await showModalBottomSheet<bool>(
      context: context,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Did you reach out to ${_firstName(contact.displayName)}?',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Not yet'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Yes, done'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (reached == true) {
      // §5.7 reached path: log, lastReachedAt, streaks, RAG, quest, win.
      await ref.read(questEngineProvider).markReached(contact.id);

      // Tier 4: check for streak milestone after the reach is recorded.
      // Tier 2: cancel the rescue notification — user has acted today.
      final notif = ref.read(notificationServiceProvider);
      final streak = await ref.read(databaseProvider).getGlobalStreak();
      await notif.notifyStreakMilestone(streak.currentStreak);
      await notif.cancelStreakRescue();
      await onReachConfirmed(contact);
    }
  }

  /// Feature screens can attach local completion semantics after the shared
  /// self-reported reach-out has been recorded.
  Future<void> onReachConfirmed(Contact contact) async {}

  String _firstName(String name) => name.trim().split(RegExp(r'\s+')).first;
}
