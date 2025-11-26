import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  static const Color feedPrimary = Color(0xFF4CAF50);
  static const Color feedSecondary = Color(0xFF2196F3);
  static const Color medPrimary = Color(0xFF0288D1);
  static const Color medSecondary = Color(0xFF00BCD4);
  static const Color expired = Color(0xFFF44336);
  static const Color expiringSoon = Color(0xFFFF9800);
  static const Color lowStock = Color(0xFFFFC107);
  static const Color goodStock = Color(0xFF4CAF50);
}

ThemeData buildLightTheme() {
  final base = ThemeData.light(useMaterial3: true);
  return base.copyWith(
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.feedPrimary,
      secondary: AppColors.feedSecondary,
      surfaceTint: Colors.white,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(
      base.textTheme,
    ).copyWith(
      bodyMedium: GoogleFonts.roboto(textStyle: base.textTheme.bodyMedium),
      bodySmall: GoogleFonts.roboto(textStyle: base.textTheme.bodySmall),
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
    ),
    scaffoldBackgroundColor: const Color(0xFFF6F8FB),
    inputDecorationTheme: base.inputDecorationTheme.copyWith(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    ),
    cardTheme: CardTheme(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );
}

ThemeData buildDarkTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.medPrimary,
      secondary: AppColors.medSecondary,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),
    cardTheme: CardTheme(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );
}

TextStyle headlineLarge(BuildContext context) =>
    Theme.of(context).textTheme.headlineLarge!.copyWith(
          fontSize: 32,
          fontWeight: FontWeight.bold,
        );

TextStyle headlineMedium(BuildContext context) =>
    Theme.of(context).textTheme.headlineMedium!.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        );
