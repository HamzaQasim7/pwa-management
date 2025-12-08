import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../utils/responsive_layout.dart';
import '../widgets/dashboard/modern_stat_card.dart';
import 'stat_card.dart';

/// Enhanced Stat Card - Smart wrapper that uses modern design on desktop
/// 
/// **BACKWARD COMPATIBLE**: Falls back to old StatCard on mobile/tablet
/// **MODERN**: Uses ModernStatCard on desktop with all new features
/// 
/// This allows gradual migration without breaking existing code
class StatCardEnhanced extends StatelessWidget {
  const StatCardEnhanced({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.trend,
    this.onTap,
    this.background,
    this.valueColor,
    // New modern features (optional)
    this.trendValue,
    this.comparison,
    this.progress,
    this.module = 'default',
    this.useModernDesign = true,
  });

  // Common properties (compatible with old StatCard)
  final IconData icon;
  final String title;
  final String value;
  final String? trend;
  final VoidCallback? onTap;
  final Color? background;
  final Color? valueColor;

  // New modern properties
  final String? trendValue;
  final String? comparison;
  final double? progress;
  final String module;
  final bool useModernDesign;

  @override
  Widget build(BuildContext context) {
    // Use modern design on desktop if enabled
    if (useModernDesign && context.isDesktop) {
      return ModernStatCard(
        label: title,
        value: value,
        icon: icon,
        trend: trend,
        trendValue: trendValue,
        comparison: comparison,
        progress: progress,
        module: module,
        onTap: onTap,
      );
    }

    // Fallback to original StatCard on mobile/tablet or if modern disabled
    return StatCard(
      icon: icon,
      title: title,
      value: value,
      trend: trend,
      onTap: onTap,
      background: background,
      valueColor: valueColor,
    );
  }
}

/// Helper extension to quickly create enhanced stat cards
extension StatCardEnhancedHelper on BuildContext {
  /// Create a revenue stat card with proper theming
  Widget revenueCard({
    required String value,
    String? trend,
    String? trendValue,
    String? comparison,
    double? progress,
  }) {
    return StatCardEnhanced(
      icon: Icons.attach_money,
      title: 'Revenue',
      value: value,
      trend: trend,
      trendValue: trendValue,
      comparison: comparison,
      progress: progress,
      module: 'profit',
      valueColor: AppColors.amberOrange,
    );
  }

  /// Create an orders stat card
  Widget ordersCard({
    required String value,
    String? trend,
    String? trendValue,
    String? comparison,
    double? progress,
  }) {
    return StatCardEnhanced(
      icon: Icons.shopping_bag,
      title: 'Orders',
      value: value,
      trend: trend,
      trendValue: trendValue,
      comparison: comparison,
      progress: progress,
      module: 'feed',
      valueColor: AppColors.emeraldGreen,
    );
  }

  /// Create a customers stat card
  Widget customersCard({
    required String value,
    String? trend,
    String? trendValue,
    String? comparison,
    double? progress,
  }) {
    return StatCardEnhanced(
      icon: Icons.people,
      title: 'Customers',
      value: value,
      trend: trend,
      trendValue: trendValue,
      comparison: comparison,
      progress: progress,
      module: 'customers',
      valueColor: AppColors.purple,
    );
  }
}

