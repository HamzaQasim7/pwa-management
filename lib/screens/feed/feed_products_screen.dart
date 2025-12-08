import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/feed_product.dart';
import '../../utils/responsive_layout.dart';
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
    final isDesktop = ResponsiveLayout.isDesktop(context);
    
    if (isDesktop) {
      // Desktop: Show as dialog
      showDialog<void>(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: Theme.of(context).colorScheme.primary,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Add Feed Product',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Capture details to reuse later',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                // Form content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: _buildProductForm(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // Mobile: Show as bottom sheet
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
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, controller) {
              return SingleChildScrollView(
                controller: controller,
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 12,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const BottomSheetHeader(
                      title: 'Add Feed Product',
                      subtitle: 'Capture details to reuse later when backend arrives.',
                    ),
                    const SizedBox(height: 16),
                    _buildProductForm(context),
                  ],
                ),
              );
            },
          );
        },
      );
    }
  }

  Widget _buildProductForm(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ImagePickerWidget(label: 'Tap to attach product image'),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Product name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.shopping_bag),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Category',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.category),
          ),
          items: feedCategories
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (_) {},
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Unit type',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.scale),
          ),
          items: const [
            DropdownMenuItem(value: 'kg', child: Text('Kilograms')),
            DropdownMenuItem(value: 'bags', child: Text('Bags')),
            DropdownMenuItem(value: 'liters', child: Text('Liters')),
          ],
          onChanged: (_) {},
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Stock quantity',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Rate (per unit)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Supplier',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.business),
          ),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(this.context).showSnackBar(
              const SnackBar(
                content: Text('Product saved (mock).'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          icon: const Icon(Icons.check),
          label: const Text('Save Product'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final paddingValue = ResponsiveLayout.value<double>(
      context: context,
      mobile: 16.0,
      tablet: 20.0,
      desktop: 24.0,
    );
    final crossAxisCount = ResponsiveLayout.gridCrossAxisCount(
      context,
      mobile: 2,
      tablet: 3,
      desktop: 4,
    );
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed Products'),
        centerTitle: isDesktop,
        actions: [
          IconButton(
            icon: Icon(isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded),
            onPressed: () => setState(() => isGrid = !isGrid),
            tooltip: isGrid ? 'List View' : 'Grid View',
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined),
            onPressed: () => _showFilterSheet(context),
            tooltip: 'Filter',
          ),
          if (isDesktop) const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 1400 : double.infinity,
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(paddingValue),
                  child: SearchBarWidget(
                    hint: 'Search feed products',
                    onChanged: (_) {},
                    onFilterTap: () => _showFilterSheet(context),
                  ),
                ),
                SizedBox(
                  height: 52,
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: paddingValue),
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
                const SizedBox(height: 8),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: isGrid
                        ? GridView.builder(
                            key: const ValueKey('grid'),
                            padding: EdgeInsets.all(paddingValue),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              mainAxisSpacing: ResponsiveLayout.spacing(context),
                              crossAxisSpacing: ResponsiveLayout.spacing(context),
                              childAspectRatio: ResponsiveLayout.value(
                                context: context,
                                mobile: 0.7,
                                tablet: 0.75,
                                desktop: 0.8,
                              ),
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
                            padding: EdgeInsets.all(paddingValue),
                            itemCount: filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = filteredProducts[index];
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: ResponsiveLayout.spacing(context),
                                ),
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxWidth: isDesktop ? 800 : double.infinity,
                                  ),
                                  child: ProductCard(
                                    product: product,
                                    onEdit: () => _showSnack('Edit ${product.name}'),
                                    onDelete: () => _showSnack('Delete ${product.name}'),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
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
