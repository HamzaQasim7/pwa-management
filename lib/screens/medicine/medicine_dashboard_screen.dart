import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';

import '../../presentation/providers/medicine_provider.dart';
import '../../presentation/providers/sale_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive_layout.dart';
import '../../widgets/alert_card.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/loading_shimmer.dart';
import '../../data/mock_data.dart';
import 'add_medicine_screen.dart';
import 'medicine_inventory_screen.dart';
import 'medicine_reports_screen.dart';
import 'medicine_sales_screen.dart';

class MedicineDashboardScreen extends StatefulWidget {
  const MedicineDashboardScreen({super.key, required this.drawerBuilder});

  final WidgetBuilder drawerBuilder;

  @override
  State<MedicineDashboardScreen> createState() => _MedicineDashboardScreenState();
}

class _MedicineDashboardScreenState extends State<MedicineDashboardScreen> {
  String range = '30D';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: context.isMobile ? Builder(builder: widget.drawerBuilder) : null,
      appBar: context.isDesktop ? null : PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.medPrimary, AppColors.medSecondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            title: const Text('Medicine Dashboard'),
            backgroundColor: Colors.transparent,
            actions: [
              Consumer<MedicineProvider>(
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
        ),
      ),
      body: SafeArea(
        child: ResponsiveContentContainer(
          child: RefreshIndicator(
            onRefresh: () async {
              await context.read<MedicineProvider>().refresh();
              await context.read<SaleProvider>().refresh();
            },
            child: ListView(
              padding: ResponsiveLayout.padding(context),
              children: [
                // Desktop: Show title since no AppBar
                if (context.isDesktop) ...[
                  Text(
                    'Medicine Dashboard',
                    style: ResponsiveTextStyles.headlineLarge(context),
                  ),
                  SizedBox(height: ResponsiveLayout.spacing(context)),
                ],
                // Stats Grid
                Consumer<SaleProvider>(
                  builder: (context, saleProvider, child) {
                    final todaysSales = saleProvider.todaysRevenue;
                    final todaysProfit = saleProvider.todaysProfit;
                    final totalSales = saleProvider.totalRevenue;
                    final totalProfit = saleProvider.totalProfit;

                    return GridView.count(
                      crossAxisCount: ResponsiveLayout.gridCrossAxisCount(
                        context,
                        mobile: 2,
                        tablet: 3,
                        desktop: 3,
                      ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: ResponsiveLayout.spacing(context),
                      mainAxisSpacing: ResponsiveLayout.spacing(context),
                      childAspectRatio: ResponsiveLayout.value(
                        context: context,
                        mobile: 0.95,
                        tablet: 1.1,
                        desktop: 1.3,
                      ),
                      children: [
                        StatCard(
                          icon: Icons.payments,
                          title: "Today's Sales",
                          value: '₹${_formatAmount(todaysSales)}',
                        ),
                        StatCard(
                          icon: Icons.trending_up,
                          title: "Today's Profit",
                          value: '₹${_formatAmount(todaysProfit)}',
                          trend: saleProvider.todaysSalesCount > 0
                              ? '${saleProvider.todaysSalesCount} sales'
                              : null,
                        ),
                        StatCard(
                          icon: Icons.calendar_view_month,
                          title: 'Total Sales',
                          value: '₹${_formatAmount(totalSales)}',
                        ),
                        StatCard(
                          icon: Icons.ssid_chart,
                          title: 'Total Profit',
                          value: '₹${_formatAmount(totalProfit)}',
                        ),
                        StatCard(
                          icon: Icons.percent,
                          title: 'Avg Margin',
                          value: '${saleProvider.averageProfitMargin.toStringAsFixed(1)}%',
                        ),
                        StatCard(
                          icon: Icons.receipt_long,
                          title: 'Total Bills',
                          value: '${saleProvider.totalCount}',
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: ResponsiveLayout.spacing(context)),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: context.isDesktop ? 1 : 0,
                  child: Padding(
                    padding: ResponsiveLayout.cardPadding(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sales Trend',
                          style: ResponsiveTextStyles.headlineSmall(context),
                        ),
                        SizedBox(height: ResponsiveLayout.spacing(context)),
                        ToggleButtons(
                          isSelected: ['7D', '30D', '12M'].map((e) => e == range).toList(),
                          onPressed: (index) => setState(() => range = ['7D', '30D', '12M'][index]),
                          borderRadius: BorderRadius.circular(30),
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: ResponsiveLayout.value(
                                  context: context,
                                  mobile: 16.0,
                                  tablet: 20.0,
                                  desktop: 24.0,
                                ),
                              ),
                              child: const Text('7D'),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: ResponsiveLayout.value(
                                  context: context,
                                  mobile: 16.0,
                                  tablet: 20.0,
                                  desktop: 24.0,
                                ),
                              ),
                              child: const Text('30D'),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: ResponsiveLayout.value(
                                  context: context,
                                  mobile: 16.0,
                                  tablet: 20.0,
                                  desktop: 24.0,
                                ),
                              ),
                              child: const Text('12M'),
                            ),
                          ],
                        ),
                        SizedBox(height: ResponsiveLayout.spacing(context)),
                        SizedBox(
                          height: ResponsiveLayout.value<double>(
                            context: context,
                            mobile: 180.0,
                            tablet: 220.0,
                            desktop: 260.0,
                          ),
                          child: LineChart(
                          LineChartData(
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: [
                                  for (int i = 0; i < mockTrend.length; i++)
                                    FlSpot(i.toDouble(), mockTrend[i] + (range == '7D' ? 40 : 0)),
                                ],
                                isCurved: true,
                                color: AppColors.medSecondary,
                                barWidth: 4,
                                dotData: const FlDotData(show: false),
                              ),
                            ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: ResponsiveLayout.spacing(context)),
                // Stock status cards - using real data
                Consumer<MedicineProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading && provider.allMedicines.isEmpty) {
                      return LoadingShimmer(
                        child: GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.3,
                          children: List.generate(
                            4,
                            (index) => Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    final inStock = provider.allMedicines
                        .where((m) => m.quantity > m.minStockLevel && !m.isExpired)
                        .length;
                    final lowStock = provider.lowStockCount;
                    final expiring = provider.expiringSoonCount;
                    final outOfStock = provider.allMedicines
                        .where((m) => m.quantity <= 0)
                        .length;

                    return ResponsiveLayout.builder(
                      context: context,
                      mobile: (ctx) => GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: ResponsiveLayout.spacing(ctx) * 0.75,
                        mainAxisSpacing: ResponsiveLayout.spacing(ctx) * 0.75,
                        childAspectRatio: 1.3,
                        children: [
                          _StockCard(icon: Icons.inventory_2, label: 'In Stock', value: '$inStock'),
                          _StockCard(icon: Icons.warning_amber, label: 'Low', value: '$lowStock'),
                          _StockCard(icon: Icons.local_fire_department, label: 'Expiring', value: '$expiring'),
                          _StockCard(icon: Icons.block, label: 'Out', value: '$outOfStock'),
                        ],
                      ),
                      desktop: (ctx) => Row(
                        children: [
                          Expanded(child: _StockCard(icon: Icons.inventory_2, label: 'In Stock', value: '$inStock')),
                          SizedBox(width: ResponsiveLayout.spacing(ctx)),
                          Expanded(child: _StockCard(icon: Icons.warning_amber, label: 'Low', value: '$lowStock')),
                          SizedBox(width: ResponsiveLayout.spacing(ctx)),
                          Expanded(child: _StockCard(icon: Icons.local_fire_department, label: 'Expiring', value: '$expiring')),
                          SizedBox(width: ResponsiveLayout.spacing(ctx)),
                          Expanded(child: _StockCard(icon: Icons.block, label: 'Out', value: '$outOfStock')),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(height: ResponsiveLayout.spacing(context)),
                Text(
                  'Alerts & Notifications',
                  style: ResponsiveTextStyles.headlineSmall(context),
                ),
                SizedBox(height: ResponsiveLayout.spacing(context) * 0.75),
                // Dynamic alerts based on real data
                Consumer<MedicineProvider>(
                  builder: (context, provider, child) {
                    final alerts = <_AlertData>[];

                    // Check for expiring medicines
                    final expiringSoon = provider.expiringSoonMedicines;
                    if (expiringSoon.isNotEmpty) {
                      alerts.add(_AlertData(
                        title: '${expiringSoon.length} batches expiring soon',
                        subtitle: 'Check ${expiringSoon.take(3).map((m) => m.name).join(", ")} batches.',
                        color: Colors.orange,
                      ));
                    }

                    // Check for low stock
                    final lowStock = provider.lowStockMedicines;
                    if (lowStock.isNotEmpty) {
                      alerts.add(_AlertData(
                        title: 'Low stock: ${lowStock.first.name}',
                        subtitle: 'Only ${lowStock.first.quantity} ${lowStock.first.unit} left against ${lowStock.first.minStockLevel} min level.',
                        color: Colors.amber,
                      ));
                    }

                    // Check for expired medicines
                    final expired = provider.expiredMedicines;
                    if (expired.isNotEmpty) {
                      alerts.add(_AlertData(
                        title: '${expired.length} medicines expired',
                        subtitle: 'Remove expired items from inventory.',
                        color: Colors.red,
                      ));
                    }

                    if (alerts.isEmpty) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'All Good!',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    Text(
                                      'No alerts at the moment.',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: alerts.map((alert) => Padding(
                        padding: EdgeInsets.only(
                          bottom: ResponsiveLayout.spacing(context) * 0.75,
                        ),
                        child: _AlertCard(alert: alert),
                      )).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: Theme.of(context).colorScheme.primary,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.receipt_long),
            label: 'New Sale',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MedicineSalesScreen()),
            ),
          ),
          SpeedDialChild(
            child: const Icon(Icons.vaccines),
            label: 'Add Medicine',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddMedicineScreen()),
            ),
          ),
          SpeedDialChild(
            child: const Icon(Icons.assignment_turned_in),
            label: 'Stock Check',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MedicineInventoryScreen()),
            ),
          ),
          SpeedDialChild(
            child: const Icon(Icons.analytics),
            label: 'Reports',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MedicineReportsScreen()),
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }
}

class _StockCard extends StatelessWidget {
  const _StockCard({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: context.isDesktop ? 1 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: ResponsiveLayout.cardPadding(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: ResponsiveLayout.iconSize(context),
            ),
            SizedBox(height: ResponsiveLayout.spacing(context) * 0.5),
            Text(
              value,
              style: ResponsiveTextStyles.headlineSmall(context),
            ),
            SizedBox(height: ResponsiveLayout.spacing(context) * 0.25),
            Text(
              label,
              style: ResponsiveTextStyles.bodySmall(context),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertData {
  final String title;
  final String subtitle;
  final Color color;

  _AlertData({
    required this.title,
    required this.subtitle,
    required this.color,
  });
}

class _AlertCard extends StatelessWidget {
  final _AlertData alert;

  const _AlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: alert.color.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 48,
              decoration: BoxDecoration(
                color: alert.color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alert.subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }
}
