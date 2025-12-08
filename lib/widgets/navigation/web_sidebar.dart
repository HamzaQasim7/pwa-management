import 'package:flutter/material.dart';
import '../../utils/responsive_layout.dart';
import 'modern_sidebar.dart';
import 'responsive_navigation.dart';

/// Desktop web sidebar navigation
/// Shows as a permanent, fixed-width sidebar on the left side
/// 
/// **MODERN VERSION**: Now uses ModernSidebar internally with backward compatibility
class WebSidebar extends StatelessWidget {
  const WebSidebar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavDestination> destinations;

  @override
  Widget build(BuildContext context) {
    final sidebarDestinations = destinations.map((dest) {
      return SidebarDestination(
        icon: dest.icon,
        selectedIcon: dest.selectedIcon,
        label: dest.label,
        badge: dest.badge,
      );
    }).toList();

    // Use ModernSidebar with professional design
    return ModernSidebar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: sidebarDestinations,
      onSettingsTap: () {
        // TODO: Navigate to settings
      },
      onNotificationsTap: () {
        // TODO: Navigate to notifications
      },
    );
  }
}

/// Legacy WebSidebar implementation (kept for reference/fallback)
/// Use WebSidebar (above) which now uses ModernSidebar internally
@Deprecated('Use WebSidebar which now uses ModernSidebar internally')
class LegacyWebSidebar extends StatelessWidget {
  const LegacyWebSidebar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavDestination> destinations;

  @override
  Widget build(BuildContext context) {
    final sidebarWidth = context.sidebarWidth;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: sidebarWidth,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          right: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: const Center(
        child: Text('Legacy sidebar - use WebSidebar instead'),
      ),
    );
  }
}

