import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';

import '../widgets/main_app_drawer.dart';
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

  @override
  Widget build(BuildContext context) {
    final screenList = pages;
    return Scaffold(
      body: PageStorage(
        bucket: bucket,
        child: IndexedStack(index: currentIndex, children: screenList),
      ),
      bottomNavigationBar: _buildNavBar(context),
    );
  }

  Widget _buildNavBar(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) => setState(() => currentIndex = index),
      destinations: [
        const NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Home'),
        NavigationDestination(
          icon: badges.Badge(
            showBadge: true,
            badgeContent: const Text('4'),
            child: const Icon(Icons.grass_outlined),
          ),
          label: 'Feed',
        ),
        const NavigationDestination(icon: Icon(Icons.medical_services_outlined), label: 'Medicine'),
        const NavigationDestination(icon: Icon(Icons.people_outline), label: 'Customers'),
        const NavigationDestination(icon: Icon(Icons.pie_chart_outline), label: 'Reports'),
      ],
    );
  }
}
