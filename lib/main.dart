import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/db/database.dart';
import 'domain/services/background_refresh.dart';
import 'domain/services/notification_service.dart';
import 'providers.dart';
import 'router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create the single database instance and seed-on-first-run runs via the
  // Drift migration strategy (database.dart). Timezone + notifications init
  // lazily on first use in NotificationService.
  final db = AppDatabase();
  final notifications = NotificationService(onRoute: appRouter.go);
  await BackgroundRefresh.initialize();

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        notificationServiceProvider.overrideWithValue(notifications),
      ],
      child: const DouuApp(),
    ),
  );
}
