import 'package:flutter/material.dart';
import '../../utils/responsive_layout.dart';
import 'web_sidebar.dart';

/// Navigation destination data model
class NavDestination {
  const NavDestination({
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.badge,
  });

  final IconData icon;
  final String label;
  final IconData? selectedIcon;
  final Widget? badge;
}

/// Main responsive navigation wrapper
/// Decides which navigation UI to show based on screen size
class ResponsiveNavigation extends StatelessWidget {
  const ResponsiveNavigation({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.child,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavDestination> destinations;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Desktop: Show permanent sidebar
    if (context.isDesktop) {
      return Row(
        children: [
          WebSidebar(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            destinations: destinations,
          ),
          Expanded(child: child),
        ],
      );
    }

    // Tablet: Show collapsed navigation rail
    if (context.isTablet) {
      return Row(
        children: [
          _buildNavigationRail(context),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      );
    }

    // Mobile: Show bottom navigation
    return Scaffold(
      body: child,
      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }

  Widget _buildNavigationRail(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      labelType: NavigationRailLabelType.all,
      destinations: destinations.map((dest) {
        return NavigationRailDestination(
          icon: Icon(dest.icon),
          selectedIcon: Icon(dest.selectedIcon ?? dest.icon),
          label: Text(dest.label),
        );
      }).toList(),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: destinations.map((dest) {
        return NavigationDestination(
          icon: dest.badge != null
              ? Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(dest.icon),
                    Positioned(
                      right: -8,
                      top: -8,
                      child: dest.badge!,
                    ),
                  ],
                )
              : Icon(dest.icon),
          selectedIcon: Icon(dest.selectedIcon ?? dest.icon),
          label: dest.label,
        );
      }).toList(),
    );
  }
}

