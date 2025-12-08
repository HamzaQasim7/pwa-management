import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import '../../utils/responsive_layout.dart';
import '../../widgets/dashboard/modern_stat_card.dart';
import '../../widgets/dashboard/module_report_card.dart';
import '../../widgets/stat_card.dart';
import '../../presentation/providers/order_provider.dart';
import '../../presentation/providers/sale_provider.dart';
import '../../presentation/providers/customer_provider.dart';
import '../../presentation/providers/feed_product_provider.dart';
import '../../presentation/providers/medicine_provider.dart';
import '../feed/feed_reports_screen.dart';
import '../medicine/medicine_reports_screen.dart';

class ReportsHubScreen extends StatefulWidget {
  const ReportsHubScreen({super.key, required this.drawerBuilder});

  final WidgetBuilder drawerBuilder;

  @override
  State<ReportsHubScreen> createState() => _ReportsHubScreenState();
}

class _ReportsHubScreenState extends State<ReportsHubScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadOrders();
      context.read<SaleProvider>().loadSales();
      context.read<CustomerProvider>().loadCustomers();
      context.read<FeedProductProvider>().loadProducts();
      context.read<MedicineProvider>().loadMedicines();
    });
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  String _formatAmount(double amount) {
    if (amount >= 100000) {
      return 'Rs ${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return 'Rs ${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return 'Rs ${amount.toStringAsFixed(0)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: context.isMobile ? Builder(builder: widget.drawerBuilder) : null,
      appBar: context.isDesktop ? null : AppBar(
        title: const Text('Reports Center'),
      ),
      body: SafeArea(
        child: ResponsiveContentContainer(
          child: Consumer5<OrderProvider, SaleProvider, CustomerProvider, FeedProductProvider, MedicineProvider>(
            builder: (context, orderProvider, saleProvider, customerProvider, feedProductProvider, medicineProvider, child) {
              // Calculate feed revenue (from feed orders)
              final feedRevenue = orderProvider.feedOrders
                  .fold(0.0, (sum, order) => sum + order.total);
              
              // Medicine revenue (from sales)
              final medicineRevenue = saleProvider.totalRevenue;
              
              // Total customers
              final totalCustomers = customerProvider.totalCount;
              
              // Profit margin (from sales)
              final profitMargin = saleProvider.averageProfitMargin;
              
              // Calculate feed orders count
              final feedOrdersCount = orderProvider.feedOrders.length;
              
              // Calculate feed customers (unique customers who have feed orders)
              final feedCustomers = orderProvider.feedOrders
                  .map((o) => o.customerId)
                  .toSet()
                  .length;
              
              // Medicine items count
              final medicineItemsCount = medicineProvider.totalCount;
              
              return ListView(
                padding: ResponsiveLayout.padding(context),
                children: [
                  // Desktop: Show title since no AppBar
                  if (context.isDesktop) ...[
                    Text(
                      'Reports Center',
                      style: ResponsiveTextStyles.headlineLarge(context),
                    ),
                    SizedBox(height: ResponsiveLayout.spacing(context) * 0.5),
                    Text(
                      'Comprehensive analytics across all modules',
                      style: ResponsiveTextStyles.bodyLarge(context).copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    SizedBox(height: ResponsiveLayout.spacing(context) * 1.5),
                  ],
                  // Modern Stat Cards on Desktop
                  context.isDesktop
                      ? GridView.count(
                          crossAxisCount: 4,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: ResponsiveLayout.spacing(context),
                          crossAxisSpacing: ResponsiveLayout.spacing(context),
                          childAspectRatio: 1.5,
                          children: [
                            ModernStatCard(
                              label: 'Feed Revenue',
                              value: _formatAmount(feedRevenue),
                              icon: Icons.grass,
                              trend: feedRevenue > 0 ? 'up' : 'neutral',
                              trendValue: feedOrdersCount > 0 ? '${feedOrdersCount} orders' : 'No orders',
                              comparison: '${feedCustomers} active customers',
                              progress: feedRevenue > 0 ? 0.84 : 0.0,
                              module: 'feed',
                            ),
                            ModernStatCard(
                              label: 'Pharmacy Revenue',
                              value: _formatAmount(medicineRevenue),
                              icon: Icons.medical_services,
                              trend: medicineRevenue > 0 ? 'up' : 'neutral',
                              trendValue: saleProvider.totalCount > 0 ? '${saleProvider.totalCount} sales' : 'No sales',
                              comparison: 'Profit: ${_formatAmount(saleProvider.totalProfit)}',
                              progress: medicineRevenue > 0 ? 0.91 : 0.0,
                              module: 'medicine',
                            ),
                            ModernStatCard(
                              label: 'Total Customers',
                              value: '$totalCustomers',
                              icon: Icons.people,
                              trend: totalCustomers > 0 ? 'up' : 'neutral',
                              trendValue: totalCustomers > 0 ? '$totalCustomers active' : 'No customers',
                              comparison: 'Credit: ${_formatAmount(customerProvider.totalCredit)}',
                              progress: totalCustomers > 0 ? 0.70 : 0.0,
                              module: 'customers',
                            ),
                            ModernStatCard(
                              label: 'Profit Margin',
                              value: '${profitMargin.toStringAsFixed(0)}%',
                              icon: Icons.trending_up,
                              trend: profitMargin > 0 ? 'up' : 'neutral',
                              trendValue: profitMargin > 0 ? '${profitMargin.toStringAsFixed(1)}%' : '0%',
                              comparison: 'Total: ${_formatAmount(saleProvider.totalProfit)}',
                              progress: profitMargin > 0 ? (profitMargin / 100).clamp(0.0, 1.0) : 0.0,
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
                              icon: Icons.storefront,
                              title: 'Feed Revenue',
                              value: _formatAmount(feedRevenue),
                            ),
                            StatCard(
                              icon: Icons.local_hospital,
                              title: 'Pharmacy Revenue',
                              value: _formatAmount(medicineRevenue),
                            ),
                            StatCard(
                              icon: Icons.people_alt,
                              title: 'Customers',
                              value: '$totalCustomers',
                            ),
                            StatCard(
                              icon: Icons.stacked_bar_chart,
                              title: 'Profitability',
                              value: '${profitMargin.toStringAsFixed(0)}%',
                            ),
                          ],
                        ),
                  SizedBox(height: ResponsiveLayout.spacing(context) * 1.5),
                  Text(
                    'Module Reports',
                    style: ResponsiveTextStyles.headlineSmall(context),
                  ),
                  SizedBox(height: ResponsiveLayout.spacing(context)),
                  
                  // Modern Module Report Cards
                  ModuleReportCard(
                    title: 'Feed Distribution Reports',
                    subtitle: 'Dashboard, product, customer & profit insights',
                    icon: Icons.grass,
                    module: 'feed',
                    quickStats: [
                      QuickStat(icon: Icons.bar_chart, value: '${feedOrdersCount} orders'),
                      QuickStat(icon: Icons.attach_money, value: _formatAmount(feedRevenue)),
                      QuickStat(icon: Icons.people, value: '$feedCustomers customers'),
                    ],
                    onTap: () => _open(context, const FeedReportsScreen()),
                  ),
                  
                  SizedBox(height: ResponsiveLayout.spacing(context)),
                  
                  ModuleReportCard(
                    title: 'Medicine & Pharmacy Reports',
                    subtitle: 'Daily to yearly analytics with financial breakdowns',
                    icon: Icons.medical_services,
                    module: 'medicine',
                    quickStats: [
                      QuickStat(icon: Icons.analytics, value: '${saleProvider.totalCount} sales'),
                      QuickStat(icon: Icons.monetization_on, value: _formatAmount(medicineRevenue)),
                      QuickStat(icon: Icons.inventory, value: '$medicineItemsCount items'),
                    ],
                    onTap: () => _open(context, const MedicineReportsScreen()),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
