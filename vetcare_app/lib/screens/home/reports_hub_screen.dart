import 'package:flutter/material.dart';

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
      drawer: Builder(builder: drawerBuilder),
      appBar: AppBar(title: const Text('Reports Center')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.05,
              children: const [
                StatCard(icon: Icons.storefront, title: 'Feed Revenue', value: '₹8.4L'),
                StatCard(icon: Icons.local_hospital, title: 'Pharmacy Revenue', value: '₹9.7L'),
                StatCard(icon: Icons.people_alt, title: 'Customers', value: '423'),
                StatCard(icon: Icons.stacked_bar_chart, title: 'Profitability', value: '37%'),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                title: const Text('Feed module reports'),
                subtitle: const Text('Dashboard, product, customer & profit insights'),
                trailing: ElevatedButton(
                  onPressed: () => _open(context, const FeedReportsScreen()),
                  child: const Text('View'),
                ),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Medicine module reports'),
                subtitle: const Text('Daily to yearly analytics with financial breakdowns'),
                trailing: ElevatedButton(
                  onPressed: () => _open(context, const MedicineReportsScreen()),
                  child: const Text('View'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
