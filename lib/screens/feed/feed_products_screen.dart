import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/feed_product_model.dart';
import '../../presentation/providers/feed_product_provider.dart';
import '../../utils/responsive_layout.dart';
import '../../widgets/bottom_sheet_header.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/filter_bottom_sheet.dart';
import '../../widgets/image_picker_widget.dart';
import '../../widgets/loading_shimmer.dart';
import '../../widgets/search_bar_widget.dart';

class FeedProductsScreen extends StatefulWidget {
  const FeedProductsScreen({super.key});

  @override
  State<FeedProductsScreen> createState() => _FeedProductsScreenState();
}

class _FeedProductsScreenState extends State<FeedProductsScreen> {
  bool isGrid = true;

  // Form controllers for add product
  final _nameController = TextEditingController();
  final _stockController = TextEditingController();
  final _rateController = TextEditingController();
  final _supplierController = TextEditingController();
  final _lowStockController = TextEditingController();
  String _selectedCategory = 'Cattle';
  String _selectedUnit = 'kg';

  static const List<String> feedCategories = [
    'Cattle',
    'Poultry',
    'Goat',
    'Fish',
    'Premium',
    'Supplements',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _stockController.dispose();
    _rateController.dispose();
    _supplierController.dispose();
    _lowStockController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _nameController.clear();
    _stockController.clear();
    _rateController.clear();
    _supplierController.clear();
    _lowStockController.clear();
    _selectedCategory = 'Cattle';
    _selectedUnit = 'kg';
  }

  void _showAddProductSheet() {
    _resetForm();
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
                              'Add a new feed product to inventory',
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
                      subtitle: 'Add a new feed product to inventory.',
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
    return StatefulBuilder(
      builder: (context, setFormState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ImagePickerWidget(label: 'Tap to attach product image'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Product name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.shopping_bag),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: feedCategories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (value) {
                setFormState(() {
                  _selectedCategory = value ?? 'Cattle';
                });
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedUnit,
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
              onChanged: (value) {
                setFormState(() {
                  _selectedUnit = value ?? 'kg';
                });
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _stockController,
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
                    controller: _rateController,
                    decoration: const InputDecoration(
                      labelText: 'Rate (per unit)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _lowStockController,
              decoration: const InputDecoration(
                labelText: 'Low stock threshold',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.warning_amber),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _supplierController,
              decoration: const InputDecoration(
                labelText: 'Supplier (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
            ),
            const SizedBox(height: 20),
            Consumer<FeedProductProvider>(
              builder: (context, provider, child) {
                return FilledButton.icon(
                  onPressed: provider.isLoading ? null : () => _saveProduct(context),
                  icon: provider.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check),
                  label: Text(provider.isLoading ? 'Saving...' : 'Save Product'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveProduct(BuildContext context) async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter product name')),
      );
      return;
    }

    final provider = context.read<FeedProductProvider>();
    
    final success = await provider.addProduct(
      name: _nameController.text.trim(),
      category: _selectedCategory,
      unit: _selectedUnit,
      stock: int.tryParse(_stockController.text) ?? 0,
      lowStockThreshold: int.tryParse(_lowStockController.text) ?? 10,
      rate: double.tryParse(_rateController.text) ?? 0,
      supplier: _supplierController.text.trim().isEmpty ? null : _supplierController.text.trim(),
    );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product saved successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to save product'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
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
          Consumer<FeedProductProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: provider.isLoading ? null : () => provider.refresh(),
                tooltip: 'Refresh',
              );
            },
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
                  child: Consumer<FeedProductProvider>(
                    builder: (context, provider, child) {
                      return SearchBarWidget(
                        hint: 'Search feed products',
                        onChanged: provider.setSearchQuery,
                        onFilterTap: () => _showFilterSheet(context),
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 52,
                  child: Consumer<FeedProductProvider>(
                    builder: (context, provider, child) {
                      return ListView.separated(
                        padding: EdgeInsets.symmetric(horizontal: paddingValue),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final category = feedCategories[index];
                          final isSelected = provider.selectedCategories.contains(category);
                          return FilterChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (_) => provider.toggleCategory(category),
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemCount: feedCategories.length,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Consumer<FeedProductProvider>(
                    builder: (context, provider, child) {
                      // Loading state
                      if (provider.isLoading && provider.products.isEmpty) {
                        return LoadingShimmer(
                          child: GridView.builder(
                            padding: EdgeInsets.all(paddingValue),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.75,
                            ),
                            itemCount: 8,
                            itemBuilder: (context, index) => Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        );
                      }

                      // Error state
                      if (provider.error != null && provider.products.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              const SizedBox(height: 16),
                              Text('Error: ${provider.error}'),
                              const SizedBox(height: 16),
                              FilledButton.icon(
                                onPressed: () => provider.loadProducts(),
                                icon: const Icon(Icons.refresh),
                                label: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      // Empty state
                      if (provider.products.isEmpty) {
                        return EmptyState(
                          icon: Icons.inventory_2_outlined,
                          title: 'No Products Found',
                          subtitle: provider.searchQuery.isNotEmpty || provider.selectedCategories.isNotEmpty
                              ? 'Try adjusting your search or filters'
                              : 'Add your first product to get started',
                          actionLabel: provider.searchQuery.isNotEmpty ? 'Clear Filters' : 'Add Product',
                          onAction: provider.searchQuery.isNotEmpty
                              ? () => provider.clearFilters()
                              : _showAddProductSheet,
                        );
                      }

                      final products = provider.products;

                      return RefreshIndicator(
                        onRefresh: () => provider.refresh(),
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
                                  itemCount: products.length,
                                  itemBuilder: (context, index) {
                                    final product = products[index];
                                    return _ProductCard(
                                      product: product,
                                      onEdit: () => _showSnack('Edit ${product.name}'),
                                      onDelete: () => _confirmDelete(product),
                                    );
                                  },
                                )
                              : ListView.builder(
                                  key: const ValueKey('list'),
                                  padding: EdgeInsets.all(paddingValue),
                                  itemCount: products.length,
                                  itemBuilder: (context, index) {
                                    final product = products[index];
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        bottom: ResponsiveLayout.spacing(context),
                                      ),
                                      child: Container(
                                        constraints: BoxConstraints(
                                          maxWidth: isDesktop ? 800 : double.infinity,
                                        ),
                                        child: _ProductCard(
                                          product: product,
                                          onEdit: () => _showSnack('Edit ${product.name}'),
                                          onDelete: () => _confirmDelete(product),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'feed_products_fab',
        onPressed: _showAddProductSheet,
        label: const Text('Add Product'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _confirmDelete(FeedProductModel product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product?'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<FeedProductProvider>().deleteProduct(product.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${product.name} deleted')),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return Consumer<FeedProductProvider>(
          builder: (context, provider, child) {
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
                          selected: provider.selectedCategories.contains(category),
                          onSelected: (_) => provider.toggleCategory(category),
                        ),
                      )
                      .toList(),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  final FeedProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLowStock = product.isLowStock;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isLowStock
              ? Colors.orange.withOpacity(0.5)
              : theme.colorScheme.outline.withOpacity(0.2),
          width: isLowStock ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image placeholder
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          Icons.inventory_2,
                          size: 48,
                          color: theme.colorScheme.primary.withOpacity(0.5),
                        ),
                      ),
                      // Category badge
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            product.category,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                      // Low stock warning
                      if (isLowStock)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.warning,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Product name
              Text(
                product.name,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Stock info
              Row(
                children: [
                  Text(
                    'Stock: ${product.stock} ${product.unit}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isLowStock
                          ? Colors.orange
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Price
              Text(
                'Rs ${product.rate.toStringAsFixed(0)}/${product.unit}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
