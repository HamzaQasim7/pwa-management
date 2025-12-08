import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_shadows.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Modern Theme - 2025 Professional Standards
/// Bold, clean, accessible, professional
class ModernTheme {
  ModernTheme._();

  // ============================================================================
  // LIGHT THEME
  // ============================================================================
  
  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    
    return base.copyWith(
      // ========== COLOR SCHEME ==========
      colorScheme: const ColorScheme.light(
        // Primary colors
        primary: AppColors.emeraldGreen,
        onPrimary: Colors.white,
        primaryContainer: Color(0xFFD1FAE5), // Very light emerald
        onPrimaryContainer: AppColors.emeraldGreen,
        
        // Secondary colors
        secondary: AppColors.royalBlue,
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFFDBEAFE), // Very light blue
        onSecondaryContainer: AppColors.royalBlue,
        
        // Tertiary colors
        tertiary: AppColors.purple,
        onTertiary: Colors.white,
        tertiaryContainer: Color(0xFFEDE9FE), // Very light purple
        onTertiaryContainer: AppColors.purple,
        
        // Error colors
        error: AppColors.red,
        onError: Colors.white,
        errorContainer: Color(0xFFFEE2E2),
        onErrorContainer: AppColors.red,
        
        // Background colors
        background: AppColors.pageBackground,
        onBackground: AppColors.textPrimary,
        
        // Surface colors
        surface: AppColors.cardBackground,
        onSurface: AppColors.textPrimary,
        surfaceVariant: AppColors.hoverBackground,
        onSurfaceVariant: AppColors.textSecondary,
        
        // Outline
        outline: AppColors.borderColor,
        outlineVariant: AppColors.borderColor,
        
        // Shadow
        shadow: Colors.black,
        scrim: Colors.black54,
        
        // Inverse colors
        inverseSurface: AppColors.darkNavy,
        onInverseSurface: AppColors.darkTextPrimary,
        inversePrimary: AppColors.emeraldLight,
        
        // Surface tint (for elevation tinting)
        surfaceTint: Colors.transparent,
      ),
      
      // ========== SCAFFOLD BACKGROUND ==========
      scaffoldBackgroundColor: AppColors.pageBackground,
      
      // ========== CARD THEME ==========
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: AppColors.shadowDefault,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusCard,
          side: const BorderSide(
            color: AppColors.borderColor,
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),
      
      // ========== APP BAR THEME ==========
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.cardBackground,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleSpacing: AppSpacing.md,
        toolbarHeight: 64,
        titleTextStyle: AppTypography.h3(),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
          size: 24,
        ),
        actionsIconTheme: const IconThemeData(
          color: AppColors.textPrimary,
          size: 24,
        ),
      ),
      
      // ========== TEXT THEME ==========
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        // Display styles
        displayLarge: AppTypography.h1(),
        displayMedium: AppTypography.h2(),
        displaySmall: AppTypography.h3(),
        
        // Headline styles
        headlineLarge: AppTypography.h1(),
        headlineMedium: AppTypography.h2(),
        headlineSmall: AppTypography.h3(),
        
        // Title styles
        titleLarge: AppTypography.h3(),
        titleMedium: AppTypography.h4(),
        titleSmall: AppTypography.bodyBold(),
        
        // Body styles
        bodyLarge: AppTypography.bodyLarge(),
        bodyMedium: AppTypography.bodyRegular(),
        bodySmall: AppTypography.bodySmall(),
        
        // Label styles
        labelLarge: AppTypography.button(),
        labelMedium: AppTypography.label(),
        labelSmall: AppTypography.caption(),
      ),
      
      // ========== BUTTON THEMES ==========
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.emeraldGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: AppColors.shadowDefault,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPaddingH,
            vertical: AppSpacing.buttonPaddingV,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          ),
          textStyle: AppTypography.button(),
          minimumSize: const Size(64, 44),
        ).copyWith(
          // Hover state
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.hovered)) {
              return AppColors.emeraldLight;
            }
            if (states.contains(MaterialState.pressed)) {
              return AppColors.emeraldGreen;
            }
            return AppColors.emeraldGreen;
          }),
          // Elevation states
          elevation: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.hovered)) {
              return AppShadows.elevation2;
            }
            if (states.contains(MaterialState.pressed)) {
              return AppShadows.elevation1;
            }
            return AppShadows.elevation0;
          }),
        ),
      ),
      
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.emeraldGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPaddingH,
            vertical: AppSpacing.buttonPaddingV,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          ),
          textStyle: AppTypography.button(),
          minimumSize: const Size(64, 44),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.emeraldGreen,
          side: const BorderSide(
            color: AppColors.emeraldGreen,
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPaddingH,
            vertical: AppSpacing.buttonPaddingV,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          ),
          textStyle: AppTypography.button(),
          minimumSize: const Size(64, 44),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.emeraldGreen,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          ),
          textStyle: AppTypography.button(),
          minimumSize: const Size(44, 44),
        ),
      ),
      
      // ========== INPUT DECORATION THEME ==========
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
          borderSide: const BorderSide(
            color: AppColors.borderColor,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
          borderSide: const BorderSide(
            color: AppColors.borderColor,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
          borderSide: const BorderSide(
            color: AppColors.royalBlue,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
          borderSide: const BorderSide(
            color: AppColors.red,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
          borderSide: const BorderSide(
            color: AppColors.red,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        hintStyle: AppTypography.bodyRegular(color: AppColors.textPlaceholder),
        labelStyle: AppTypography.label(),
        floatingLabelStyle: AppTypography.label(color: AppColors.royalBlue),
        errorStyle: AppTypography.caption(color: AppColors.red),
      ),
      
      // ========== DIVIDER THEME ==========
      dividerTheme: const DividerThemeData(
        color: AppColors.borderColor,
        thickness: 1,
        space: 1,
      ),
      
      // ========== ICON THEME ==========
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
        size: 24,
      ),
      
      // ========== FLOATING ACTION BUTTON THEME ==========
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.emeraldGreen,
        foregroundColor: Colors.white,
        elevation: 4,
        hoverElevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      
      // ========== CHIP THEME ==========
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.hoverBackground,
        deleteIconColor: AppColors.textMuted,
        disabledColor: AppColors.borderColor,
        selectedColor: AppColors.emeraldGreen,
        secondarySelectedColor: AppColors.emeraldLight,
        padding: AppSpacing.paddingSM,
        labelStyle: AppTypography.bodySmall(),
        secondaryLabelStyle: AppTypography.bodySmall(color: Colors.white),
        brightness: Brightness.light,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
          side: const BorderSide(color: AppColors.borderColor),
        ),
      ),
      
      // ========== SNACK BAR THEME ==========
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkNavy,
        contentTextStyle: AppTypography.bodyRegular(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusMD,
        ),
        elevation: 4,
      ),
      
      // ========== DIALOG THEME ==========
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.cardBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusLG,
        ),
        titleTextStyle: AppTypography.h3(),
        contentTextStyle: AppTypography.bodyRegular(),
      ),
      
      // ========== BOTTOM SHEET THEME ==========
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.cardBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        showDragHandle: true,
        dragHandleColor: AppColors.borderColor,
      ),
      
      // ========== NAVIGATION BAR THEME ==========
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        height: 64,
        labelTextStyle: MaterialStateProperty.all(
          AppTypography.caption(),
        ),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(
              color: AppColors.emeraldGreen,
              size: 24,
            );
          }
          return const IconThemeData(
            color: AppColors.textMuted,
            size: 24,
          );
        }),
        indicatorColor: AppColors.emeraldGreen.withOpacity(0.1),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
        ),
      ),
      
      // ========== TAB BAR THEME ==========
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.emeraldGreen,
        unselectedLabelColor: AppColors.textMuted,
        labelStyle: AppTypography.bodyBold(),
        unselectedLabelStyle: AppTypography.bodyRegular(),
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(
            color: AppColors.emeraldGreen,
            width: 3,
          ),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: AppColors.borderColor,
      ),
      
      // ========== TOOLTIP THEME ==========
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.darkNavy,
          borderRadius: AppSpacing.borderRadiusSM,
        ),
        textStyle: AppTypography.caption(color: Colors.white),
        padding: AppSpacing.paddingSM,
        waitDuration: const Duration(milliseconds: 500),
      ),
      
      // ========== PROGRESS INDICATOR THEME ==========
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.emeraldGreen,
        linearTrackColor: AppColors.borderColor,
        circularTrackColor: AppColors.borderColor,
      ),
      
      // ========== SWITCH THEME ==========
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.white;
          }
          return AppColors.textMuted;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.emeraldGreen;
          }
          return AppColors.borderColor;
        }),
      ),
      
      // ========== CHECKBOX THEME ==========
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.emeraldGreen;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(Colors.white),
        side: const BorderSide(
          color: AppColors.borderColor,
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      
      // ========== RADIO THEME ==========
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.emeraldGreen;
          }
          return AppColors.borderColor;
        }),
      ),
      
      // ========== LIST TILE THEME ==========
      listTileTheme: ListTileThemeData(
        contentPadding: AppSpacing.paddingHorizontalMD,
        minLeadingWidth: 40,
        iconColor: AppColors.textPrimary,
        textColor: AppColors.textPrimary,
        titleTextStyle: AppTypography.bodyLarge(),
        subtitleTextStyle: AppTypography.bodySmall(),
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusMD,
        ),
      ),
    );
  }

  // ============================================================================
  // DARK THEME
  // ============================================================================
  
  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    
    return base.copyWith(
      // Similar structure to light theme but with dark colors
      colorScheme: const ColorScheme.dark(
        primary: AppColors.emeraldLight,
        onPrimary: AppColors.darkNavy,
        primaryContainer: AppColors.emeraldGreen,
        onPrimaryContainer: Colors.white,
        
        secondary: AppColors.royalBlueLight,
        onSecondary: AppColors.darkNavy,
        secondaryContainer: AppColors.royalBlue,
        onSecondaryContainer: Colors.white,
        
        tertiary: AppColors.purpleLight,
        onTertiary: AppColors.darkNavy,
        
        error: AppColors.redLight,
        onError: AppColors.darkNavy,
        
        background: AppColors.darkPageBackground,
        onBackground: AppColors.darkTextPrimary,
        
        surface: AppColors.darkCardBackground,
        onSurface: AppColors.darkTextPrimary,
        surfaceVariant: AppColors.darkHoverBackground,
        onSurfaceVariant: AppColors.darkTextSecondary,
        
        outline: AppColors.darkBorderColor,
        
        shadow: Colors.black,
        inverseSurface: AppColors.cardBackground,
        onInverseSurface: AppColors.textPrimary,
        
        surfaceTint: Colors.transparent,
      ),
      
      scaffoldBackgroundColor: AppColors.darkPageBackground,
      
      // Rest of the theme configuration similar to light theme
      // but with dark color variants...
      
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge: AppTypography.h1Dark(),
        headlineLarge: AppTypography.h1Dark(),
        headlineMedium: AppTypography.h2Dark(),
        bodyLarge: AppTypography.bodyLargeDark(),
        bodyMedium: AppTypography.bodyRegularDark(),
        bodySmall: AppTypography.bodySmallDark(),
      ),
      
      cardTheme: CardThemeData(
        color: AppColors.darkCardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusCard,
          side: BorderSide(
            color: AppColors.darkBorderColor.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkCardBackground,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        titleTextStyle: AppTypography.h3Dark(),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
    );
  }
}

