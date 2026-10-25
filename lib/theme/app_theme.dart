import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dumb-Ways / Happy-Tree-Friends candy cartoon palette.
class BuddyColors {
  static const skyTop = Color(0xFFFFE08A);
  static const skyBottom = Color(0xFFFF9ECF);
  static const mint = Color(0xFF7DFFB3);
  static const bubblegum = Color(0xFFFF6BB5);
  static const grape = Color(0xFF7B5CFF);
  static const lemon = Color(0xFFFFE566);
  static const ink = Color(0xFF1A1028);
  static const cream = Color(0xFFFFF6E8);
  static const bruise = Color(0xFF5C4D7A);
}

class AppTheme {
  static ThemeData light() {
    final display = GoogleFonts.fredoka(
      fontWeight: FontWeight.w700,
      color: BuddyColors.ink,
      letterSpacing: -0.4,
    );
    final body = GoogleFonts.nunito(
      color: BuddyColors.ink,
      height: 1.3,
      fontWeight: FontWeight.w600,
    );

    final scheme = ColorScheme.fromSeed(
      seedColor: BuddyColors.bubblegum,
      brightness: Brightness.light,
      primary: BuddyColors.bubblegum,
      secondary: BuddyColors.grape,
      tertiary: BuddyColors.mint,
      surface: BuddyColors.cream,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: BuddyColors.ink,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: BuddyColors.cream,
      textTheme: TextTheme(
        displayLarge: display.copyWith(fontSize: 40),
        displayMedium: display.copyWith(fontSize: 32),
        headlineLarge: display.copyWith(fontSize: 28),
        headlineMedium: display.copyWith(fontSize: 24),
        headlineSmall: display.copyWith(fontSize: 20),
        titleLarge: display.copyWith(fontSize: 18),
        titleMedium: body.copyWith(fontSize: 16, fontWeight: FontWeight.w800),
        titleSmall: body.copyWith(fontSize: 14, fontWeight: FontWeight.w800),
        bodyLarge: body.copyWith(fontSize: 16),
        bodyMedium: body.copyWith(fontSize: 14),
        bodySmall: body.copyWith(fontSize: 12, color: BuddyColors.bruise),
        labelLarge: body.copyWith(fontSize: 16, fontWeight: FontWeight.w800),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: BuddyColors.ink,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: display.copyWith(fontSize: 22),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: BuddyColors.bubblegum,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          textStyle: GoogleFonts.fredoka(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: const BorderSide(color: BuddyColors.ink, width: 3),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: BuddyColors.bruise,
          textStyle: GoogleFonts.nunito(fontWeight: FontWeight.w800),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: BuddyColors.lemon,
        labelStyle: GoogleFonts.nunito(
          fontWeight: FontWeight.w800,
          color: BuddyColors.ink,
        ),
        side: const BorderSide(color: BuddyColors.ink, width: 2.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: BuddyColors.cream,
        indicatorColor: BuddyColors.mint,
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 12),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? BuddyColors.ink : BuddyColors.bruise,
            size: 26,
          );
        }),
        elevation: 0,
        height: 72,
      ),
      cardTheme: CardThemeData(
        color: BuddyColors.cream,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: BuddyColors.ink, width: 3),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: BuddyColors.ink,
        contentTextStyle: GoogleFonts.nunito(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
