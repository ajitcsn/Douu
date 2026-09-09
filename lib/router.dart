import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/contact/contact_detail_screen.dart';
import 'features/groups/bulk_add_screen.dart';
import 'features/groups/create_group_sheet.dart';
import 'features/groups/group_detail_screen.dart';
import 'features/groups/sort_contacts_screen.dart';
import 'features/hub/hub_screen.dart';
import 'features/insights/insights_screen.dart';
import 'features/onboarding/contacts_permission_screen.dart';
import 'features/onboarding/done_screen.dart';
import 'features/onboarding/family_screen.dart';
import 'features/onboarding/importing_screen.dart';
import 'features/onboarding/reminders_screen.dart';
import 'features/onboarding/welcome_screen.dart';
import 'features/quest/quest_archive_screen.dart';
import 'features/quest/quest_screen.dart';
import 'features/quest/side_quest_screen.dart';
import 'features/settings/backup_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/splash/splash_screen.dart';

/// Navigation map (§6).
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
    GoRoute(
        path: '/onboarding/welcome', builder: (_, __) => const WelcomeScreen()),
    GoRoute(
        path: '/onboarding/contacts',
        builder: (_, __) => const ContactsPermissionScreen()),
    GoRoute(
        path: '/onboarding/importing',
        builder: (_, __) => const ImportingScreen()),
    GoRoute(
        path: '/onboarding/family',
        builder: (_, __) => const FamilyOnboardingScreen()),
    GoRoute(
        path: '/onboarding/reminders',
        builder: (_, __) => const RemindersScreen()),
    GoRoute(path: '/onboarding/done', builder: (_, __) => const DoneScreen()),
    GoRoute(path: '/hub', builder: (_, __) => const HubScreen()),
    GoRoute(path: '/groups/new', builder: (_, __) => const CreateGroupScreen()),
    GoRoute(
      path: '/groups/:id',
      builder: (_, s) =>
          GroupDetailScreen(groupId: int.parse(s.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/groups/:id/add',
      builder: (_, s) =>
          BulkAddScreen(groupId: int.parse(s.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/contacts/:id',
      builder: (_, s) =>
          ContactDetailScreen(contactId: int.parse(s.pathParameters['id']!)),
    ),
    GoRoute(path: '/quest', builder: (_, __) => const QuestScreen()),
    GoRoute(
        path: '/quest/archive', builder: (_, __) => const QuestArchiveScreen()),
    GoRoute(path: '/side-quest', builder: (_, __) => const SideQuestScreen()),
    GoRoute(
      path: '/sort-contacts',
      builder: (_, state) => SortContactsScreen(
        initialContactId:
            int.tryParse(state.uri.queryParameters['contactId'] ?? ''),
        initialGroupId:
            int.tryParse(state.uri.queryParameters['groupId'] ?? ''),
      ),
    ),
    GoRoute(path: '/insights', builder: (_, __) => const InsightsScreen()),
    GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
    GoRoute(path: '/settings/backup', builder: (_, __) => const BackupScreen()),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(child: Text('Route not found: ${state.uri}')),
  ),
);
