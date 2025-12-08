import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';

import '../utils/responsive_layout.dart';
import '../widgets/main_app_drawer.dart';
import '../widgets/navigation/responsive_navigation.dart';
import 'customers/customers_screen.dart';
import 'feed/feed_dashboard_screen.dart';
import 'home/home_dashboard_screen.dart';
import 'home/reports_hub_screen.dart';
import 'medicine/medicine_dashboard_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int currentIndex = 0;
  final PageStorageBucket bucket = PageStorageBucket();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  WidgetBuilder get drawerBuilder => (context) => MainAppDrawer(
        isDark: widget.isDarkMode,
        onThemeChanged: widget.onThemeChanged,
      );

  List<Widget> get pages => [
        HomeDashboardScreen(drawerBuilder: drawerBuilder, key: const PageStorageKey('home')),
        FeedDashboardScreen(drawerBuilder: drawerBuilder, key: const PageStorageKey('feed')),
        MedicineDashboardScreen(drawerBuilder: drawerBuilder, key: const PageStorageKey('medicine')),
        CustomersScreen(drawerBuilder: drawerBuilder, key: const PageStorageKey('customers')),
        ReportsHubScreen(drawerBuilder: drawerBuilder, key: const PageStorageKey('reports')),
      ];

  List<NavDestination> get destinations => [
        const NavDestination(
          icon: Icons.dashboard_outlined,
          selectedIcon: Icons.dashboard,
          label: 'Home',
        ),
        NavDestination(
          icon: Icons.grass_outlined,
          selectedIcon: Icons.grass,
          label: 'Feed',
          badge: badges.Badge(
            showBadge: true,
            badgeContent: const Text('4', style: TextStyle(fontSize: 10, color: Colors.white)),
            badgeStyle: const badges.BadgeStyle(
              badgeColor: Colors.red,
              padding: EdgeInsets.all(4),
            ),
          ),
        ),
        const NavDestination(
          icon: Icons.medical_services_outlined,
          selectedIcon: Icons.medical_services,
          label: 'Medicine',
        ),
        const NavDestination(
          icon: Icons.people_outline,
          selectedIcon: Icons.people,
          label: 'Customers',
        ),
        const NavDestination(
          icon: Icons.pie_chart_outline,
          selectedIcon: Icons.pie_chart,
          label: 'Reports',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final screenList = pages;
    
    // For desktop, we don't need Scaffold wrapper as ResponsiveNavigation handles layout
    if (context.isDesktop) {
      return ResponsiveNavigation(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => setState(() => currentIndex = index),
        destinations: destinations,
        child: PageStorage(
          bucket: bucket,
          child: IndexedStack(index: currentIndex, children: screenList),
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: context.isMobile ? drawerBuilder(context) : null,
      body: ResponsiveNavigation(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => setState(() => currentIndex = index),
        destinations: destinations,
        child: PageStorage(
          bucket: bucket,
          child: IndexedStack(index: currentIndex, children: screenList),
        ),
      ),
    );
  }
}
