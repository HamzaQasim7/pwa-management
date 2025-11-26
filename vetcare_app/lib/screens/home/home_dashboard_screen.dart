import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../widgets/stat_card.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key, required this.drawerBuilder});

  final WidgetBuilder drawerBuilder;

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  bool showFeed = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      drawer: Builder(builder: widget.drawerBuilder),
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(
                showFeed ? feedLogoUrl : medicineLogoUrl,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('VetCare Distributors',
                    style: Theme.of(context).textTheme.titleMedium),
                Text('Premium feed & pharmacy',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notifications from drawer.')),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('Feed Dashboard')),
                ButtonSegment(value: false, label: Text('Medicine Dashboard')),
              ],
              selected: {showFeed},
              onSelectionChanged: (value) =>
                  setState(() => showFeed = value.first),
            ),
            const SizedBox(height: 24),
            Text(
              showFeed ? 'Today in Feed' : 'Today in Pharmacy',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                StatCard(
                  icon: Icons.payments_outlined,
                  title: "Today's Sales",
                  value: showFeed ? '₹1,25,000' : '₹88,000',
                  trend: '+12% vs yesterday',
                  valueColor:
                      showFeed ? colorScheme.primary : colorScheme.secondary,
                ),
                StatCard(
                  icon: Icons.shopping_bag_outlined,
                  title: showFeed ? 'Orders' : 'Bills',
                  value: showFeed ? '23' : '18',
                  trend: '4 pending approvals',
                ),
                StatCard(
                  icon: Icons.hourglass_top_outlined,
                  title: 'Pending Value',
                  value: showFeed ? '₹45,000' : '₹38,500',
                  trend: 'Follow up customers',
                ),
                StatCard(
                  icon: Icons.medication_liquid,
                  title: 'Low Stock Items',
                  value: showFeed ? '5' : '8',
                  trend: 'Reorder suggested',
                  valueColor: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Quick Actions',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _QuickAction(
                  icon: Icons.add_shopping_cart,
                  label: 'New Feed Order',
                  onTap: () {},
                ),
                _QuickAction(
                  icon: Icons.inventory_2_outlined,
                  label: 'Add Product',
                  onTap: () {},
                ),
                _QuickAction(
                  icon: Icons.document_scanner_outlined,
                  label: 'Print Invoice',
                  onTap: () {},
                ),
                _QuickAction(
                  icon: Icons.analytics_outlined,
                  label: 'Reports',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text('Upcoming Deliveries',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...mockFeedOrders.take(3).map(
              (order) => ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                leading: CircleAvatar(child: Text(order.orderNumber.substring(4))),
                title: Text(order.orderNumber),
                subtitle: Text(order.date),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('₹${order.total.toStringAsFixed(0)}'),
                    Text(order.paymentStatus,
                        style: TextStyle(
                          color: order.paymentStatus == 'Paid'
                              ? colorScheme.primary
                              : Colors.amber,
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, this.onTap});

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
        onTap: onTap,
        child: SizedBox(
          width: MediaQuery.of(context).size.width / 2 - 32,
          height: 110,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28),
              const SizedBox(height: 12),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
