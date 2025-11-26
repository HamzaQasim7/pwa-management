import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/feed_product.dart';
import '../../widgets/bottom_sheet_header.dart';
import '../../widgets/filter_bottom_sheet.dart';
import '../../widgets/image_picker_widget.dart';
import '../../widgets/product_card.dart';
import '../../widgets/search_bar_widget.dart';

class FeedProductsScreen extends StatefulWidget {
  const FeedProductsScreen({super.key});

  @override
  State<FeedProductsScreen> createState() => _FeedProductsScreenState();
}

class _FeedProductsScreenState extends State<FeedProductsScreen> {
  bool isGrid = true;
  final Set<String> selectedCategories = {};

  List<FeedProduct> get filteredProducts {
    if (selectedCategories.isEmpty) return mockFeedProducts;
    return mockFeedProducts
        .where((p) => selectedCategories.contains(p.category))
        .toList();
  }

  void _showAddProductSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          builder: (context, controller) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: ListView(
                controller: controller,
                children: [
                  const BottomSheetHeader(
                    title: 'Add Feed Product',
                    subtitle: 'Capture details to reuse later when backend arrives.',
                  ),
                  const SizedBox(height: 16),
                  const ImagePickerWidget(label: 'Tap to attach product image'),
                  const SizedBox(height: 16),
                  TextFormField(decoration: const InputDecoration(labelText: 'Product name')),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: feedCategories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (_) {},
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Unit type'),
                    items: const [
                      DropdownMenuItem(value: 'kg', child: Text('Kilograms')),
                      DropdownMenuItem(value: 'bags', child: Text('Bags')),
                    ],
                    onChanged: (_) {},
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Stock quantity'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Rate (per unit)'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Supplier'),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(content: Text('Product saved (mock).')),
                      );
                    },
                    child: const Text('Save Product'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed Products'),
        actions: [
          IconButton(
            icon: Icon(isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded),
            onPressed: () => setState(() => isGrid = !isGrid),
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: SearchBarWidget(
                hint: 'Search feed products',
                onChanged: (_) {},
                onFilterTap: () => _showFilterSheet(context),
              ),
            ),
            SizedBox(
              height: 48,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final category = feedCategories[index];
                  final isSelected = selectedCategories.contains(category);
                  return FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (value) => setState(() {
                      if (value) {
                        selectedCategories.add(category);
                      } else {
                        selectedCategories.remove(category);
                      }
                    }),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemCount: feedCategories.length,
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isGrid
                    ? GridView.builder(
                        key: const ValueKey('grid'),
                        padding: const EdgeInsets.all(20),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return ProductCard(
                            product: product,
                            onEdit: () => _showSnack('Edit ${product.name}'),
                            onDelete: () => _showSnack('Delete ${product.name}'),
                          );
                        },
                      )
                    : ListView.builder(
                        key: const ValueKey('list'),
                        padding: const EdgeInsets.all(20),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: ProductCard(
                              product: product,
                              onEdit: () => _showSnack('Edit ${product.name}'),
                              onDelete: () => _showSnack('Delete ${product.name}'),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddProductSheet,
        label: const Text('Add Product'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return FilterBottomSheet(
          title: 'Filter Products',
          onApply: () => Navigator.pop(context),
          children: [
            Wrap(
              spacing: 8,
              children: feedCategories
                  .map(
                    (category) => FilterChip(
                      label: Text(category),
                      selected: selectedCategories.contains(category),
                      onSelected: (value) => setState(() {
                        if (value) {
                          selectedCategories.add(category);
                        } else {
                          selectedCategories.remove(category);
                        }
                      }),
                    ),
                  )
                  .toList(),
            ),
          ],
        );
      },
    );
  }
}
