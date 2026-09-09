import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/defaults.dart';
import '../../providers.dart';
import '../../shared/widgets/douu_states.dart';
import '../groups/contact_picker.dart';

/// S4 — Build Family. Creates the Family group on entry, teaches bulk-add.
/// Shown once during onboarding.
class FamilyOnboardingScreen extends ConsumerStatefulWidget {
  const FamilyOnboardingScreen({super.key});

  @override
  ConsumerState<FamilyOnboardingScreen> createState() =>
      _FamilyOnboardingScreenState();
}

class _FamilyOnboardingScreenState
    extends ConsumerState<FamilyOnboardingScreen> {
  int? _familyId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureFamily());
  }

  Future<void> _ensureFamily() async {
    final repo = ref.read(repositoryProvider);
    final existing = await repo.groupByName('Family');
    final id = existing?.id ??
        await repo.createGroup(
          name: 'Family',
          frequencyDays: DouuDefaults.familyFrequencyDays,
        );
    if (mounted) setState(() => _familyId = id);
  }

  Future<void> _submit(List<int> ids) async {
    final repo = ref.read(repositoryProvider);
    await repo.addMemberships(ids, _familyId!);
    await ref.read(healthServiceProvider).recomputeGroup(_familyId!);
    if (mounted) context.go('/onboarding/reminders');
  }

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(contactsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Add people to Family')),
      body: _familyId == null
          ? const DouuLoading()
          : contactsAsync.when(
              loading: () => const DouuLoading(),
              error: (e, _) =>
                  DouuError(message: "Couldn't load contacts.", onAction: () {}),
              data: (contacts) => Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Tap everyone who belongs, then add them all at once.',
                    ),
                  ),
                  Expanded(
                    child: ContactPicker(
                      contacts: contacts,
                      ctaLabelBuilder: (n) => 'Add $n to Family',
                      onSubmit: _submit,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
