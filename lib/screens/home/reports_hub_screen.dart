import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../utils/responsive_layout.dart';
import '../../widgets/dashboard/modern_stat_card.dart';
import '../../widgets/dashboard/module_report_card.dart';
import '../../widgets/stat_card.dart';
import '../feed/feed_reports_screen.dart';
import '../medicine/medicine_reports_screen.dart';

class ReportsHubScreen extends StatelessWidget {
  const ReportsHubScreen({super.key, required this.drawerBuilder});

  final WidgetBuilder drawerBuilder;

  void _open(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: context.isMobile ? Builder(builder: drawerBuilder) : null,
      appBar: context.isDesktop ? null : AppBar(
        title: const Text('Reports Center'),
      ),
      body: SafeArea(
        child: ResponsiveContentContainer(
          child: ListView(
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
                      childAspectRatio: 2.0, // Adjusted for 130px height (260px width / 130px height)
                      children: const [
                        ModernStatCard(
                          label: 'Feed Revenue',
                          value: '₹8.4L',
                          icon: Icons.grass,
                          trend: 'up',
                          trendValue: '+15%',
                          comparison: 'vs last month: ₹7.3L',
                          progress: 0.84,
                          module: 'feed',
                        ),
                        ModernStatCard(
                          label: 'Pharmacy Revenue',
                          value: '₹9.7L',
                          icon: Icons.medical_services,
                          trend: 'up',
                          trendValue: '+12%',
                          comparison: 'vs last month: ₹8.7L',
                          progress: 0.91,
                          module: 'medicine',
                        ),
                        ModernStatCard(
                          label: 'Total Customers',
                          value: '423',
                          icon: Icons.people,
                          trend: 'up',
                          trendValue: '+23',
                          comparison: 'vs last month: 400',
                          progress: 0.70,
                          module: 'customers',
                        ),
                        ModernStatCard(
                          label: 'Profit Margin',
                          value: '37%',
                          icon: Icons.trending_up,
                          trend: 'up',
                          trendValue: '+2%',
                          comparison: 'vs last month: 35%',
                          progress: 0.74,
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
                      childAspectRatio: 0.95, // Fixed: was 1.05, now 0.95
                      children: const [
                        StatCard(icon: Icons.storefront, title: 'Feed Revenue', value: '₹8.4L'),
                        StatCard(icon: Icons.local_hospital, title: 'Pharmacy Revenue', value: '₹9.7L'),
                        StatCard(icon: Icons.people_alt, title: 'Customers', value: '423'),
                        StatCard(icon: Icons.stacked_bar_chart, title: 'Profitability', value: '37%'),
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
                quickStats: const [
                  QuickStat(icon: Icons.bar_chart, value: '234 reports'),
                  QuickStat(icon: Icons.attach_money, value: '₹8.4L'),
                  QuickStat(icon: Icons.people, value: '156 customers'),
                ],
                onTap: () => _open(context, const FeedReportsScreen()),
              ),
              
              SizedBox(height: ResponsiveLayout.spacing(context)),
              
              ModuleReportCard(
                title: 'Medicine & Pharmacy Reports',
                subtitle: 'Daily to yearly analytics with financial breakdowns',
                icon: Icons.medical_services,
                module: 'medicine',
                quickStats: const [
                  QuickStat(icon: Icons.analytics, value: '567 reports'),
                  QuickStat(icon: Icons.monetization_on, value: '₹9.7L'),
                  QuickStat(icon: Icons.inventory, value: '1,285 items'),
                ],
                onTap: () => _open(context, const MedicineReportsScreen()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
