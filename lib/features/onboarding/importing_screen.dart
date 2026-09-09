import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/services/contacts_import.dart';
import '../../providers.dart';
import '../../shared/widgets/douu_states.dart';

/// S3 — Importing. Reads + normalizes contacts with progress (§5.1).
class ImportingScreen extends ConsumerStatefulWidget {
  const ImportingScreen({super.key});

  @override
  ConsumerState<ImportingScreen> createState() => _ImportingScreenState();
}

class _ImportingScreenState extends ConsumerState<ImportingScreen> {
  int _done = 0;
  int _total = 0;
  Object? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _import());
  }

  Future<void> _import() async {
    setState(() => _error = null);
    try {
      final importer = ContactsImporter(ref.read(databaseProvider));
      final count = await importer.importAll(onProgress: (done, total) {
        if (mounted) {
          setState(() {
            _done = done;
            _total = total;
          });
        }
      });
      if (!mounted) return;
      // Empty device → skip Family build, go straight to done.
      context.go(count == 0 ? '/onboarding/done' : '/onboarding/family');
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = _total == 0 ? null : _done / _total;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _error != null
              ? DouuError(
                  message: "Couldn't read contacts.",
                  onAction: _import,
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Importing your contacts',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 24),
                    LinearProgressIndicator(value: progress),
                    const SizedBox(height: 8),
                    Text(_total == 0 ? '' : '$_done / $_total'),
                    const SizedBox(height: 24),
                    const Text('Tidying up phone numbers…'),
                  ],
                ),
        ),
      ),
    );
  }
}
