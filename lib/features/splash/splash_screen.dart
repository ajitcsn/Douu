import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers.dart';
import '../../shared/widgets/douu_states.dart';

/// S0 — Splash / Router. Initializes DB-backed settings and routes to
/// onboarding or hub. No flash of the wrong screen.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Object? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _route());
  }

  Future<void> _route() async {
    try {
      final db = ref.read(databaseProvider);
      final settings = await db.getSettings();
      if (!mounted) return;
      context.go(settings.onboardingDone ? '/hub' : '/onboarding/welcome');
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _error != null
          ? DouuError(
              message: "Couldn't start Douu. Please try again.",
              onAction: () {
                setState(() => _error = null);
                _route();
              },
            )
          : Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Douu',
                      style: Theme.of(context).textTheme.displaySmall),
                  const SizedBox(height: 24),
                  const DouuLoading(message: 'loading…'),
                ],
              ),
            ),
    );
  }
}
