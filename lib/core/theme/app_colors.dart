import 'package:flutter/material.dart';

/// Modern Color Palette - 2025 Professional Standards
/// NO pastel colors, bold and professional
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // ============================================================================
  // PRIMARY PALETTE - Professional & Bold
  // ============================================================================
  
  /// Deep Navy - Professional, trust, authority
  static const Color deepNavy = Color(0xFF1E293B);
  static const Color darkNavy = Color(0xFF0F172A);
  
  /// Emerald Green - Success, growth, vitality
  static const Color emeraldGreen = Color(0xFF059669);
  static const Color emeraldLight = Color(0xFF10B981);
  
  /// Royal Blue - Action, energy, primary actions
  static const Color royalBlue = Color(0xFF2563EB);
  static const Color royalBlueLight = Color(0xFF3B82F6);
  
  /// Amber Orange - Attention, warmth, warnings
  static const Color amberOrange = Color(0xFFF59E0B);
  static const Color amberLight = Color(0xFFFBBF24);
  
  /// Purple - Premium, customers
  static const Color purple = Color(0xFF8B5CF6);
  static const Color purpleLight = Color(0xFFA78BFA);
  
  /// Red - Errors, alerts, negative trends
  static const Color red = Color(0xFFEF4444);
  static const Color redLight = Color(0xFFF87171);

  // ============================================================================
  // BACKGROUND SYSTEM - Light Mode
  // ============================================================================
  
  /// Page background - Subtle grey-blue
  static const Color pageBackground = Color(0xFFF8FAFC);
  
  /// Card background - Pure white
  static const Color cardBackground = Color(0xFFFFFFFF);
  
  /// Sidebar background - Dark navy
  static const Color sidebarBackground = Color(0xFF0F172A);
  
  /// Hover states - Very light grey
  static const Color hoverBackground = Color(0xFFF1F5F9);
  
  /// Border color - Light grey
  static const Color borderColor = Color(0xFFE2E8F0);

  // ============================================================================
  // TEXT COLORS - Light Mode
  // ============================================================================
  
  /// Primary text - Dark navy
  static const Color textPrimary = Color(0xFF0F172A);
  
  /// Secondary text - Medium grey
  static const Color textSecondary = Color(0xFF334155);
  
  /// Tertiary text - Light grey
  static const Color textTertiary = Color(0xFF475569);
  
  /// Muted text - Very light grey
  static const Color textMuted = Color(0xFF64748B);
  
  /// Disabled text
  static const Color textDisabled = Color(0xFF94A3B8);
  
  /// Placeholder text
  static const Color textPlaceholder = Color(0xFFCBD5E1);

  // ============================================================================
  // DARK MODE - Background System
  // ============================================================================
  
  /// Dark mode page background
  static const Color darkPageBackground = Color(0xFF0A0E27);
  
  /// Dark mode card background
  static const Color darkCardBackground = Color(0xFF1E293B);
  
  /// Dark mode hover
  static const Color darkHoverBackground = Color(0xFF334155);
  
  /// Dark mode border
  static const Color darkBorderColor = Color(0xFF475569);

  // ============================================================================
  // DARK MODE - Text Colors
  // ============================================================================
  
  /// Dark mode primary text
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  
  /// Dark mode secondary text
  static const Color darkTextSecondary = Color(0xFFE2E8F0);
  
  /// Dark mode tertiary text
  static const Color darkTextTertiary = Color(0xFFCBD5E1);
  
  /// Dark mode muted text
  static const Color darkTextMuted = Color(0xFF94A3B8);

  // ============================================================================
  // GRADIENTS - Module Specific
  // ============================================================================
  
  /// Feed module gradient - Emerald Green
  static const LinearGradient feedGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [emeraldGreen, emeraldLight],
  );
  
  /// Medicine module gradient - Royal Blue
  static const LinearGradient medicineGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [royalBlue, royalBlueLight],
  );
  
  /// Customers module gradient - Purple
  static const LinearGradient customersGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purple, purpleLight],
  );
  
  /// Profit/Revenue module gradient - Amber to Red
  static const LinearGradient profitGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [amberOrange, red],
  );
  
  /// Reports module gradient - Royal Blue to Purple
  static const LinearGradient reportsGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [royalBlue, purple],
  );

  // ============================================================================
  // SIDEBAR GRADIENTS
  // ============================================================================
  
  /// Active navigation item gradient
  static const LinearGradient sidebarActiveGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.2, 1.0],
    colors: [emeraldGreen, emeraldLight],
  );

  // ============================================================================
  // STATUS COLORS
  // ============================================================================
  
  /// Success color
  static const Color success = emeraldGreen;
  
  /// Warning color
  static const Color warning = amberOrange;
  
  /// Error color
  static const Color error = red;
  
  /// Info color
  static const Color info = royalBlue;

  // ============================================================================
  // SHADOW COLORS
  // ============================================================================
  
  /// Default shadow color
  static final Color shadowDefault = Colors.black.withOpacity(0.1);
  
  /// Hover shadow color
  static final Color shadowHover = Colors.black.withOpacity(0.15);
  
  /// Focus shadow color - Royal Blue with opacity
  static final Color shadowFocus = royalBlue.withOpacity(0.1);

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================
  
  /// Get gradient colors for module type
  static List<Color> getModuleGradientColors(String module) {
    switch (module.toLowerCase()) {
      case 'feed':
        return [emeraldGreen, emeraldLight];
      case 'medicine':
      case 'pharmacy':
        return [royalBlue, royalBlueLight];
      case 'customers':
      case 'customer':
        return [purple, purpleLight];
      case 'profit':
      case 'revenue':
        return [amberOrange, red];
      case 'reports':
        return [royalBlue, purple];
      default:
        return [deepNavy, royalBlue];
    }
  }
  
  /// Get primary color for module type
  static Color getModulePrimaryColor(String module) {
    switch (module.toLowerCase()) {
      case 'feed':
        return emeraldGreen;
      case 'medicine':
      case 'pharmacy':
        return royalBlue;
      case 'customers':
      case 'customer':
        return purple;
      case 'profit':
      case 'revenue':
        return amberOrange;
      case 'reports':
        return royalBlue;
      default:
        return deepNavy;
    }
  }
}

