import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../widgets/order_card.dart';
import '../../widgets/stat_card.dart';
import 'feed_order_screen.dart';
import 'feed_products_screen.dart';
import 'feed_reports_screen.dart';

class FeedDashboardScreen extends StatelessWidget {
  const FeedDashboardScreen({super.key, required this.drawerBuilder});

  final WidgetBuilder drawerBuilder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Builder(builder: drawerBuilder),
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(feedLogoUrl),
            ),
            const SizedBox(width: 12),
            const Text('Feed Distribution'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Scanner coming soon.')),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1,
              children: const [
                StatCard(
                  icon: Icons.currency_rupee,
                  title: "Today's Sales",
                  value: '₹1,25,000',
                  trend: '+8.2% vs yesterday',
                ),
                StatCard(
                  icon: Icons.shopping_cart_outlined,
                  title: 'Orders',
                  value: '23',
                  trend: '4 new enquiries',
                ),
                StatCard(
                  icon: Icons.hourglass_empty,
                  title: 'Pending',
                  value: '₹45,000',
                  trend: '3 awaiting payment',
                ),
                StatCard(
                  icon: Icons.inventory_outlined,
                  title: 'Low Stock',
                  value: '5 items',
                  trend: 'Needs attention',
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Quick Actions', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.4,
              children: [
                _QuickActionTile(
                  icon: Icons.add_box_outlined,
                  label: 'New Order',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FeedOrderScreen()),
                  ),
                ),
                _QuickActionTile(
                  icon: Icons.inventory_2_outlined,
                  label: 'Products',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FeedProductsScreen()),
                  ),
                ),
                _QuickActionTile(
                  icon: Icons.bar_chart,
                  label: 'Reports',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FeedReportsScreen()),
                  ),
                ),
                const _QuickActionTile(icon: Icons.assignment_return, label: 'Returns'),
              ],
            ),
            const SizedBox(height: 24),
            Text('Recent Orders',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
            const SizedBox(height: 12),
            ...mockFeedOrders.map(
              (order) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: OrderCard(
                  order: order,
                  customerName: mockCustomers
                          .firstWhere((c) => c.id == order.customerId)
                          .name,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Starting new feed order flow...')),
        ),
        label: const Text('New Order'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(24),
      color: Theme.of(context).colorScheme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap ??
            () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$label tapped')),
                ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32),
              const SizedBox(height: 12),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
