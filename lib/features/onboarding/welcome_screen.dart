import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// S1 — Welcome. Value + privacy promise. No permission requested here.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text('Stay close to the people who matter.',
                  style: text.headlineMedium),
              const SizedBox(height: 24),
              Text(
                'Douu reminds you who to reach out to, and opens the '
                'WhatsApp chat for you.',
                style: text.bodyLarge,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Text('🔒  '),
                  Expanded(
                    child: Text('Everything stays on this phone. Always.',
                        style: text.titleMedium),
                  ),
                ],
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => context.push('/onboarding/contacts'),
                child: const Text('Get started'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
