import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../presentation/providers/feed_product_provider.dart';
import '../../presentation/providers/order_provider.dart';
import '../../presentation/providers/customer_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive_layout.dart';
import '../../widgets/order_card.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/loading_shimmer.dart';
import '../../data/models/order_model.dart';
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
        title: const Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.grass, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text('Feed Distribution'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Scanner coming soon.')),
            ),
          ),
          Consumer<OrderProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: provider.isLoading ? null : () => provider.refresh(),
                tooltip: 'Refresh',
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveContentContainer(
          child: RefreshIndicator(
            onRefresh: () async {
              await context.read<OrderProvider>().refresh();
              await context.read<FeedProductProvider>().refresh();
            },
            child: ListView(
              padding: ResponsiveLayout.padding(context),
              children: [
                // Stats Grid
                Consumer2<OrderProvider, FeedProductProvider>(
                  builder: (context, orderProvider, productProvider, child) {
                    // Get feed orders
                    final feedOrders = orderProvider.allOrders
                        .where((o) => o.orderType == 'feed')
                        .toList();
                    
                    // Calculate today's sales
                    final now = DateTime.now();
                    final startOfDay = DateTime(now.year, now.month, now.day);
                    final todaysSales = feedOrders
                        .where((o) => o.date.isAfter(startOfDay))
                        .fold(0.0, (sum, o) => sum + o.total);
                    
                    // Calculate pending amount
                    final pendingAmount = feedOrders
                        .where((o) => o.paymentStatus != 'Paid')
                        .fold(0.0, (sum, o) => sum + o.remainingAmount);
                    
                    // Get pending orders count
                    final pendingOrders = feedOrders
                        .where((o) => o.paymentStatus != 'Paid')
                        .length;
                    
                    // Get today's orders count
                    final todaysOrders = feedOrders
                        .where((o) => o.date.isAfter(startOfDay))
                        .length;

                    return GridView.count(
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
                        mobile: 0.95,
                        tablet: 1.1,
                        desktop: 1.2,
                      ),
                      children: [
                        StatCard(
                          icon: Icons.currency_rupee,
                          title: "Today's Sales",
                          value: '₹${_formatAmount(todaysSales)}',
                          trend: '$todaysOrders orders today',
                        ),
                        StatCard(
                          icon: Icons.shopping_cart_outlined,
                          title: 'Total Orders',
                          value: '${feedOrders.length}',
                          trend: '$todaysOrders new today',
                        ),
                        StatCard(
                          icon: Icons.hourglass_empty,
                          title: 'Pending',
                          value: '₹${_formatAmount(pendingAmount)}',
                          trend: '$pendingOrders awaiting payment',
                        ),
                        StatCard(
                          icon: Icons.inventory_outlined,
                          title: 'Low Stock',
                          value: '${productProvider.lowStockCount} items',
                          trend: productProvider.lowStockCount > 0 ? 'Needs attention' : 'All stocked',
                        ),
                      ],
                    );
                  },
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
                Consumer2<OrderProvider, CustomerProvider>(
                  builder: (context, orderProvider, customerProvider, child) {
                    if (orderProvider.isLoading && orderProvider.allOrders.isEmpty) {
                      return LoadingShimmer(
                        child: Column(
                          children: List.generate(
                            3,
                            (index) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Container(
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    final feedOrders = orderProvider.allOrders
                        .where((o) => o.orderType == 'feed')
                        .take(10)
                        .toList();

                    if (feedOrders.isEmpty) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 48,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No orders yet',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Create your first order to get started',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: feedOrders.map((order) {
                        // Get customer name
                        String customerName = order.customerName ?? 'Unknown';
                        if (customerName == 'Unknown' || customerName.isEmpty) {
                          final customer = customerProvider.allCustomers
                              .where((c) => c.id == order.customerId)
                              .firstOrNull;
                          if (customer != null) {
                            customerName = customer.name;
                          }
                        }

                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: ResponsiveLayout.spacing(context) * 0.75,
                          ),
                          child: _FeedOrderCard(
                            order: order,
                            customerName: customerName,
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FeedOrderScreen()),
        ),
        label: const Text('New Order'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
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

class _FeedOrderCard extends StatelessWidget {
  final OrderModel order;
  final String customerName;

  const _FeedOrderCard({
    required this.order,
    required this.customerName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color statusColor;
    switch (order.paymentStatus) {
      case 'Paid':
        statusColor = Colors.green;
        break;
      case 'Pending':
        statusColor = Colors.orange;
        break;
      case 'Partially Paid':
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Order info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        order.orderNumber,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          order.paymentStatus,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    customerName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(order.date),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${order.total.toStringAsFixed(0)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                if (order.discount > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    '-₹${order.discount.toStringAsFixed(0)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.green,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

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
}
