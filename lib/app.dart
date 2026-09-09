import 'package:flutter/material.dart';

import 'config/theme.dart';
import 'router.dart';

class DouuApp extends StatelessWidget {
  const DouuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Douu',
      debugShowCheckedModeBanner: false,
      theme: DouuTheme.light(),
      // Force light — the palette is designed for a light background.
      themeMode: ThemeMode.light,
      routerConfig: appRouter,
    );
  }
}
