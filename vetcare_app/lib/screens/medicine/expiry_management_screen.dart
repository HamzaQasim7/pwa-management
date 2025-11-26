import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../data/mock_data.dart';
import '../../widgets/status_badge.dart';

class ExpiryManagementScreen extends StatelessWidget {
  const ExpiryManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Expiry Management'),
          actions: [
            IconButton(
              icon: const Icon(Icons.ios_share_outlined),
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export prepared (mock).')),
              ),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Expired (3)'),
              Tab(text: '30 Days (5)'),
              Tab(text: '60 Days (3)'),
              Tab(text: '90 Days (7)'),
            ],
          ),
        ),
        body: Column(
          children: [
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: medicineCategories
                    .map(
                      (category) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          onSelected: (_) {},
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: List.generate(4, (index) => _ExpiryTab(index: index)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpiryTab extends StatelessWidget {
  const _ExpiryTab({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final items = mockMedicines.take(5).toList();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: ListTile(
            title: const Text('Summary'),
            subtitle: Text('Total value ₹${(index + 1) * 25000}'),
            trailing: StatusBadge(
              label: index == 0 ? 'Expired' : 'Due soon',
              color: index == 0 ? Colors.red : Colors.orange,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...items.map(
          (medicine) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Slidable(
              key: ValueKey(medicine.id + index.toString()),
              endActionPane: ActionPane(
                motion: const StretchMotion(),
                children: [
                  SlidableAction(
                    onPressed: (_) => _toast(context, 'Dispose ${medicine.name}'),
                    icon: Icons.delete_sweep,
                    label: 'Dispose',
                    backgroundColor: Colors.red,
                  ),
                  SlidableAction(
                    onPressed: (_) => _toast(context, 'Return ${medicine.name}'),
                    icon: Icons.reply,
                    label: 'Return',
                  ),
                ],
              ),
              child: Card(
                clipBehavior: Clip.hardEdge,
                child: ListTile(
                  leading: CircleAvatar(backgroundImage: NetworkImage(medicine.image)),
                  title: Text(medicine.name),
                  subtitle: Text('Batch ${medicine.batchNo} • Exp ${medicine.expiryDate}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${(index + 1) * 12} days'),
                      Text('₹${medicine.sellingPrice.toStringAsFixed(0)}'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _toast(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}
