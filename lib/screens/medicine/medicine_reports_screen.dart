import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../utils/responsive_layout.dart';
import '../../widgets/chart_card.dart';
import '../../widgets/stat_card.dart';

class MedicineReportsScreen extends StatelessWidget {
  const MedicineReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Medicine Reports'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Daily'),
              Tab(text: 'Monthly'),
              Tab(text: 'Yearly'),
              Tab(text: 'Financial'),
              Tab(text: 'Stock'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _DailyTab(),
            _MonthlyTab(),
            _YearlyTab(),
            _FinancialTab(),
            _StockTab(),
          ],
        ),
      ),
    );
  }
}

class _DailyTab extends StatelessWidget {
  const _DailyTab();

  @override
  Widget build(BuildContext context) {
    return ResponsiveContentContainer(
      child: ListView(
        padding: ResponsiveLayout.padding(context),
        children: [
          FilledButton.tonalIcon(
            onPressed: () {},
            icon: const Icon(Icons.today),
            label: const Text('Select Date'),
          ),
          SizedBox(height: ResponsiveLayout.spacing(context) * 0.75),
          GridView.count(
            crossAxisCount: ResponsiveLayout.gridCrossAxisCount(
              context,
              mobile: 2,
              tablet: 2,
              desktop: 4,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: ResponsiveLayout.spacing(context) * 0.75,
            crossAxisSpacing: ResponsiveLayout.spacing(context) * 0.75,
            childAspectRatio: ResponsiveLayout.value(
              context: context,
              mobile: 0.95, // Fixed aspect ratio
              tablet: 1.05,
              desktop: 1.2,
            ),
          children: const [
            StatCard(icon: Icons.payments, title: 'Sales', value: '₹88k'),
            StatCard(icon: Icons.auto_graph, title: 'Profit', value: '₹22k'),
            StatCard(icon: Icons.shopping_basket, title: 'Bills', value: '32'),
            StatCard(icon: Icons.trending_up, title: 'Avg ticket', value: '₹2.7k'),
          ],
        ),
        const SizedBox(height: 12),
        ChartCard(
          title: 'Top Medicines',
          chart: BarChart(
            BarChartData(
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(show: false),
              barGroups: [
                for (int i = 0; i < 5; i++)
                  BarChartGroupData(x: i, barRods: [BarChartRodData(toY: (i + 2) * 10.0)])
              ],
            ),
            ),
          ),
          SizedBox(height: ResponsiveLayout.spacing(context) * 0.75),
          ChartCard(
            title: 'Category Split',
          chart: PieChart(
            PieChartData(
              sections: [
                for (int i = 0; i < mockCategorySeries.length; i++)
                  PieChartSectionData(
                    value: mockCategorySeries[i].value,
                    color: Colors.primaries[i % Colors.primaries.length],
                    title: mockCategorySeries[i].label.substring(0, 2),
                  ),
              ],
              ),
            ),
          ),
          SizedBox(height: ResponsiveLayout.spacing(context) * 0.75),
          ChartCard(
            title: 'Hourly Sales',
            chart: LineChart(
            LineChartData(
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(show: false),
              lineBarsData: [
                LineChartBarData(
                  isCurved: true,
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

class _MonthlyTab extends StatelessWidget {
  const _MonthlyTab();

  @override
  Widget build(BuildContext context) {
    return ResponsiveContentContainer(
      child: ListView(
        padding: ResponsiveLayout.padding(context),
        children: [
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.calendar_month),
            label: const Text('Pick Month'),
          ),
          SizedBox(height: ResponsiveLayout.spacing(context) * 0.75),
          ChartCard(
          title: 'Sales Trend',
          chart: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  color: Colors.blue,
                  spots: [for (int i = 0; i < 30; i++) FlSpot(i.toDouble(), (i % 6 + 1) * 10)],
                  isCurved: true,
                ),
                LineChartBarData(
                  color: Colors.green,
                  spots: [for (int i = 0; i < 30; i++) FlSpot(i.toDouble(), (5 - (i % 5)) * 8)],
                  isCurved: true,
                ),
              ],
              titlesData: FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
            ),
            ),
          ),
          SizedBox(height: ResponsiveLayout.spacing(context) * 0.75),
          GridView.count(
            crossAxisCount: ResponsiveLayout.gridCrossAxisCount(
              context,
              mobile: 2,
              tablet: 2,
              desktop: 4,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: ResponsiveLayout.value(
              context: context,
              mobile: 0.95,
              tablet: 1.05,
              desktop: 1.2,
            ),
            mainAxisSpacing: ResponsiveLayout.spacing(context) * 0.75,
            crossAxisSpacing: ResponsiveLayout.spacing(context) * 0.75,
            children: const [
              StatCard(icon: Icons.timeline, title: 'Growth', value: '+18%'),
              StatCard(icon: Icons.shopping_cart_checkout, title: 'Orders', value: '640'),
              StatCard(icon: Icons.people, title: 'Customers', value: '210'),
              StatCard(icon: Icons.compare, title: 'vs LY', value: '+9%'),
            ],
          ),
        const SizedBox(height: 12),
        DataTable(
          columns: const [
            DataColumn(label: Text('Medicine')),
            DataColumn(label: Text('Qty')),
            DataColumn(label: Text('Value')),
          ],
          rows: mockMedicines.take(5).map(
            (medicine) => DataRow(cells: [
              DataCell(Text(medicine.name)),
              DataCell(Text('${medicine.quantity ~/ 3}')),
                DataCell(Text('₹${(medicine.sellingPrice * 20).toStringAsFixed(0)}')),
              ]),
            ).toList(),
          ),
        ],
      ),
    );
  }
}

class _YearlyTab extends StatelessWidget {
  const _YearlyTab();

  @override
  Widget build(BuildContext context) {
    return ResponsiveContentContainer(
      child: ListView(
        padding: ResponsiveLayout.padding(context),
        children: [
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.date_range_outlined),
          label: const Text('2025'),
        ),
        const SizedBox(height: 12),
        ChartCard(
          title: 'Monthly Sales',
          chart: BarChart(
            BarChartData(
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(show: false),
              barGroups: [
                for (int i = 0; i < 12; i++)
                  BarChartGroupData(x: i, barRods: [BarChartRodData(toY: (i + 4).toDouble() * 10)])
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        ChartCard(
          title: 'Profit Overlay',
          chart: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  color: Colors.orange,
                  spots: [for (int i = 0; i < 12; i++) FlSpot(i.toDouble(), (12 - i) * 5)],
                ),
              ],
              titlesData: FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FinancialTab extends StatelessWidget {
  const _FinancialTab();

  @override
  Widget build(BuildContext context) {
    return ResponsiveContentContainer(
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
            childAspectRatio: ResponsiveLayout.value(
              context: context,
              mobile: 0.95,
              tablet: 1.05,
              desktop: 1.2,
            ),
            mainAxisSpacing: ResponsiveLayout.spacing(context) * 0.75,
            crossAxisSpacing: ResponsiveLayout.spacing(context) * 0.75,
          children: const [
            StatCard(icon: Icons.shopping_bag_outlined, title: 'Purchases', value: '₹1.2Cr'),
            StatCard(icon: Icons.attach_money, title: 'Sales', value: '₹2.1Cr'),
            StatCard(icon: Icons.percent, title: 'Margin', value: '38%'),
            StatCard(icon: Icons.warehouse, title: 'Inventory value', value: '₹48L'),
          ],
        ),
        const SizedBox(height: 12),
        ChartCard(
          title: 'Category Margin',
          chart: BarChart(
            BarChartData(
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(show: false),
              barGroups: [
                for (int i = 0; i < 5; i++)
                  BarChartGroupData(x: i, barRods: [BarChartRodData(toY: 20 + i * 5)])
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StockTab extends StatelessWidget {
  const _StockTab();

  @override
  Widget build(BuildContext context) {
    return ResponsiveContentContainer(
      child: ListView(
        padding: ResponsiveLayout.padding(context),
      children: [
        SegmentedButton<String>(
          multiSelectionEnabled: false,
          segments: const [
            ButtonSegment(value: 'All', label: Text('All')),
            ButtonSegment(value: 'Low', label: Text('Low')),
            ButtonSegment(value: 'Out', label: Text('Out')),
            ButtonSegment(value: 'Over', label: Text('Over')),
          ],
          selected: const {'All'},
          onSelectionChanged: (_) {},
        ),
        const SizedBox(height: 12),
        DataTable(
          columns: const [
            DataColumn(label: Text('Batch')),
            DataColumn(label: Text('Qty')),
            DataColumn(label: Text('Expiry')),
          ],
          rows: mockMedicines.take(6).map(
            (medicine) => DataRow(cells: [
              DataCell(Text(medicine.batchNo)),
              DataCell(Text('${medicine.quantity} ${medicine.unit}')),
                DataCell(Text(medicine.expiryDate)),
              ]),
            ).toList(),
          ),
        ],
      ),
    );
  }
}
