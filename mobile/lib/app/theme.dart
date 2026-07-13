import 'package:flutter/material.dart';

/// Brand palette — dark-first. Surfaces step up from [bg] to [surfaceHigh];
/// [mint] is the single interactive accent, [amber] the warm highlight.
/// Chart marks use the darker, contrast-validated [chartTeal]/[chartAmber].
abstract final class AppBrand {
  // Surfaces
  static const bg = Color(0xFF0B1118);
  static const surface = Color(0xFF131C26);
  static const surfaceHigh = Color(0xFF1A2530);
  static const line = Color(0x14FFFFFF); // white 8%

  // Accents
  static const mint = Color(0xFF2DD4BF);
  static const amber = Color(0xFFFFB454);
  static const ink = Color(0xFF0A1E28);
  static const teal = Color(0xFF105C58);
  static const tealBright = Color(0xFF17847E);

  // Chart data marks (validated against the dark surface)
  static const chartTeal = Color(0xFF0FA695);
  static const chartAmber = Color(0xFFD97706);

  // Status
  static const ok = mint;
  static const warn = amber;
  static const danger = Color(0xFFFF6B6B);

  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [tealBright, teal, bg],
    stops: [0.0, 0.42, 1.0],
  );
}

ThemeData buildAppTheme() {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: AppBrand.teal,
        brightness: Brightness.dark,
      ).copyWith(
        primary: AppBrand.mint,
        onPrimary: AppBrand.ink,
        secondary: AppBrand.amber,
        onSecondary: AppBrand.ink,
        surface: AppBrand.surface,
        onSurface: const Color(0xFFE8EEF2),
        outline: AppBrand.line,
      );

  const display = 'Sora';

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: AppBrand.bg,
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
      backgroundColor: AppBrand.bg,
      foregroundColor: scheme.onSurface,
      titleTextStyle: TextStyle(
        fontFamily: display,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: scheme.onSurface,
      ),
    ),
    cardTheme: const CardThemeData(
      elevation: 0,
      color: AppBrand.surface,
      margin: EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
        side: BorderSide(color: AppBrand.line),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppBrand.surfaceHigh,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppBrand.mint, width: 1.6),
      ),
      labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.65)),
      prefixIconColor: Colors.white.withValues(alpha: 0.55),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        backgroundColor: AppBrand.mint,
        foregroundColor: AppBrand.ink,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        foregroundColor: AppBrand.mint,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: BorderSide(color: AppBrand.mint.withValues(alpha: 0.45)),
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppBrand.mint,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF0E161F),
      indicatorColor: AppBrand.mint.withValues(alpha: 0.16),
      elevation: 0,
      height: 68,
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? AppBrand.mint
              : Colors.white.withValues(alpha: 0.6),
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: states.contains(WidgetState.selected)
              ? AppBrand.mint
              : Colors.white.withValues(alpha: 0.6),
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppBrand.surfaceHigh,
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    chipTheme: ChipThemeData(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(999)),
        side: BorderSide(color: AppBrand.line),
      ),
      backgroundColor: AppBrand.surface,
      labelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
    ),
    listTileTheme: const ListTileThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
      iconColor: AppBrand.mint,
    ),
    dividerTheme: const DividerThemeData(color: AppBrand.line, space: 1),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppBrand.mint,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 2,
      backgroundColor: AppBrand.mint,
      foregroundColor: AppBrand.ink,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
      },
    ),
  );
}
