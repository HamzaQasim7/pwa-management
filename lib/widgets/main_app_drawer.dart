import 'package:flutter/material.dart';

import '../screens/feed/feed_order_screen.dart';
import '../screens/feed/feed_products_screen.dart';
import '../screens/medicine/add_medicine_screen.dart';
import '../screens/medicine/expiry_management_screen.dart';
import '../screens/medicine/medicine_inventory_screen.dart';
import '../screens/medicine/medicine_reports_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/settings/settings_screen.dart';

class MainAppDrawer extends StatelessWidget {
  const MainAppDrawer({super.key, required this.isDark, required this.onThemeChanged});

  final bool isDark;
  final ValueChanged<bool> onThemeChanged;

  void _open(BuildContext context, Widget screen) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            const DrawerHeader(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(radius: 32, child: Icon(Icons.pets, size: 32)),
                  SizedBox(height: 12),
                  Text('VetCare Suite', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Smart operations cockpit'),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: const Text('Feed Products'),
              onTap: () => _open(context, const FeedProductsScreen()),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Feed Orders'),
              onTap: () => _open(context, const FeedOrderScreen()),
            ),
            ListTile(
              leading: const Icon(Icons.medical_services_outlined),
              title: const Text('Medicine Inventory'),
              onTap: () => _open(context, const MedicineInventoryScreen()),
            ),
            ListTile(
              leading: const Icon(Icons.warning_amber),
              title: const Text('Expiry Management'),
              onTap: () => _open(context, const ExpiryManagementScreen()),
            ),
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('Add Medicine'),
              onTap: () => _open(context, const AddMedicineScreen()),
            ),
            ListTile(
              leading: const Icon(Icons.analytics_outlined),
              title: const Text('Medicine Reports'),
              onTap: () => _open(context, const MedicineReportsScreen()),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.notifications_active_outlined),
              title: const Text('Notifications'),
              onTap: () => _open(context, const NotificationsScreen()),
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () => _open(
                context,
                SettingsScreen(isDark: isDark, onThemeChanged: onThemeChanged),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
