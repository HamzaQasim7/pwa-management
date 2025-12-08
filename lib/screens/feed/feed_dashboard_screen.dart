import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive_layout.dart';
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
      drawer: context.isMobile ? Builder(builder: drawerBuilder) : null,
      appBar: context.isDesktop ? null : AppBar(
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
        child: ResponsiveContentContainer(
          child: ListView(
            padding: ResponsiveLayout.padding(context),
            children: [
              GridView.count(
                crossAxisCount: ResponsiveLayout.gridCrossAxisCount(
                  context,
                  mobile: 2,
                  tablet: 2,
                  desktop: 4,
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: ResponsiveLayout.spacing(context),
                crossAxisSpacing: ResponsiveLayout.spacing(context),
                childAspectRatio: ResponsiveLayout.value(
                  context: context,
                  mobile: 0.95, // Fixed: was 1.0, now 0.95 to give more height
                  tablet: 1.1,
                  desktop: 1.2,
                ),
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
              SizedBox(height: ResponsiveLayout.spacing(context) * 1.5),
              Text('Quick Actions', style: ResponsiveTextStyles.headlineSmall(context)),
              SizedBox(height: ResponsiveLayout.spacing(context) * 0.75),
              GridView.count(
                crossAxisCount: ResponsiveLayout.gridCrossAxisCount(
                  context,
                  mobile: 2,
                  tablet: 3,
                  desktop: 4,
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: ResponsiveLayout.spacing(context),
                crossAxisSpacing: ResponsiveLayout.spacing(context),
                childAspectRatio: context.isDesktop ? 1.6 : 1.4,
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
              SizedBox(height: ResponsiveLayout.spacing(context) * 1.5),
              Text('Recent Orders',
                  style: ResponsiveTextStyles.headlineSmall(context)),
              SizedBox(height: ResponsiveLayout.spacing(context) * 0.75),
              ...mockFeedOrders.map(
                (order) => Padding(
                  padding: EdgeInsets.only(
                    bottom: ResponsiveLayout.spacing(context) * 0.75,
                  ),
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
      borderRadius: BorderRadius.circular(16),
      color: Theme.of(context).colorScheme.surface,
      elevation: context.isDesktop ? 1 : 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap ??
            () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$label tapped')),
                ),
        child: Padding(
          padding: ResponsiveLayout.cardPadding(context),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: ResponsiveLayout.iconSize(context)),
              SizedBox(height: ResponsiveLayout.spacing(context) * 0.5),
              Text(
                label,
                textAlign: TextAlign.center,
                style: ResponsiveTextStyles.bodyMedium(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
