import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Modern Typography System - 2025 Standards
/// Clear hierarchy, readable, professional
class AppTypography {
  AppTypography._();

  // ============================================================================
  // FONT FAMILIES
  // ============================================================================
  
  /// Primary font family - Inter (clean, modern, professional)
  static String get primaryFont => GoogleFonts.inter().fontFamily!;
  
  /// Numbers font - Roboto Mono (tabular figures)
  static String get numbersFont => GoogleFonts.robotoMono().fontFamily!;
  
  /// Headings font - Poppins (bold, impactful)
  static String get headingsFont => GoogleFonts.poppins().fontFamily!;

  // ============================================================================
  // FONT WEIGHTS
  // ============================================================================
  
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;

  // ============================================================================
  // HEADLINES - Light Mode
  // ============================================================================
  
  /// H1 - 32px, 700 weight, primary color
  static TextStyle h1({Color? color}) => GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: bold,
        color: color ?? AppColors.textPrimary,
        height: 1.2,
        letterSpacing: -0.5,
      );
  
  /// H2 - 24px, 600 weight, primary color
  static TextStyle h2({Color? color}) => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: semiBold,
        color: color ?? AppColors.textPrimary,
        height: 1.3,
        letterSpacing: -0.3,
      );
  
  /// H3 - 20px, 600 weight, secondary color
  static TextStyle h3({Color? color}) => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: semiBold,
        color: color ?? AppColors.deepNavy,
        height: 1.4,
        letterSpacing: -0.2,
      );
  
  /// H4 - 18px, 600 weight
  static TextStyle h4({Color? color}) => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: semiBold,
        color: color ?? AppColors.textPrimary,
        height: 1.4,
      );

  // ============================================================================
  // BODY TEXT - Light Mode
  // ============================================================================
  
  /// Body Large - 16px, 400 weight
  static TextStyle bodyLarge({Color? color}) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: regular,
        color: color ?? AppColors.textSecondary,
        height: 1.5,
      );
  
  /// Body Regular - 14px, 400 weight
  static TextStyle bodyRegular({Color? color}) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: regular,
        color: color ?? AppColors.textTertiary,
        height: 1.5,
      );
  
  /// Body Small - 12px, 400 weight
  static TextStyle bodySmall({Color? color}) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: regular,
        color: color ?? AppColors.textMuted,
        height: 1.5,
      );
  
  /// Body Bold - 14px, 700 weight
  static TextStyle bodyBold({Color? color}) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: bold,
        color: color ?? AppColors.textPrimary,
        height: 1.5,
      );

  // ============================================================================
  // NUMBERS & METRICS
  // ============================================================================
  
  /// Large number - 28px, bold, tabular figures (reduced from 36px to prevent overflow)
  static TextStyle numberLarge({Color? color}) => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: bold,
        color: color ?? AppColors.textPrimary,
        height: 1.1,
        fontFeatures: [const FontFeature.tabularFigures()],
      );
  
  /// Medium number - 24px, bold, tabular figures
  static TextStyle numberMedium({Color? color}) => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: bold,
        color: color ?? AppColors.textPrimary,
        height: 1.3,
        fontFeatures: [const FontFeature.tabularFigures()],
      );
  
  /// Small number - 16px, semi-bold, tabular figures
  static TextStyle numberSmall({Color? color}) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: semiBold,
        color: color ?? AppColors.textPrimary,
        height: 1.4,
        fontFeatures: [const FontFeature.tabularFigures()],
      );

  // ============================================================================
  // LABELS & CAPTIONS
  // ============================================================================
  
  /// Label - 12px, medium weight, muted (reduced from 14px)
  static TextStyle label({Color? color}) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: medium,
        color: color ?? AppColors.textMuted,
        height: 1.3,
        letterSpacing: 0.1,
      );
  
  /// Caption - 12px, regular weight, muted
  static TextStyle caption({Color? color}) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: regular,
        color: color ?? AppColors.textMuted,
        height: 1.4,
      );
  
  /// Overline - 10px, medium weight, uppercase
  static TextStyle overline({Color? color}) => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: medium,
        color: color ?? AppColors.textMuted,
        height: 1.6,
        letterSpacing: 1.5,
      );

  // ============================================================================
  // BUTTONS & LINKS
  // ============================================================================
  
  /// Button text - 14px, bold
  static TextStyle button({Color? color}) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: semiBold,
        color: color ?? Colors.white,
        height: 1.2,
        letterSpacing: 0.5,
      );
  
  /// Link text - 14px, medium, with underline
  static TextStyle link({Color? color}) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: medium,
        color: color ?? AppColors.royalBlue,
        height: 1.5,
        decoration: TextDecoration.underline,
      );

  // ============================================================================
  // TRENDS & INDICATORS
  // ============================================================================
  
  /// Positive trend - 12px, bold, green
  static TextStyle trendPositive() => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: semiBold,
        color: AppColors.emeraldGreen,
        height: 1.2,
      );
  
  /// Negative trend - 12px, bold, red
  static TextStyle trendNegative() => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: semiBold,
        color: AppColors.red,
        height: 1.2,
      );

  // ============================================================================
  // DARK MODE VARIANTS
  // ============================================================================
  
  /// H1 Dark mode
  static TextStyle h1Dark() => h1(color: AppColors.darkTextPrimary);
  
  /// H2 Dark mode
  static TextStyle h2Dark() => h2(color: AppColors.darkTextPrimary);
  
  /// H3 Dark mode
  static TextStyle h3Dark() => h3(color: AppColors.darkTextPrimary);
  
  /// Body Large Dark mode
  static TextStyle bodyLargeDark() => bodyLarge(color: AppColors.darkTextSecondary);
  
  /// Body Regular Dark mode
  static TextStyle bodyRegularDark() => bodyRegular(color: AppColors.darkTextTertiary);
  
  /// Body Small Dark mode
  static TextStyle bodySmallDark() => bodySmall(color: AppColors.darkTextMuted);

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================
  
  /// Get text style for context (light/dark mode aware)
  static TextStyle getHeadline1(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? h1Dark() : h1();
  }
  
  /// Get body style for context
  static TextStyle getBodyRegular(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? bodyRegularDark() : bodyRegular();
  }
}

