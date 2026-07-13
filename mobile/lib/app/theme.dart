import 'package:flutter/material.dart';

/// Brand palette. The hero gradient and accent are shared by the
/// dashboard header, ticket screen and charts so the app reads as one
/// designed system instead of stock Material.
abstract final class AppBrand {
  static const teal = Color(0xFF105C58);
  static const tealBright = Color(0xFF17847E);
  static const ink = Color(0xFF0A1E28);
  static const amber = Color(0xFFFFB454);
  static const surface = Color(0xFFF4F6F5);

  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [tealBright, teal, ink],
    stops: [0.0, 0.45, 1.0],
  );
}

ThemeData buildAppTheme() {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: AppBrand.teal,
        brightness: Brightness.light,
      ).copyWith(
        primary: AppBrand.teal,
        secondary: AppBrand.amber,
        surface: Colors.white,
      );

  const display = 'Sora';

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: AppBrand.surface,
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontFamily: display,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.6,
      ),
      headlineSmall: TextStyle(
        fontFamily: display,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
      titleLarge: TextStyle(
        fontFamily: display,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      titleMedium: TextStyle(
        fontFamily: display,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
      ),
      labelLarge: TextStyle(fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(height: 1.4),
    ),
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: AppBrand.surface,
      foregroundColor: scheme.onSurface,
      titleTextStyle: TextStyle(
        fontFamily: display,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: scheme.onSurface,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.primary, width: 1.6),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        backgroundColor: AppBrand.teal,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: BorderSide(color: scheme.primary.withValues(alpha: 0.4)),
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: scheme.primary.withValues(alpha: 0.12),
      elevation: 0,
      height: 68,
      labelTextStyle: const WidgetStatePropertyAll(
        TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
      ),
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
    ),
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      iconColor: scheme.primary,
    ),
    dividerTheme: DividerThemeData(
      color: Colors.black.withValues(alpha: 0.06),
      space: 1,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
      },
    ),
  );
}
