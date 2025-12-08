import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../../data/mock_data.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive_layout.dart';
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
          ),
        ),
      ),
      body: SafeArea(
        child: ResponsiveContentContainer(
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
              GridView.count(
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
                  mobile: 0.95, // Fixed: was 1.05, now 0.95
                  tablet: 1.1,
                  desktop: 1.3,
                ),
              children: const [
                StatCard(icon: Icons.payments, title: "Today's Sales", value: '₹88,000'),
                StatCard(icon: Icons.trending_up, title: "Today's Profit", value: '₹22,400', trend: '+12%'),
                StatCard(icon: Icons.calendar_view_month, title: 'Monthly Sales', value: '₹18.2L'),
                StatCard(icon: Icons.ssid_chart, title: 'Monthly Profit', value: '₹4.3L'),
                StatCard(icon: Icons.calendar_month, title: 'Yearly Sales', value: '₹2.1Cr'),
                StatCard(icon: Icons.auto_graph, title: 'Yearly Profit', value: '₹54L'),
                ],
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
              // Responsive stock cards - wrap for mobile, row for desktop
              ResponsiveLayout.builder(
                context: context,
                mobile: (ctx) => GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: ResponsiveLayout.spacing(ctx) * 0.75,
                  mainAxisSpacing: ResponsiveLayout.spacing(ctx) * 0.75,
                  childAspectRatio: 1.3,
                  children: const [
                    _StockCard(icon: Icons.inventory_2, label: 'In Stock', value: '1285'),
                    _StockCard(icon: Icons.warning_amber, label: 'Low', value: '48'),
                    _StockCard(icon: Icons.local_fire_department, label: 'Expiring', value: '16'),
                    _StockCard(icon: Icons.block, label: 'Out', value: '6'),
                  ],
                ),
                desktop: (ctx) => Row(
                  children: [
                    const Expanded(child: _StockCard(icon: Icons.inventory_2, label: 'In Stock', value: '1285')),
                    SizedBox(width: ResponsiveLayout.spacing(ctx)),
                    const Expanded(child: _StockCard(icon: Icons.warning_amber, label: 'Low', value: '48')),
                    SizedBox(width: ResponsiveLayout.spacing(ctx)),
                    const Expanded(child: _StockCard(icon: Icons.local_fire_department, label: 'Expiring', value: '16')),
                    SizedBox(width: ResponsiveLayout.spacing(ctx)),
                    const Expanded(child: _StockCard(icon: Icons.block, label: 'Out', value: '6')),
                  ],
                ),
              ),
              SizedBox(height: ResponsiveLayout.spacing(context)),
              Text(
                'Alerts & Notifications',
                style: ResponsiveTextStyles.headlineSmall(context),
              ),
              SizedBox(height: ResponsiveLayout.spacing(context) * 0.75),
              ...mockAlerts.map(
                (alert) => Padding(
                  padding: EdgeInsets.only(
                    bottom: ResponsiveLayout.spacing(context) * 0.75,
                  ),
                  child: AlertCard(alert: alert),
                ),
              ),
            ],
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
