import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/medicine.dart';
import '../../widgets/medicine_card.dart';
import '../../widgets/search_bar_widget.dart';
import 'add_medicine_screen.dart';
import 'medicine_detail_screen.dart';

class MedicineInventoryScreen extends StatefulWidget {
  const MedicineInventoryScreen({super.key});

  @override
  State<MedicineInventoryScreen> createState() => _MedicineInventoryScreenState();
}

class _MedicineInventoryScreenState extends State<MedicineInventoryScreen> {
  final Set<String> categoryFilters = {};
  RangeValues priceRange = const RangeValues(50, 500);

  List<Medicine> get filteredMedicines {
    return mockMedicines.where((m) {
      final matchesPrice = m.sellingPrice >= priceRange.start && m.sellingPrice <= priceRange.end;
      final matchesCategory = categoryFilters.isEmpty || categoryFilters.contains(m.category);
      return matchesPrice && matchesCategory;
    }).toList();
  }

  void _openFilters() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Inventory Filters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: medicineCategories
                      .map(
                        (category) => FilterChip(
                          label: Text(category),
                          selected: categoryFilters.contains(category),
                          onSelected: (value) => setState(() {
                            if (value) {
                              categoryFilters.add(category);
                            } else {
                              categoryFilters.remove(category);
                            }
                          }),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 16),
              Text('Price Range ₹${priceRange.start.toStringAsFixed(0)} - ₹${priceRange.end.toStringAsFixed(0)}'),
              RangeSlider(
                values: priceRange,
                min: 0,
                max: 500,
                onChanged: (value) => setState(() => priceRange = value),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Apply'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openAddMedicine() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddMedicineScreen()),
    );
  }

  void _openDetail(Medicine medicine) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MedicineDetailScreen(medicine: medicine)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _openFilters,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Sorting by $value (mock)')),
            ),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'Stock', child: Text('Stock')),
              PopupMenuItem(value: 'Expiry', child: Text('Expiry')),
              PopupMenuItem(value: 'Price', child: Text('Price')),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: SearchBarWidget(
                hint: 'Search medicines',
                onChanged: (_) {},
                onFilterTap: _openFilters,
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 900
                      ? 3
                      : constraints.maxWidth > 600
                          ? 2
                          : 1;
                  return GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: crossAxisCount == 1 ? 2.5 : 1.8,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                    ),
                    itemCount: filteredMedicines.length,
                    itemBuilder: (context, index) {
                      final medicine = filteredMedicines[index];
                      return MedicineCard(
                        medicine: medicine,
                        onTap: () => _openDetail(medicine),
                        onAdd: () => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${medicine.name} added to cart (mock).')),
                        ),
                        onMore: () => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('More options for ${medicine.name}')),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddMedicine,
        icon: const Icon(Icons.add),
        label: const Text('Add Medicine'),
      ),
    );
  }
}
