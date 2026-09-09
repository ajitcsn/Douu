import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

/// S2 — Contacts permission rationale, shown BEFORE the system dialog.
class ContactsPermissionScreen extends StatefulWidget {
  const ContactsPermissionScreen({super.key});

  @override
  State<ContactsPermissionScreen> createState() =>
      _ContactsPermissionScreenState();
}

class _ContactsPermissionScreenState extends State<ContactsPermissionScreen> {
  bool _denied = false;
  bool _permanentlyDenied = false;

  Future<void> _request() async {
    final status = await Permission.contacts.request();
    if (!mounted) return;
    if (status.isGranted || status.isLimited) {
      context.go('/onboarding/importing');
    } else {
      setState(() {
        _denied = true;
        _permanentlyDenied = status.isPermanentlyDenied;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Douu needs your contacts', style: text.headlineSmall),
              const SizedBox(height: 16),
              Text(
                'To show your people so you can sort them into groups and get '
                'reminders to stay in touch.',
                style: text.bodyLarge,
              ),
              const SizedBox(height: 16),
              Text('Your contacts never leave this device.',
                  style: text.titleMedium),
              if (_denied) ...[
                const SizedBox(height: 24),
                Text(
                  "Douu can't show contacts without permission. You can still "
                  'add people later, or enable it in system settings.',
                  style: text.bodyMedium
                      ?.copyWith(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const Spacer(),
              if (!_denied) ...[
                FilledButton(
                    onPressed: _request,
                    child: const Text('Allow contacts')),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => setState(() => _denied = true),
                  child: const Text('Not now'),
                ),
              ] else ...[
                FilledButton(
                  onPressed: () => _permanentlyDenied
                      ? openAppSettings()
                      : _request(),
                  child: Text(_permanentlyDenied
                      ? 'Open settings'
                      : 'Try again'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.go('/onboarding/done'),
                  child: const Text('Continue without'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
