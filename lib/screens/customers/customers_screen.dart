import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/customer_model.dart';
import '../../presentation/providers/customer_provider.dart';
import '../../utils/responsive_layout.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_shimmer.dart';
import 'customer_detail_screen.dart';
import 'add_customer_dialog.dart';

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key, required this.drawerBuilder});

  final WidgetBuilder drawerBuilder;

  void _openDetails(BuildContext context, CustomerModel customer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomerDetailScreen(customer: customer),
      ),
    );
  }

  void _showAddCustomerDialog(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    
    if (isDesktop) {
      showAddCustomerDialog(context);
    } else {
      showAddCustomerBottomSheet(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: context.isMobile ? Builder(builder: drawerBuilder) : null,
      appBar: context.isDesktop ? null : AppBar(
        title: const Text('Customers'),
        actions: [
          Consumer<CustomerProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: provider.isLoading ? null : () => provider.refresh(),
                tooltip: 'Refresh',
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveContentContainer(
          child: Column(
            children: [
              // Search and filter bar
              Padding(
                padding: ResponsiveLayout.padding(context),
                child: Consumer<CustomerProvider>(
                  builder: (context, provider, child) {
                    return Column(
                      children: [
                        // Search bar
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'Search customers...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: provider.searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () => provider.setSearchQuery(''),
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                          ),
                          onChanged: provider.setSearchQuery,
                        ),
                        const SizedBox(height: 12),
                        // Filter chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _FilterChip(
                                label: 'All',
                                selected: provider.filterType == 'All',
                                onSelected: () => provider.setFilterType('All'),
                              ),
                              const SizedBox(width: 8),
                              _FilterChip(
                                label: 'Retail',
                                selected: provider.filterType == 'Retail',
                                onSelected: () => provider.setFilterType('Retail'),
                              ),
                              const SizedBox(width: 8),
                              _FilterChip(
                                label: 'Wholesale',
                                selected: provider.filterType == 'Wholesale',
                                onSelected: () => provider.setFilterType('Wholesale'),
                              ),
                              const SizedBox(width: 8),
                              _FilterChip(
                                label: 'VIP',
                                selected: provider.filterType == 'VIP',
                                onSelected: () => provider.setFilterType('VIP'),
                              ),
                              const SizedBox(width: 8),
                              _FilterChip(
                                label: 'Credit',
                                selected: provider.filterType == 'Credit',
                                onSelected: () => provider.setFilterType('Credit'),
                                color: Colors.green,
                              ),
                              const SizedBox(width: 8),
                              _FilterChip(
                                label: 'Debt',
                                selected: provider.filterType == 'Debt',
                                onSelected: () => provider.setFilterType('Debt'),
                                color: Colors.red,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              // Customer list
              Expanded(
                child: Consumer<CustomerProvider>(
                  builder: (context, provider, child) {
                    // Loading state
                    if (provider.isLoading && provider.customers.isEmpty) {
                      return LoadingShimmer(
                        child: ListView.builder(
                          padding: ResponsiveLayout.padding(context),
                          itemCount: 5,
                          itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Container(
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    // Error state
                    if (provider.error != null && provider.customers.isEmpty) {
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
                            Text(
                              'Error loading customers',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              provider.error!,
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              onPressed: () => provider.loadCustomers(),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    // Empty state
                    if (provider.customers.isEmpty) {
                      return EmptyState(
                        icon: Icons.people_outline,
                        title: 'No Customers Found',
                        subtitle: provider.searchQuery.isNotEmpty
                            ? 'Try adjusting your search or filters'
                            : 'Add your first customer to get started',
                        actionLabel: provider.searchQuery.isNotEmpty ? 'Clear Filters' : 'Add Customer',
                        onAction: provider.searchQuery.isNotEmpty
                            ? () => provider.clearFilters()
                            : () => _showAddCustomerDialog(context),
                      );
                    }

                    // Customer list
                    return RefreshIndicator(
                      onRefresh: () => provider.refresh(),
                      child: ResponsiveLayout.builder(
                        context: context,
                        mobile: (ctx) => ListView.builder(
                          padding: ResponsiveLayout.padding(ctx),
                          itemCount: provider.customers.length,
                          itemBuilder: (context, index) {
                            final customer = provider.customers[index];
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: ResponsiveLayout.spacing(ctx) * 0.75,
                              ),
                              child: _CustomerListItem(
                                customer: customer,
                                onTap: () => _openDetails(context, customer),
                              ),
                            );
                          },
                        ),
                        desktop: (ctx) => GridView.builder(
                          padding: ResponsiveLayout.padding(ctx),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: ResponsiveLayout.gridCrossAxisCount(
                              ctx,
                              mobile: 1,
                              tablet: 2,
                              desktop: 2,
                            ),
                            crossAxisSpacing: ResponsiveLayout.spacing(ctx),
                            mainAxisSpacing: ResponsiveLayout.spacing(ctx),
                            childAspectRatio: 2.5,
                          ),
                          itemCount: provider.customers.length,
                          itemBuilder: (context, index) {
                            final customer = provider.customers[index];
                            return _CustomerListItem(
                              customer: customer,
                              onTap: () => _openDetails(context, customer),
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
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'customers_screen_fab',
        onPressed: () => _showAddCustomerDialog(context),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add Customer'),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: selected ? Colors.white : Colors.black,
      )),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: selected ? color : Colors.grey.shade200,
      checkmarkColor: selected ? Colors.white : Colors.black,
    );
  }
}

class _CustomerListItem extends StatelessWidget {
  final CustomerModel customer;
  final VoidCallback onTap;

  const _CustomerListItem({
    required this.customer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCredit = customer.balance > 0;
    final isDebt = customer.balance < 0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 28,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Customer info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            customer.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getTypeColor(customer.customerType, theme)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            customer.customerType,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: _getTypeColor(customer.customerType, theme),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (customer.shopName != null && customer.shopName!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        customer.shopName!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.phone,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          customer.phone,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Balance
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Rs ${customer.balance.abs().toStringAsFixed(0)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isCredit
                          ? Colors.green
                          : isDebt
                              ? Colors.red
                              : theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    isCredit
                        ? 'Credit'
                        : isDebt
                            ? 'Due'
                            : 'Clear',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isCredit
                          ? Colors.green
                          : isDebt
                              ? Colors.red
                              : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(String type, ThemeData theme) {
    switch (type) {
      case 'VIP':
        return Colors.amber;
      case 'Wholesale':
        return Colors.blue;
      case 'Retail':
      default:
        return theme.colorScheme.primary;
    }
  }
}
