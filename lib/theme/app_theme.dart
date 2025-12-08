import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/responsive_layout.dart';

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
    cardTheme: CardThemeData(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(0), // Let screens control margins
    ),
    // Enhanced button themes for web
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
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
    cardTheme: CardThemeData(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(0),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}

/// Responsive text styles
class ResponsiveTextStyles {
  ResponsiveTextStyles._();

  /// Large headline - for main page titles
  static TextStyle headlineLarge(BuildContext context) {
    return Theme.of(context).textTheme.headlineLarge!.copyWith(
          fontSize: ResponsiveLayout.value(
            context: context,
            mobile: 28,
            tablet: 32,
            desktop: 36,
            largeDesktop: 40,
          ),
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        );
  }

  /// Medium headline - for section titles
  static TextStyle headlineMedium(BuildContext context) {
    return Theme.of(context).textTheme.headlineMedium!.copyWith(
          fontSize: ResponsiveLayout.headingSize(context),
          fontWeight: FontWeight.bold,
          letterSpacing: -0.3,
        );
  }

  /// Small headline - for card titles
  static TextStyle headlineSmall(BuildContext context) {
    return Theme.of(context).textTheme.headlineSmall!.copyWith(
          fontSize: ResponsiveLayout.subheadingSize(context),
          fontWeight: FontWeight.w600,
        );
  }

  /// Body large - for emphasized body text
  static TextStyle bodyLarge(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge!.copyWith(
          fontSize: ResponsiveLayout.bodyTextSize(context),
          fontWeight: FontWeight.w500,
        );
  }

  /// Body medium - for regular body text
  static TextStyle bodyMedium(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
          fontSize: ResponsiveLayout.bodyTextSize(context),
        );
  }

  /// Body small - for secondary text
  static TextStyle bodySmall(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall!.copyWith(
          fontSize: ResponsiveLayout.value(
            context: context,
            mobile: 12,
            tablet: 13,
            desktop: 14,
          ),
        );
  }

  /// Label large - for buttons
  static TextStyle labelLarge(BuildContext context) {
    return Theme.of(context).textTheme.labelLarge!.copyWith(
          fontSize: ResponsiveLayout.bodyTextSize(context),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        );
  }
}

/// Legacy support - maintained for backward compatibility
TextStyle headlineLarge(BuildContext context) =>
    ResponsiveTextStyles.headlineLarge(context);

TextStyle headlineMedium(BuildContext context) =>
    ResponsiveTextStyles.headlineMedium(context);
