import 'package:flutter/material.dart';

/// Douu visual language: calm, trustworthy, relationship-forward.
/// Soft blue palette — safe and warm without being clinical.
/// Red is reserved for the RAG health dot only (§5.5).
class DouuTheme {
  DouuTheme._();

  // ── Brand palette ──────────────────────────────────────────────────
  static const Color seed = Color(0xFF5BA4CF); // soft sky blue
  static const Color blueLight = Color(0xFFDCEEF8); // pale wash
  static const Color blueMid = Color(0xFF8EC5E8); // mid blue

  // Light-mode surface colours — white scaffold, clearly-blue cards
  static const Color _lightBg = Colors.white;
  static const Color _lightCard = Color(0xFFDCEEF8);
  static const Color _lightCardBorder = Color(0xFFBDD9F0);

  // Dark-mode surface colours — deep navy, NOT near-black
  static const Color _darkSurface = Color(0xFF0D1B2A);
  static const Color _darkCard = Color(0xFF1A3250);
  static const Color _darkCardBorder = Color(0xFF254A6E);

  // Streak gradient — vivid so momentum pops on the hub
  static const Color streakOrange = Color(0xFFFF8C42);
  static const Color streakGold = Color(0xFFFFD166);
  static const Color streakBlue = Color(0xFF5BA4CF);

  // ── RAG (health dots only) ─────────────────────────────────────────
  static const Color ragGreen = Color(0xFF2F9E44);
  static const Color ragAmber = Color(0xFFF59F00);
  static const Color ragRed = Color(0xFFE03131);
  static const Color ragGrey = Color(0xFFADB5BD);

  // ── Themes ────────────────────────────────────────────────────────

  static ThemeData light() {
    const scheme = ColorScheme.light(
      primary: seed,
      onPrimary: Colors.white,
      primaryContainer: blueLight,
      onPrimaryContainer: Color(0xFF1A3A54),
      secondary: seed,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFD6EAF8),
      onSecondaryContainer: Color(0xFF1A3A54),
      surface: _lightBg,
      onSurface: Color(0xFF1A2E42),
      surfaceContainerHighest: _lightCard,
      outline: Color(0xFF8EC5E8),
      outlineVariant: _lightCardBorder,
    );
    return _base(scheme, cardColor: _lightCard, cardBorder: _lightCardBorder);
  }

  static ThemeData dark() {
    const scheme = ColorScheme.dark(
      primary: blueMid,
      onPrimary: Color(0xFF0D1B2A),
      primaryContainer: Color(0xFF1A3A54),
      onPrimaryContainer: blueLight,
      secondary: blueMid,
      onSecondary: Color(0xFF0D1B2A),
      secondaryContainer: Color(0xFF1A3250),
      onSecondaryContainer: blueLight,
      surface: _darkSurface,
      onSurface: Color(0xFFDCEEF8),
      surfaceContainerHighest: _darkCard,
      outline: Color(0xFF254A6E),
      outlineVariant: Color(0xFF1F3D5C),
    );
    return _base(scheme, cardColor: _darkCard, cardBorder: _darkCardBorder);
  }

  static ThemeData _base(
    ColorScheme scheme, {
    required Color cardColor,
    required Color cardBorder,
  }) {
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      visualDensity: VisualDensity.comfortable,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: scheme.onSurface,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 6),
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: cardBorder),
        ),
      ),
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: DividerThemeData(color: cardBorder),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          side: BorderSide(color: scheme.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHighest,
        side: BorderSide(color: cardBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderSide: BorderSide(color: cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        filled: true,
        fillColor: cardColor,
      ),
    );
  }

  static Color ragColor(String rag) {
    switch (rag) {
      case 'green':
        return ragGreen;
      case 'amber':
        return ragAmber;
      case 'red':
        return ragRed;
      default:
        return ragGrey;
    }
  }
}
