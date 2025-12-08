import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../presentation/providers/medicine_provider.dart';
import '../../presentation/providers/sale_provider.dart';
import '../../utils/responsive_layout.dart';
import '../../widgets/chart_card.dart';
import '../../widgets/stat_card.dart';

class MedicineReportsScreen extends StatefulWidget {
  const MedicineReportsScreen({super.key});

  @override
  State<MedicineReportsScreen> createState() => _MedicineReportsScreenState();
}

class _MedicineReportsScreenState extends State<MedicineReportsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MedicineProvider>().loadMedicines();
      context.read<SaleProvider>().loadSales();
    });
  }

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
    return Consumer2<SaleProvider, MedicineProvider>(
      builder: (context, saleProvider, medicineProvider, child) {
        final todaysSales = saleProvider.todaysRevenue;
        final todaysProfit = saleProvider.todaysProfit;
        final todaysBills = saleProvider.todaysSalesCount;
        final avgTicket = todaysBills > 0 ? todaysSales / todaysBills : 0.0;

        // Category data from medicines
        final categories = <String, double>{};
        for (final medicine in medicineProvider.allMedicines) {
          categories[medicine.category] =
              (categories[medicine.category] ?? 0) + medicine.sellingPrice;
        }

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
                  mobile: 0.95,
                  tablet: 1.05,
                  desktop: 1.2,
                ),
                children: [
                  StatCard(
                    icon: Icons.payments,
                    title: 'Sales',
                    value: 'Rs ${_formatValue(todaysSales)}',
                  ),
                  StatCard(
                    icon: Icons.auto_graph,
                    title: 'Profit',
                    value: 'Rs ${_formatValue(todaysProfit)}',
                  ),
                  StatCard(
                    icon: Icons.shopping_basket,
                    title: 'Bills',
                    value: '$todaysBills',
                  ),
                  StatCard(
                    icon: Icons.trending_up,
                    title: 'Avg ticket',
                    value: 'Rs ${_formatValue(avgTicket)}',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ChartCard(
                title: 'Top Medicines',
                chart: BarChart(
                  BarChartData(
                    borderData: FlBorderData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    barGroups: [
                      for (int i = 0; i < 5; i++)
                        BarChartGroupData(
                          x: i,
                          barRods: [BarChartRodData(toY: (i + 2) * 10.0)],
                        )
                    ],
                  ),
                ),
              ),
              SizedBox(height: ResponsiveLayout.spacing(context) * 0.75),
              ChartCard(
                title: 'Category Split',
                chart: PieChart(
                  PieChartData(
                    sections: categories.entries.take(5).toList().asMap().entries.map((entry) {
                      return PieChartSectionData(
                        value: entry.value.value,
                        color: Colors.primaries[entry.key % Colors.primaries.length],
                        title: entry.value.key.substring(0, 2),
                      );
                    }).toList(),
                  ),
                ),
              ),
              SizedBox(height: ResponsiveLayout.spacing(context) * 0.75),
              ChartCard(
                title: 'Hourly Sales',
                chart: LineChart(
                  LineChartData(
                    borderData: FlBorderData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: true,
                        spots: [
                          for (int i = 0; i < 12; i++)
                            FlSpot(i.toDouble(), ((i * 3 + 5) % 15 + 2).toDouble()),
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

  String _formatValue(double value) {
    if (value >= 100000) return '${(value / 100000).toStringAsFixed(1)}L';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}k';
    return value.toStringAsFixed(0);
  }
}

class _MonthlyTab extends StatelessWidget {
  const _MonthlyTab();

  @override
  Widget build(BuildContext context) {
    return Consumer2<SaleProvider, MedicineProvider>(
      builder: (context, saleProvider, medicineProvider, child) {
        final totalSales = saleProvider.totalRevenue;
        final totalOrders = saleProvider.totalCount;
        final medicines = medicineProvider.allMedicines.take(5).toList();

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
                        spots: [
                          for (int i = 0; i < 30; i++)
                            FlSpot(i.toDouble(), (i % 6 + 1) * 10)
                        ],
                        isCurved: true,
                      ),
                      LineChartBarData(
                        color: Colors.green,
                        spots: [
                          for (int i = 0; i < 30; i++)
                            FlSpot(i.toDouble(), (5 - (i % 5)) * 8)
                        ],
                        isCurved: true,
                      ),
                    ],
                    titlesData: const FlTitlesData(show: false),
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
                children: [
                  StatCard(
                    icon: Icons.timeline,
                    title: 'Growth',
                    value: '+${(saleProvider.averageProfitMargin).toStringAsFixed(0)}%',
                  ),
                  StatCard(
                    icon: Icons.shopping_cart_checkout,
                    title: 'Orders',
                    value: '$totalOrders',
                  ),
                  StatCard(
                    icon: Icons.people,
                    title: 'Medicines',
                    value: '${medicineProvider.totalCount}',
                  ),
                  StatCard(
                    icon: Icons.compare,
                    title: 'Revenue',
                    value: 'Rs ${_formatValue(totalSales)}',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (medicines.isNotEmpty)
                DataTable(
                  columns: const [
                    DataColumn(label: Text('Medicine')),
                    DataColumn(label: Text('Qty')),
                    DataColumn(label: Text('Value')),
                  ],
                  rows: medicines
                      .map(
                        (medicine) => DataRow(cells: [
                          DataCell(Text(medicine.name)),
                          DataCell(Text('${medicine.quantity}')),
                          DataCell(Text(
                              'Rs ${(medicine.sellingPrice * medicine.quantity).toStringAsFixed(0)}')),
                        ]),
                      )
                      .toList(),
                ),
            ],
          ),
        );
      },
    );
  }

  String _formatValue(double value) {
    if (value >= 10000000) return '${(value / 10000000).toStringAsFixed(1)}Cr';
    if (value >= 100000) return '${(value / 100000).toStringAsFixed(1)}L';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}k';
    return value.toStringAsFixed(0);
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
                titlesData: const FlTitlesData(show: false),
                barGroups: [
                  for (int i = 0; i < 12; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [BarChartRodData(toY: (i + 4).toDouble() * 10)],
                    )
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
                    spots: [
                      for (int i = 0; i < 12; i++)
                        FlSpot(i.toDouble(), (12 - i) * 5)
                    ],
                  ),
                ],
                titlesData: const FlTitlesData(show: false),
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
    return Consumer2<SaleProvider, MedicineProvider>(
      builder: (context, saleProvider, medicineProvider, child) {
        final totalSales = saleProvider.totalRevenue;
        final inventoryValue = medicineProvider.totalStockValueAtSale;
        final margin = saleProvider.averageProfitMargin;

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
                children: [
                  StatCard(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Purchases',
                    value: 'Rs ${_formatValue(medicineProvider.totalStockValueAtCost)}',
                  ),
                  StatCard(
                    icon: Icons.attach_money,
                    title: 'Sales',
                    value: 'Rs ${_formatValue(totalSales)}',
                  ),
                  StatCard(
                    icon: Icons.percent,
                    title: 'Margin',
                    value: '${margin.toStringAsFixed(0)}%',
                  ),
                  StatCard(
                    icon: Icons.warehouse,
                    title: 'Inventory value',
                    value: 'Rs ${_formatValue(inventoryValue)}',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ChartCard(
                title: 'Category Margin',
                chart: BarChart(
                  BarChartData(
                    borderData: FlBorderData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    barGroups: [
                      for (int i = 0; i < 5; i++)
                        BarChartGroupData(
                          x: i,
                          barRods: [BarChartRodData(toY: 20 + i * 5)],
                        )
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

  String _formatValue(double value) {
    if (value >= 10000000) return '${(value / 10000000).toStringAsFixed(1)}Cr';
    if (value >= 100000) return '${(value / 100000).toStringAsFixed(0)}L';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}k';
    return value.toStringAsFixed(0);
  }
}

class _StockTab extends StatefulWidget {
  const _StockTab();

  @override
  State<_StockTab> createState() => _StockTabState();
}

class _StockTabState extends State<_StockTab> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    return Consumer<MedicineProvider>(
      builder: (context, provider, child) {
        var medicines = provider.allMedicines;

        // Apply filter
        switch (_filter) {
          case 'Low':
            medicines = medicines.where((m) => m.isLowStock && m.quantity > 0).toList();
            break;
          case 'Out':
            medicines = medicines.where((m) => m.quantity <= 0).toList();
            break;
          case 'Over':
            medicines = medicines.where((m) => m.quantity > m.minStockLevel * 3).toList();
            break;
        }

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
                selected: {_filter},
                onSelectionChanged: (value) => setState(() => _filter = value.first),
              ),
              const SizedBox(height: 12),
              if (provider.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (medicines.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('No medicines found for this filter'),
                  ),
                )
              else
                DataTable(
                  columns: const [
                    DataColumn(label: Text('Batch')),
                    DataColumn(label: Text('Qty')),
                    DataColumn(label: Text('Expiry')),
                  ],
                  rows: medicines.take(10).map(
                    (medicine) => DataRow(cells: [
                      DataCell(Text(medicine.batchNo)),
                      DataCell(Text('${medicine.quantity} ${medicine.unit}')),
                      DataCell(Text(
                        '${medicine.expiryDate.day}/${medicine.expiryDate.month}/${medicine.expiryDate.year}',
                      )),
                    ]),
                  ).toList(),
                ),
            ],
          ),
        );
      },
    );
  }
}
