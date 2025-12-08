import 'package:flutter/material.dart';

/// Modern Spacing System - 8px base unit
/// Consistent spacing throughout the application
class AppSpacing {
  AppSpacing._(); // Private constructor

  // ============================================================================
  // BASE SPACING UNITS - 8px system
  // ============================================================================
  
  /// Extra small spacing - 4px
  static const double xs = 4.0;
  
  /// Small spacing - 8px
  static const double sm = 8.0;
  
  /// Medium spacing - 16px
  static const double md = 16.0;
  
  /// Large spacing - 24px
  static const double lg = 24.0;
  
  /// Extra large spacing - 32px
  static const double xl = 32.0;
  
  /// 2X Extra large spacing - 48px
  static const double xxl = 48.0;
  
  /// 3X Extra large spacing - 64px
  static const double xxxl = 64.0;

  // ============================================================================
  // COMPONENT SPECIFIC SPACING
  // ============================================================================
  
  /// Card internal padding
  static const double cardPadding = 24.0;
  
  /// Card gap between cards
  static const double cardGap = 24.0;
  
  /// Section spacing
  static const double sectionSpacing = 32.0;
  
  /// Page padding
  static const double pagePadding = 32.0;
  
  /// Mobile page padding
  static const double pagePaddingMobile = 16.0;
  
  /// List item spacing
  static const double listItemSpacing = 12.0;
  
  /// Icon spacing
  static const double iconSpacing = 12.0;
  
  /// Button padding horizontal
  static const double buttonPaddingH = 24.0;
  
  /// Button padding vertical
  static const double buttonPaddingV = 12.0;

  // ============================================================================
  // EDGE INSETS
  // ============================================================================
  
  /// Extra small padding
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  
  /// Small padding
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  
  /// Medium padding
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  
  /// Large padding
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  
  /// Extra large padding
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);
  
  /// Card padding
  static const EdgeInsets paddingCard = EdgeInsets.all(cardPadding);
  
  /// Page padding
  static const EdgeInsets paddingPage = EdgeInsets.all(pagePadding);
  
  /// Horizontal medium padding
  static const EdgeInsets paddingHorizontalMD = EdgeInsets.symmetric(horizontal: md);
  
  /// Vertical medium padding
  static const EdgeInsets paddingVerticalMD = EdgeInsets.symmetric(vertical: md);

  // ============================================================================
  // SIZED BOXES
  // ============================================================================
  
  /// Extra small gap
  static const SizedBox gapXS = SizedBox(width: xs, height: xs);
  
  /// Small gap
  static const SizedBox gapSM = SizedBox(width: sm, height: sm);
  
  /// Medium gap
  static const SizedBox gapMD = SizedBox(width: md, height: md);
  
  /// Large gap
  static const SizedBox gapLG = SizedBox(width: lg, height: lg);
  
  /// Extra large gap
  static const SizedBox gapXL = SizedBox(width: xl, height: xl);
  
  /// Horizontal small gap
  static const SizedBox gapHorizontalSM = SizedBox(width: sm);
  
  /// Horizontal medium gap
  static const SizedBox gapHorizontalMD = SizedBox(width: md);
  
  /// Horizontal large gap
  static const SizedBox gapHorizontalLG = SizedBox(width: lg);
  
  /// Vertical small gap
  static const SizedBox gapVerticalSM = SizedBox(height: sm);
  
  /// Vertical medium gap
  static const SizedBox gapVerticalMD = SizedBox(height: md);
  
  /// Vertical large gap
  static const SizedBox gapVerticalLG = SizedBox(height: lg);

  // ============================================================================
  // BORDER RADIUS
  // ============================================================================
  
  /// Extra small border radius - 4px
  static const double radiusXS = 4.0;
  
  /// Small border radius - 8px
  static const double radiusSM = 8.0;
  
  /// Medium border radius - 12px
  static const double radiusMD = 12.0;
  
  /// Large border radius - 16px
  static const double radiusLG = 16.0;
  
  /// Extra large border radius - 24px
  static const double radiusXL = 24.0;
  
  /// Card border radius
  static const double radiusCard = 12.0;
  
  /// Button border radius
  static const double radiusButton = 8.0;
  
  /// Chip border radius
  static const double radiusChip = 20.0;

  // ============================================================================
  // BORDER RADIUS OBJECTS
  // ============================================================================
  
  /// Small border radius
  static const BorderRadius borderRadiusSM = BorderRadius.all(Radius.circular(radiusSM));
  
  /// Medium border radius
  static const BorderRadius borderRadiusMD = BorderRadius.all(Radius.circular(radiusMD));
  
  /// Large border radius
  static const BorderRadius borderRadiusLG = BorderRadius.all(Radius.circular(radiusLG));
  
  /// Card border radius
  static const BorderRadius borderRadiusCard = BorderRadius.all(Radius.circular(radiusCard));
}

