import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Modern Shadow & Elevation System - 2025 Standards
/// Subtle, purposeful depth
class AppShadows {
  AppShadows._();

  // ============================================================================
  // CARD SHADOWS
  // ============================================================================
  
  /// Default card shadow - Subtle, 1px offset
  static List<BoxShadow> get cardDefault => [
        BoxShadow(
          color: AppColors.shadowDefault,
          offset: const Offset(0, 1),
          blurRadius: 3,
          spreadRadius: 0,
        ),
      ];
  
  /// Card hover shadow - Elevated, more visible
  static List<BoxShadow> get cardHover => [
        BoxShadow(
          color: AppColors.shadowHover,
          offset: const Offset(0, 8),
          blurRadius: 16,
          spreadRadius: 0,
        ),
      ];
  
  /// Card active shadow - Pressed state
  static List<BoxShadow> get cardActive => [
        BoxShadow(
          color: AppColors.shadowDefault,
          offset: const Offset(0, 2),
          blurRadius: 4,
          spreadRadius: 0,
        ),
      ];

  // ============================================================================
  // BUTTON SHADOWS
  // ============================================================================
  
  /// Primary button shadow
  static List<BoxShadow> get buttonPrimary => [
        BoxShadow(
          color: AppColors.shadowDefault,
          offset: const Offset(0, 2),
          blurRadius: 4,
          spreadRadius: 0,
        ),
      ];
  
  /// Button hover shadow
  static List<BoxShadow> get buttonHover => [
        BoxShadow(
          color: AppColors.shadowHover,
          offset: const Offset(0, 4),
          blurRadius: 8,
          spreadRadius: 0,
        ),
      ];

  // ============================================================================
  // FOCUS SHADOWS (Rings)
  // ============================================================================
  
  /// Focus ring - Royal blue
  static List<BoxShadow> get focusRing => [
        BoxShadow(
          color: AppColors.shadowFocus,
          offset: const Offset(0, 0),
          blurRadius: 0,
          spreadRadius: 3,
        ),
      ];
  
  /// Focus ring with color
  static List<BoxShadow> focusRingColored(Color color) => [
        BoxShadow(
          color: color.withOpacity(0.1),
          offset: const Offset(0, 0),
          blurRadius: 0,
          spreadRadius: 3,
        ),
      ];

  // ============================================================================
  // SIDEBAR SHADOWS
  // ============================================================================
  
  /// Active nav item shadow - Green glow
  static List<BoxShadow> get sidebarActiveGlow => [
        BoxShadow(
          color: AppColors.emeraldGreen.withOpacity(0.3),
          offset: const Offset(0, 4),
          blurRadius: 12,
          spreadRadius: 0,
        ),
      ];

  // ============================================================================
  // MODAL & DIALOG SHADOWS
  // ============================================================================
  
  /// Modal overlay shadow
  static List<BoxShadow> get modalShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          offset: const Offset(0, 16),
          blurRadius: 32,
          spreadRadius: 0,
        ),
      ];
  
  /// Dropdown shadow
  static List<BoxShadow> get dropdownShadow => [
        BoxShadow(
          color: AppColors.shadowDefault,
          offset: const Offset(0, 4),
          blurRadius: 12,
          spreadRadius: 0,
        ),
      ];

  // ============================================================================
  // NO SHADOW
  // ============================================================================
  
  /// No shadow - for flat design elements
  static List<BoxShadow> get none => const [];

  // ============================================================================
  // ELEVATION VALUES (Material Design 3 inspired)
  // ============================================================================
  
  /// Elevation 0 - No shadow
  static const double elevation0 = 0;
  
  /// Elevation 1 - Subtle elevation
  static const double elevation1 = 1;
  
  /// Elevation 2 - Default cards
  static const double elevation2 = 2;
  
  /// Elevation 3 - Raised cards
  static const double elevation3 = 3;
  
  /// Elevation 4 - Hovered elements
  static const double elevation4 = 4;
  
  /// Elevation 8 - Modals, dialogs
  static const double elevation8 = 8;

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================
  
  /// Get shadow for elevation level
  static List<BoxShadow> getShadowForElevation(double elevation) {
    if (elevation <= 1) {
      return cardDefault;
    } else if (elevation <= 3) {
      return cardActive;
    } else if (elevation <= 6) {
      return buttonHover;
    } else {
      return modalShadow;
    }
  }
}

