import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/model_converters.dart';
import '../../data/models/medicine_model.dart';
import '../../models/medicine.dart';
import '../../presentation/providers/medicine_provider.dart';
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
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MedicineProvider>().loadMedicines();
    });
  }

  List<Medicine> _filterMedicines(List<MedicineModel> models) {
    return models.where((m) {
      final matchesPrice = m.sellingPrice >= priceRange.start && m.sellingPrice <= priceRange.end;
      final matchesCategory = categoryFilters.isEmpty || categoryFilters.contains(m.category);
      final matchesSearch = _searchQuery.isEmpty ||
          m.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          m.genericName.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesPrice && matchesCategory && matchesSearch;
    }).map((model) => ModelConverters.medicineFromModel(model)).toList();
  }

  void _openFilters() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return Consumer<MedicineProvider>(
          builder: (context, provider, child) {
            // Extract unique categories from medicines
            final categories = provider.allMedicines
                .map((m) => m.category)
                .toSet()
                .toList()
              ..sort();

            return StatefulBuilder(
              builder: (context, setModalState) {
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
                          children: categories
                              .map(
                                (category) => FilterChip(
                                  label: Text(category),
                                  selected: categoryFilters.contains(category),
                                  onSelected: (value) {
                                    setModalState(() {
                                      if (value) {
                                        categoryFilters.add(category);
                                      } else {
                                        categoryFilters.remove(category);
                                      }
                                    });
                                    setState(() {});
                                  },
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
                        onChanged: (value) {
                          setModalState(() => priceRange = value);
                          setState(() {});
                        },
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
          },
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
          Consumer<MedicineProvider>(
            builder: (context, provider, child) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.sort),
                onSelected: (value) {
                  switch (value) {
                    case 'Stock':
                      provider.setSortBy('quantity');
                      break;
                    case 'Expiry':
                      provider.setSortBy('expiry');
                      break;
                    case 'Price':
                      provider.setSortBy('price');
                      break;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Sorted by $value')),
                  );
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'Stock', child: Text('Stock')),
                  PopupMenuItem(value: 'Expiry', child: Text('Expiry')),
                  PopupMenuItem(value: 'Price', child: Text('Price')),
                ],
              );
            },
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
                onChanged: (value) => setState(() => _searchQuery = value),
                onFilterTap: _openFilters,
              ),
            ),
            Expanded(
              child: Consumer<MedicineProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.error != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Error: ${provider.error}'),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () => provider.refresh(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final filteredMedicines = _filterMedicines(provider.allMedicines);

                  if (filteredMedicines.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.medication_outlined, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text('No medicines found'),
                          const SizedBox(height: 8),
                          Text(
                            _searchQuery.isNotEmpty || categoryFilters.isNotEmpty
                                ? 'Try adjusting your filters'
                                : 'Add your first medicine',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: provider.refresh,
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
                                SnackBar(content: Text('${medicine.name} added to cart.')),
                              ),
                              onMore: () => ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('More options for ${medicine.name}')),
                              ),
                            );
                          },
                        );
                      },
                    ),
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
