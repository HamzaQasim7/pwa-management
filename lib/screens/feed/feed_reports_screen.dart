import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../utils/responsive_layout.dart';
import '../../widgets/chart_card.dart';
import '../../widgets/stat_card.dart';

class FeedReportsScreen extends StatelessWidget {
  const FeedReportsScreen({super.key});

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
                const SnackBar(content: Text('Export queued (mock).')),
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
        body: TabBarView(
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
  @override
  Widget build(BuildContext context) {
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
              mobile: 0.95, // Fixed aspect ratio
              tablet: 1.1,
              desktop: 1.2,
            ),
          children: const [
            StatCard(icon: Icons.attach_money, title: 'Revenue', value: '₹8.4L'),
            StatCard(icon: Icons.shopping_bag, title: 'Orders', value: '134'),
            StatCard(icon: Icons.people_alt, title: 'Customers', value: '56'),
            StatCard(icon: Icons.inventory, title: 'Avg. Fill Rate', value: '92%'),
            ],
          ),
          SizedBox(height: ResponsiveLayout.spacing(context)),
          ChartCard(
          title: 'Contribution',
          chart: PieChart(
            PieChartData(
              sections: [
                for (int i = 0; i < mockSummarySeries.length; i++)
                  PieChartSectionData(
                    value: mockSummarySeries[i].value,
                    color: Colors.primaries[i % Colors.primaries.length],
                    title: '${mockSummarySeries[i].value.toStringAsFixed(0)}%',
                  ),
              ],
            ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                      if (index >= mockCategorySeries.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(mockCategorySeries[index].label,
                            style: const TextStyle(fontSize: 12)),
                      );
                    },
                  ),
                ),
              ),
              barGroups: [
                for (int i = 0; i < mockCategorySeries.length; i++)
                  BarChartGroupData(x: i, barRods: [
                    BarChartRodData(toY: mockCategorySeries[i].value, width: 18),
                  ]),
              ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
              rows: mockCustomers
                  .map(
                    (customer) => DataRow(
                      cells: [
                        DataCell(Text(customer.name)),
                        DataCell(Text((customer.balance / 10000).abs().toStringAsFixed(0))),
                        DataCell(Text('₹${(customer.balance.abs() + 50000).toStringAsFixed(0)}')),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfitTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ResponsiveContentContainer(
      child: ListView(
        padding: ResponsiveLayout.padding(context),
        children: [
          ChartCard(
            title: 'Weekly Profit Trend',
            chart: LineChart(
              LineChartData(
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    color: Theme.of(context).colorScheme.primary,
                    barWidth: 4,
                    spots: [
                      for (int i = 0; i < mockTrend.length; i++)
                        FlSpot(i.toDouble(), mockTrend[i]),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
