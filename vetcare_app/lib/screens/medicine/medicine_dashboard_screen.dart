import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../../data/mock_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/alert_card.dart';
import '../../widgets/stat_card.dart';
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
      drawer: Builder(builder: widget.drawerBuilder),
      appBar: PreferredSize(
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
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.05,
              children: const [
                StatCard(icon: Icons.payments, title: "Today's Sales", value: '₹88,000'),
                StatCard(icon: Icons.trending_up, title: "Today's Profit", value: '₹22,400', trend: '+12%'),
                StatCard(icon: Icons.calendar_view_month, title: 'Monthly Sales', value: '₹18.2L'),
                StatCard(icon: Icons.ssid_chart, title: 'Monthly Profit', value: '₹4.3L'),
                StatCard(icon: Icons.calendar_month, title: 'Yearly Sales', value: '₹2.1Cr'),
                StatCard(icon: Icons.auto_graph, title: 'Yearly Profit', value: '₹54L'),
              ],
            ),
            const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ToggleButtons(
                      isSelected: ['7D', '30D', '12M'].map((e) => e == range).toList(),
                      onPressed: (index) => setState(() => range = ['7D', '30D', '12M'][index]),
                      borderRadius: BorderRadius.circular(30),
                      children: const [
                        Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('7D')),
                        Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('30D')),
                        Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('12M')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 180,
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
            const SizedBox(height: 20),
            Row(
              children: const [
                Expanded(child: _StockCard(icon: Icons.inventory_2, label: 'In Stock', value: '1285')), 
                SizedBox(width: 12),
                Expanded(child: _StockCard(icon: Icons.warning_amber, label: 'Low', value: '48')),
                SizedBox(width: 12),
                Expanded(child: _StockCard(icon: Icons.local_fire_department, label: 'Expiring', value: '16')),
                SizedBox(width: 12),
                Expanded(child: _StockCard(icon: Icons.block, label: 'Out', value: '6')),
              ],
            ),
            const SizedBox(height: 20),
            ...mockAlerts.map(
              (alert) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AlertCard(alert: alert),
              ),
            ),
          ],
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

  void _toast(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label coming soon.')));
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
