import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../../data/models/medicine_model.dart';
import '../../presentation/providers/medicine_provider.dart';
import '../../widgets/status_badge.dart';

class ExpiryManagementScreen extends StatefulWidget {
  const ExpiryManagementScreen({super.key});

  @override
  State<ExpiryManagementScreen> createState() => _ExpiryManagementScreenState();
}

class _ExpiryManagementScreenState extends State<ExpiryManagementScreen> {
  final Set<String> _selectedCategories = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MedicineProvider>().loadMedicines();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MedicineProvider>(
      builder: (context, provider, child) {
        final allMedicines = provider.allMedicines;
        final categories = allMedicines.map((m) => m.category).toSet().toList()..sort();

        // Filter medicines by expiry
        final now = DateTime.now();
        final expired = _filterByCategory(allMedicines.where((m) => m.isExpired).toList());
        final expiring30 = _filterByCategory(allMedicines.where((m) {
          final days = m.expiryDate.difference(now).inDays;
          return days > 0 && days <= 30;
        }).toList());
        final expiring60 = _filterByCategory(allMedicines.where((m) {
          final days = m.expiryDate.difference(now).inDays;
          return days > 30 && days <= 60;
        }).toList());
        final expiring90 = _filterByCategory(allMedicines.where((m) {
          final days = m.expiryDate.difference(now).inDays;
          return days > 60 && days <= 90;
        }).toList());

        return DefaultTabController(
          length: 4,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Expiry Management'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.ios_share_outlined),
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Export prepared.')),
                  ),
                ),
              ],
              bottom: TabBar(
                isScrollable: true,
                tabs: [
                  Tab(text: 'Expired (${expired.length})'),
                  Tab(text: '30 Days (${expiring30.length})'),
                  Tab(text: '60 Days (${expiring60.length})'),
                  Tab(text: '90 Days (${expiring90.length})'),
                ],
              ),
            ),
            body: Column(
              children: [
                if (categories.isNotEmpty)
                  SizedBox(
                    height: 48,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: categories
                          .map(
                            (category) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(category),
                                selected: _selectedCategories.contains(category),
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedCategories.add(category);
                                    } else {
                                      _selectedCategories.remove(category);
                                    }
                                  });
                                },
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                Expanded(
                  child: provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : TabBarView(
                          children: [
                            _ExpiryTab(medicines: expired, isExpired: true),
                            _ExpiryTab(medicines: expiring30, daysLabel: '30'),
                            _ExpiryTab(medicines: expiring60, daysLabel: '60'),
                            _ExpiryTab(medicines: expiring90, daysLabel: '90'),
                          ],
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<MedicineModel> _filterByCategory(List<MedicineModel> medicines) {
    if (_selectedCategories.isEmpty) return medicines;
    return medicines.where((m) => _selectedCategories.contains(m.category)).toList();
  }
}

class _ExpiryTab extends StatelessWidget {
  const _ExpiryTab({
    required this.medicines,
    this.isExpired = false,
    this.daysLabel,
  });

  final List<MedicineModel> medicines;
  final bool isExpired;
  final String? daysLabel;

  @override
  Widget build(BuildContext context) {
    if (medicines.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isExpired ? Icons.check_circle_outline : Icons.schedule,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              isExpired ? 'No expired medicines' : 'No medicines expiring in this period',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      );
    }

    final totalValue = medicines.fold<double>(
      0,
      (sum, m) => sum + (m.sellingPrice * m.quantity),
    );

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: ListTile(
            title: const Text('Summary'),
            subtitle: Text('Total value Rs ${totalValue.toStringAsFixed(0)} (${medicines.length} items)'),
            trailing: StatusBadge(
              label: isExpired ? 'Expired' : 'Due soon',
              color: isExpired ? Colors.red : Colors.orange,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...medicines.map(
          (medicine) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Slidable(
              key: ValueKey(medicine.id),
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
                  leading: CircleAvatar(
                    backgroundImage: medicine.image != null
                        ? NetworkImage(medicine.image!)
                        : null,
                    child: medicine.image == null
                        ? const Icon(Icons.medication)
                        : null,
                  ),
                  title: Text(medicine.name),
                  subtitle: Text(
                    'Batch ${medicine.batchNo} • Exp ${medicine.expiryDate.day}/${medicine.expiryDate.month}/${medicine.expiryDate.year}',
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        isExpired
                            ? 'Expired'
                            : '${medicine.daysUntilExpiry} days',
                        style: TextStyle(
                          color: isExpired ? Colors.red : Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text('Rs ${medicine.sellingPrice.toStringAsFixed(0)}'),
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
