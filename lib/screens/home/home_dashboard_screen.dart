import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart' as modern;
import '../../data/mock_data.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive_layout.dart';
import '../../widgets/dashboard/modern_stat_card.dart';
import '../../widgets/stat_card.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key, required this.drawerBuilder});

  final WidgetBuilder drawerBuilder;

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  bool showFeed = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      // Only show drawer on mobile (desktop has permanent sidebar)
      drawer: context.isMobile ? Builder(builder: widget.drawerBuilder) : null,
      appBar: context.isDesktop ? null : AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(
                showFeed ? feedLogoUrl : medicineLogoUrl,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Aftab Distributors',
                      style: Theme.of(context).textTheme.titleMedium),
                  Text('Premium feed & pharmacy',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notifications from drawer.')),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveContentContainer(
          child: ListView(
            padding: ResponsiveLayout.padding(context),
            children: [
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('Feed Dashboard')),
                ButtonSegment(value: false, label: Text('Medicine Dashboard')),
              ],
              selected: {showFeed},
              onSelectionChanged: (value) =>
                  setState(() => showFeed = value.first),
            ),
            SizedBox(height: ResponsiveLayout.spacing(context)),
            Text(
              showFeed ? 'Today in Feed' : 'Today in Pharmacy',
              style: ResponsiveTextStyles.headlineMedium(context),
            ),
            SizedBox(height: ResponsiveLayout.spacing(context)),
              // Modern Stat Cards on Desktop, Classic on Mobile
              context.isDesktop
                  ? GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: ResponsiveLayout.spacing(context),
                      crossAxisSpacing: ResponsiveLayout.spacing(context),
                      childAspectRatio: 1.35, // Adjusted to 1.35 for proper height (280/200)
                      children: [
                        ModernStatCard(
                          label: "Today's Sales",
                          value: showFeed ? '₹1.25L' : '₹88K',
                          icon: Icons.attach_money,
                          trend: 'up',
                          trendValue: '+12%',
                          comparison: 'vs yesterday: ${showFeed ? "₹1.1L" : "₹79K"}',
                          progress: 0.75,
                          module: showFeed ? 'feed' : 'medicine',
                        ),
                        ModernStatCard(
                          label: showFeed ? 'Orders' : 'Bills',
                          value: showFeed ? '23' : '18',
                          icon: Icons.shopping_bag,
                          trend: 'up',
                          trendValue: '+8%',
                          comparison: '4 pending approvals',
                          progress: 0.65,
                          module: showFeed ? 'feed' : 'medicine',
                        ),
                        ModernStatCard(
                          label: 'Pending Value',
                          value: showFeed ? '₹45K' : '₹38.5K',
                          icon: Icons.hourglass_top,
                          trend: 'neutral',
                          trendValue: '0%',
                          comparison: 'Follow up customers',
                          progress: 0.45,
                          module: 'customers',
                        ),
                        ModernStatCard(
                          label: 'Low Stock Items',
                          value: showFeed ? '5' : '8',
                          icon: Icons.inventory,
                          trend: 'down',
                          trendValue: '-3',
                          comparison: 'Reorder suggested',
                          progress: 0.3,
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
                      childAspectRatio: 0.95, // Fixed: was 1.1, now 0.95
                      children: [
                        StatCard(
                          icon: Icons.payments_outlined,
                          title: "Today's Sales",
                          value: showFeed ? '₹1,25,000' : '₹88,000',
                          trend: '+12% vs yesterday',
                          valueColor: showFeed
                              ? modern.AppColors.emeraldGreen
                              : modern.AppColors.royalBlue,
                        ),
                        StatCard(
                          icon: Icons.shopping_bag_outlined,
                          title: showFeed ? 'Orders' : 'Bills',
                          value: showFeed ? '23' : '18',
                          trend: '4 pending approvals',
                        ),
                        StatCard(
                          icon: Icons.hourglass_top_outlined,
                          title: 'Pending Value',
                          value: showFeed ? '₹45,000' : '₹38,500',
                          trend: 'Follow up customers',
                        ),
                        StatCard(
                          icon: Icons.medication_liquid,
                          title: 'Low Stock Items',
                          value: showFeed ? '5' : '8',
                          trend: 'Reorder suggested',
                          valueColor: modern.AppColors.amberOrange,
                        ),
                      ],
                    ),
            SizedBox(height: ResponsiveLayout.spacing(context) * 1.5),
            Text('Quick Actions',
                style: ResponsiveTextStyles.headlineSmall(context)),
            SizedBox(height: ResponsiveLayout.spacing(context) * 0.75),
            Wrap(
              spacing: ResponsiveLayout.spacing(context) * 0.75,
              runSpacing: ResponsiveLayout.spacing(context) * 0.75,
              children: [
                _QuickAction(
                  icon: Icons.add_shopping_cart,
                  label: 'New Feed Order',
                  onTap: () {},
                ),
                _QuickAction(
                  icon: Icons.inventory_2_outlined,
                  label: 'Add Product',
                  onTap: () {},
                ),
                _QuickAction(
                  icon: Icons.document_scanner_outlined,
                  label: 'Print Invoice',
                  onTap: () {},
                ),
                _QuickAction(
                  icon: Icons.analytics_outlined,
                  label: 'Reports',
                  onTap: () {},
                ),
              ],
            ),
            SizedBox(height: ResponsiveLayout.spacing(context) * 1.5),
            Text('Upcoming Deliveries',
                style: ResponsiveTextStyles.headlineSmall(context)),
            SizedBox(height: ResponsiveLayout.spacing(context) * 0.75),
            ...mockFeedOrders.take(3).map(
              (order) => ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                leading: CircleAvatar(child: Text(order.orderNumber.substring(4),style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600,fontSize: 10),)),
                title: Text(order.orderNumber, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600,),),
                subtitle: Text(order.date, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600,),),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('₹${order.total.toStringAsFixed(0)}'),
                    Text(order.paymentStatus,
                        style: TextStyle(
                          color: order.paymentStatus == 'Paid'
                              ? colorScheme.primary
                              : Colors.amber,
                        )),
                  ],
                ),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Calculate width based on device type
    final width = ResponsiveLayout.value<double>(
      context: context,
      mobile: (MediaQuery.of(context).size.width - 64) / 2,
      tablet: 160.0,
      desktop: 180.0,
    );

    final height = ResponsiveLayout.value<double>(
      context: context,
      mobile: 110.0,
      tablet: 120.0,
      desktop: 130.0,
    );

    return Material(
      borderRadius: BorderRadius.circular(16),
      color: Theme.of(context).colorScheme.surface,
      elevation: context.isDesktop ? 1 : 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: SizedBox(
          width: width,
          height: height,
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
