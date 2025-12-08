import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart' as modern;
import '../../presentation/providers/feed_product_provider.dart';
import '../../presentation/providers/medicine_provider.dart';
import '../../presentation/providers/order_provider.dart';
import '../../presentation/providers/sale_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive_layout.dart';
import '../../widgets/dashboard/modern_stat_card.dart';
import '../../widgets/stat_card.dart';

// Logo URLs for dashboard header
const _feedLogoUrl =
    'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=200&q=60';
const _medicineLogoUrl =
    'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?auto=format&fit=crop&w=200&q=60';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key, required this.drawerBuilder});

  final WidgetBuilder drawerBuilder;

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  bool showFeed = true;

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatAmount(double amount) {
    if (amount >= 100000) {
      return 'Rs ${(amount / 100000).toStringAsFixed(2)}L';
    } else if (amount >= 1000) {
      return 'Rs ${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return 'Rs ${amount.toStringAsFixed(0)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      // Only show drawer on mobile (desktop has permanent sidebar)
      drawer: context.isMobile ? Builder(builder: widget.drawerBuilder) : null,
      appBar: context.isDesktop ? null : AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(
                showFeed ? _feedLogoUrl : _medicineLogoUrl,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Aftab Distributors',
                      style: Theme.of(context).textTheme.titleMedium),
                  Text('Premium feed & pharmacy',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
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
        child: ResponsiveContentContainer(
          child: ListView(
            padding: ResponsiveLayout.padding(context),
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
            SizedBox(height: ResponsiveLayout.spacing(context)),
            Text(
              showFeed ? 'Today in Feed' : 'Today in Pharmacy',
              style: ResponsiveTextStyles.headlineMedium(context),
            ),
            SizedBox(height: ResponsiveLayout.spacing(context)),
              // Modern Stat Cards on Desktop, Classic on Mobile
              Consumer4<OrderProvider, SaleProvider, FeedProductProvider, MedicineProvider>(
                builder: (context, orderProvider, saleProvider, feedProvider, medicineProvider, child) {
                  final todaysSales = showFeed 
                      ? orderProvider.todaysRevenue 
                      : saleProvider.todaysRevenue;
                  final totalOrders = showFeed 
                      ? orderProvider.feedOrders.length 
                      : saleProvider.totalCount;
                  final pendingValue = showFeed 
                      ? orderProvider.totalPending 
                      : 0.0;
                  final lowStockCount = showFeed 
                      ? feedProvider.lowStockCount 
                      : medicineProvider.lowStockCount;
                  final pendingOrders = orderProvider.pendingOrders.length;

                  return context.isDesktop
                      ? GridView.count(
                          crossAxisCount: 4,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: ResponsiveLayout.spacing(context),
                          crossAxisSpacing: ResponsiveLayout.spacing(context),
                          childAspectRatio: 1.35,
                          children: [
                            ModernStatCard(
                              label: "Today's Sales",
                              value: _formatAmount(todaysSales),
                              icon: Icons.attach_money,
                              trend: todaysSales > 0 ? 'up' : 'neutral',
                              trendValue: todaysSales > 0 ? '+' : '',
                              comparison: 'Updated in real-time',
                              progress: 0.75,
                              module: showFeed ? 'feed' : 'medicine',
                            ),
                            ModernStatCard(
                              label: showFeed ? 'Orders' : 'Bills',
                              value: '$totalOrders',
                              icon: Icons.shopping_bag,
                              trend: totalOrders > 0 ? 'up' : 'neutral',
                              trendValue: '',
                              comparison: '$pendingOrders pending',
                              progress: 0.65,
                              module: showFeed ? 'feed' : 'medicine',
                            ),
                            ModernStatCard(
                              label: 'Pending Value',
                              value: _formatAmount(pendingValue),
                              icon: Icons.hourglass_top,
                              trend: pendingValue > 0 ? 'neutral' : 'up',
                              trendValue: '',
                              comparison: 'Follow up customers',
                              progress: 0.45,
                              module: 'customers',
                            ),
                            ModernStatCard(
                              label: 'Low Stock Items',
                              value: '$lowStockCount',
                              icon: Icons.inventory,
                              trend: lowStockCount > 0 ? 'down' : 'up',
                              trendValue: lowStockCount > 0 ? '-$lowStockCount' : '',
                              comparison: lowStockCount > 0 ? 'Reorder suggested' : 'All stocked',
                              progress: 0.3,
                              module: 'profit',
                            ),
                          ],
                        )
                      : GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: ResponsiveLayout.spacing(context),
                          crossAxisSpacing: ResponsiveLayout.spacing(context),
                          childAspectRatio: 0.95,
                          children: [
                            StatCard(
                              icon: Icons.payments_outlined,
                              title: "Today's Sales",
                              value: _formatAmount(todaysSales),
                              trend: 'Updated in real-time',
                              valueColor: showFeed
                                  ? modern.AppColors.emeraldGreen
                                  : modern.AppColors.royalBlue,
                            ),
                            StatCard(
                              icon: Icons.shopping_bag_outlined,
                              title: showFeed ? 'Orders' : 'Bills',
                              value: '$totalOrders',
                              trend: '$pendingOrders pending',
                            ),
                            StatCard(
                              icon: Icons.hourglass_top_outlined,
                              title: 'Pending Value',
                              value: _formatAmount(pendingValue),
                              trend: 'Follow up customers',
                            ),
                            StatCard(
                              icon: Icons.medication_liquid,
                              title: 'Low Stock Items',
                              value: '$lowStockCount',
                              trend: lowStockCount > 0 ? 'Reorder suggested' : 'All stocked',
                              valueColor: lowStockCount > 0 
                                  ? modern.AppColors.amberOrange 
                                  : modern.AppColors.emeraldGreen,
                            ),
                          ],
                        );
                },
              ),
            SizedBox(height: ResponsiveLayout.spacing(context) * 1.5),
            Text('Quick Actions',
                style: ResponsiveTextStyles.headlineSmall(context)),
            SizedBox(height: ResponsiveLayout.spacing(context) * 0.75),
            Wrap(
              spacing: ResponsiveLayout.spacing(context) * 0.75,
              runSpacing: ResponsiveLayout.spacing(context) * 0.75,
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
            SizedBox(height: ResponsiveLayout.spacing(context) * 1.5),
            Text('Upcoming Deliveries',
                style: ResponsiveTextStyles.headlineSmall(context)),
            SizedBox(height: ResponsiveLayout.spacing(context) * 0.75),
            Consumer<OrderProvider>(
              builder: (context, orderProvider, child) {
                final recentOrders = orderProvider.allOrders.take(3).toList();
                
                if (recentOrders.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            color: colorScheme.outline,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text('No recent orders'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                return Column(
                  children: recentOrders.map(
                    (order) => ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      leading: CircleAvatar(
                        child: Text(
                          order.orderNumber.length > 4 
                              ? order.orderNumber.substring(order.orderNumber.length - 4)
                              : order.orderNumber,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      title: Text(
                        order.orderNumber,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        _formatDate(order.date),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Rs ${order.total.toStringAsFixed(0)}'),
                          Text(
                            order.paymentStatus,
                            style: TextStyle(
                              color: order.paymentStatus == 'Paid'
                                  ? colorScheme.primary
                                  : Colors.amber,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).toList(),
                );
              },
            ),
            ],
          ),
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
    // Calculate width based on device type
    final width = ResponsiveLayout.value<double>(
      context: context,
      mobile: (MediaQuery.of(context).size.width - 64) / 2,
      tablet: 160.0,
      desktop: 180.0,
    );

    final height = ResponsiveLayout.value<double>(
      context: context,
      mobile: 110.0,
      tablet: 120.0,
      desktop: 130.0,
    );

    return Material(
      borderRadius: BorderRadius.circular(16),
      color: Theme.of(context).colorScheme.surface,
      elevation: context.isDesktop ? 1 : 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: SizedBox(
          width: width,
          height: height,
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
