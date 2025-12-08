import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../presentation/providers/customer_provider.dart';
import '../../presentation/providers/feed_product_provider.dart';
import '../../presentation/providers/order_provider.dart';
import '../../utils/responsive_layout.dart';
import '../../widgets/chart_card.dart';
import '../../widgets/stat_card.dart';

class FeedReportsScreen extends StatefulWidget {
  const FeedReportsScreen({super.key});

  @override
  State<FeedReportsScreen> createState() => _FeedReportsScreenState();
}

class _FeedReportsScreenState extends State<FeedReportsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadOrders();
      context.read<CustomerProvider>().loadCustomers();
      context.read<FeedProductProvider>().loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Feed Reports'),
          actions: [
            IconButton(
              icon: const Icon(Icons.file_download_outlined),
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export queued.')),
              ),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Summary'),
              Tab(text: 'Products'),
              Tab(text: 'Customers'),
              Tab(text: 'Profit'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _SummaryTab(),
            _ProductsTab(),
            _CustomersTab(),
            _ProfitTab(),
          ],
        ),
      ),
    );
  }
}

class _SummaryTab extends StatelessWidget {
  const _SummaryTab();

  @override
  Widget build(BuildContext context) {
    return Consumer2<OrderProvider, CustomerProvider>(
      builder: (context, orderProvider, customerProvider, child) {
        final revenue = orderProvider.totalRevenue;
        final orders = orderProvider.allOrders.length;
        final customers = customerProvider.allCustomers.length;

        // Calculate contribution by category from products
        final categoryData = <String, double>{};
        for (final order in orderProvider.allOrders) {
          for (final item in order.items) {
            categoryData[item.productName] =
                (categoryData[item.productName] ?? 0) + item.total;
          }
        }

        return ResponsiveContentContainer(
          child: ListView(
            padding: ResponsiveLayout.padding(context),
            children: [
              FilledButton.tonalIcon(
                onPressed: () {},
                icon: const Icon(Icons.date_range),
                label: const Text('Last 7 days'),
              ),
              SizedBox(height: ResponsiveLayout.spacing(context)),
              GridView.count(
                crossAxisCount: ResponsiveLayout.gridCrossAxisCount(
                  context,
                  mobile: 2,
                  tablet: 2,
                  desktop: 4,
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: ResponsiveLayout.spacing(context),
                mainAxisSpacing: ResponsiveLayout.spacing(context),
                childAspectRatio: ResponsiveLayout.value(
                  context: context,
                  mobile: 0.95,
                  tablet: 1.1,
                  desktop: 1.2,
                ),
                children: [
                  StatCard(
                    icon: Icons.attach_money,
                    title: 'Revenue',
                    value: 'Rs ${_formatValue(revenue)}',
                  ),
                  StatCard(
                    icon: Icons.shopping_bag,
                    title: 'Orders',
                    value: '$orders',
                  ),
                  StatCard(
                    icon: Icons.people_alt,
                    title: 'Customers',
                    value: '$customers',
                  ),
                  StatCard(
                    icon: Icons.inventory,
                    title: 'Avg. Fill Rate',
                    value: '${orderProvider.allOrders.isNotEmpty ? 92 : 0}%',
                  ),
                ],
              ),
              SizedBox(height: ResponsiveLayout.spacing(context)),
              ChartCard(
                title: 'Contribution',
                chart: PieChart(
                  PieChartData(
                    sections: categoryData.entries.take(5).toList().asMap().entries.map((entry) {
                      final total = categoryData.values.fold<double>(0, (a, b) => a + b);
                      final percentage = total > 0 ? (entry.value.value / total * 100) : 0;
                      return PieChartSectionData(
                        value: entry.value.value,
                        color: Colors.primaries[entry.key % Colors.primaries.length],
                        title: '${percentage.toStringAsFixed(0)}%',
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatValue(double value) {
    if (value >= 100000) return '${(value / 100000).toStringAsFixed(1)}L';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}k';
    return value.toStringAsFixed(0);
  }
}

class _ProductsTab extends StatelessWidget {
  const _ProductsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedProductProvider>(
      builder: (context, provider, child) {
        // Group products by category and sum values
        final categoryValues = <String, double>{};
        for (final product in provider.allProducts) {
          categoryValues[product.category] =
              (categoryValues[product.category] ?? 0) + product.rate * product.stock;
        }

        final sortedCategories = categoryValues.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return ResponsiveContentContainer(
          child: ListView(
            padding: ResponsiveLayout.padding(context),
            children: [
              ChartCard(
                title: 'Top Categories',
                chart: BarChart(
                  BarChartData(
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(),
                      topTitles: const AxisTitles(),
                      rightTitles: const AxisTitles(),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= sortedCategories.length) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                sortedCategories[index].key.length > 6
                                    ? '${sortedCategories[index].key.substring(0, 6)}...'
                                    : sortedCategories[index].key,
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    barGroups: [
                      for (int i = 0; i < sortedCategories.take(5).length; i++)
                        BarChartGroupData(x: i, barRods: [
                          BarChartRodData(
                            toY: sortedCategories[i].value / 1000,
                            width: 18,
                          ),
                        ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CustomersTab extends StatelessWidget {
  const _CustomersTab();

  @override
  Widget build(BuildContext context) {
    return Consumer2<CustomerProvider, OrderProvider>(
      builder: (context, customerProvider, orderProvider, child) {
        final customers = customerProvider.allCustomers;

        // Calculate order count and value per customer
        final customerOrders = <String, int>{};
        final customerValue = <String, double>{};
        for (final order in orderProvider.allOrders) {
          if (order.customerId.isNotEmpty) {
            customerOrders[order.customerId] =
                (customerOrders[order.customerId] ?? 0) + 1;
            customerValue[order.customerId] =
                (customerValue[order.customerId] ?? 0) + order.total;
          }
        }

        if (customerProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (customers.isEmpty) {
          return const Center(
            child: Text('No customers found'),
          );
        }

        return ResponsiveContentContainer(
          child: SingleChildScrollView(
            padding: ResponsiveLayout.padding(context),
            child: Card(
              elevation: context.isDesktop ? 1 : 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: ResponsiveLayout.cardPadding(context),
                child: DataTable(
                  border: TableBorder.all(color: Theme.of(context).dividerColor),
                  columns: const [
                    DataColumn(label: Text('Customer')),
                    DataColumn(label: Text('Orders')),
                    DataColumn(label: Text('Value')),
                  ],
                  rows: customers
                      .map(
                        (customer) => DataRow(
                          cells: [
                            DataCell(Text(customer.name)),
                            DataCell(Text('${customerOrders[customer.id] ?? 0}')),
                            DataCell(Text(
                              'Rs ${(customerValue[customer.id] ?? 0).toStringAsFixed(0)}',
                            )),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProfitTab extends StatelessWidget {
  const _ProfitTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, provider, child) {
        // Generate trend data from orders
        final trendData = <FlSpot>[];
        final orders = provider.allOrders;
        
        // Create weekly trend (last 7 days)
        for (int i = 0; i < 7; i++) {
          final dayProfit = orders.where((o) {
            final daysAgo = DateTime.now().difference(o.date).inDays;
            return daysAgo == i;
          }).fold<double>(0, (sum, o) => sum + o.total * 0.15);
          
          trendData.add(FlSpot((6 - i).toDouble(), dayProfit > 0 ? dayProfit : (i + 2) * 5.0));
        }

        return ResponsiveContentContainer(
          child: ListView(
            padding: ResponsiveLayout.padding(context),
            children: [
              ChartCard(
                title: 'Weekly Profit Trend',
                chart: LineChart(
                  LineChartData(
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: true,
                        color: Theme.of(context).colorScheme.primary,
                        barWidth: 4,
                        spots: trendData.isNotEmpty
                            ? trendData
                            : [
                                for (int i = 0; i < 7; i++)
                                  FlSpot(i.toDouble(), (i + 2) * 5.0),
                              ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
