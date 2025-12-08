import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/customer_model.dart';
import '../../presentation/providers/order_provider.dart';
import '../../presentation/providers/customer_provider.dart';
import '../../utils/responsive_layout.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/loading_shimmer.dart';
import '../../core/utils/date_formatter.dart';
import 'add_payment_dialog.dart';

class CustomerDetailScreen extends StatelessWidget {
  const CustomerDetailScreen({super.key, required this.customer});

  final CustomerModel customer;

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    
    return Consumer<CustomerProvider>(
      builder: (context, customerProvider, child) {
        // Get latest customer data from provider
        final updatedCustomer = customerProvider.allCustomers
            .firstWhere(
              (c) => c.id == customer.id,
              orElse: () => customer,
            );
        
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: Text(updatedCustomer.name),
              centerTitle: isDesktop,
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Orders'),
                  Tab(text: 'Details'),
                ],
              ),
            ),
            body: Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 1200 : double.infinity,
                ),
                child: TabBarView(
                  children: [
                    _OrdersTab(customer: updatedCustomer),
                    _DetailsTab(customer: updatedCustomer),
                  ],
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              heroTag: 'customer_detail_fab',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AddPaymentDialog(customer: updatedCustomer),
                );
              },
              label: const Text('Add Payment'),
              icon: const Icon(Icons.attach_money),
            ),
          ),
        );
      },
    );
  }
}

class _OrdersTab extends StatelessWidget {
  const _OrdersTab({required this.customer});

  final CustomerModel customer;

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        if (orderProvider.isLoading && orderProvider.allOrders.isEmpty) {
          return LoadingShimmer(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: 3,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          );
        }

        // Get orders for this customer
        final customerOrders = orderProvider.allOrders
            .where((o) => o.customerId == customer.id)
            .toList();

        // Calculate payment statistics
        double totalPaid = 0;
        double totalOwed = 0;
        double totalOrderValue = 0;

        for (final order in customerOrders) {
          totalOrderValue += order.total;
          totalPaid += order.paidAmount ?? 0;
          totalOwed += order.remainingAmount;
        }

        return RefreshIndicator(
          onRefresh: () async {
            final orderProvider = context.read<OrderProvider>();
            final customerProvider = context.read<CustomerProvider>();
            await orderProvider.loadOrders();
            await customerProvider.loadCustomers();
          },
          child: ListView(
            padding: ResponsiveLayout.padding(context),
            children: [
            _InfoCard(
              title: 'Outstanding Balance',
              highlight: true,
              children: [
                Row(
                  children: [
                    Text(
                      'Rs ${customer.balance.abs().toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 12),
                    StatusBadge(
                      label: customer.balance > 0 ? 'Credit' : customer.balance < 0 ? 'Due' : 'Clear',
                      color: customer.balance > 0
                          ? Colors.green
                          : customer.balance < 0
                              ? Colors.orange
                              : Colors.grey,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Payment Statistics
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Order Value',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Rs ${totalOrderValue.toStringAsFixed(0)}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      size: 16,
                                      color: Colors.green.shade700,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Total Paid',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Rs ${totalPaid.toStringAsFixed(0)}',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon(
                                      Icons.warning_amber,
                                      size: 16,
                                      color: Colors.orange.shade700,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Total Due',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Rs ${totalOwed.toStringAsFixed(0)}',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade700,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Customer since ${DateFormatter.formatDate(customer.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Order History',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (customerOrders.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 48,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No orders yet',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Order')),
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Value')),
                    DataColumn(label: Text('Status')),
                  ],
                  rows: customerOrders.map((order) {
                    return DataRow(
                      cells: [
                        DataCell(Text(order.orderNumber)),
                        DataCell(Text(DateFormatter.formatDateShort(order.date))),
                        DataCell(Text('Rs ${order.total.toStringAsFixed(0)}')),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(order.paymentStatus).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              order.paymentStatus,
                              style: TextStyle(
                                color: _getStatusColor(order.paymentStatus),
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Paid':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Partially Paid':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

class _DetailsTab extends StatelessWidget {
  const _DetailsTab({required this.customer});

  final CustomerModel customer;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: ResponsiveLayout.padding(context),
      children: [
        _InfoCard(
          title: 'Contact Information',
          children: [
            _InfoRow(label: 'Name', value: customer.name),
            if (customer.shopName != null && customer.shopName!.isNotEmpty)
              _InfoRow(label: 'Shop', value: customer.shopName!),
            _InfoRow(label: 'Phone', value: customer.phone),
            if (customer.email != null && customer.email!.isNotEmpty)
              _InfoRow(label: 'Email', value: customer.email!),
          ],
        ),
        _InfoCard(
          title: 'Address',
          children: [
            if (customer.address != null && customer.address!.isNotEmpty)
              _InfoRow(label: 'Address', value: customer.address!),
            if (customer.city != null && customer.city!.isNotEmpty)
              _InfoRow(label: 'City', value: customer.city!),
            if (customer.area != null && customer.area!.isNotEmpty)
              _InfoRow(label: 'Area', value: customer.area!),
          ],
        ),
        _InfoCard(
          title: 'Account Details',
          children: [
            _InfoRow(label: 'Type', value: customer.customerType),
            if (customer.creditLimit != null)
              _InfoRow(
                label: 'Credit Limit',
                value: 'Rs ${customer.creditLimit!.toStringAsFixed(0)}',
              ),
            _InfoRow(
              label: 'Balance',
              value: 'Rs ${customer.balance.abs().toStringAsFixed(0)} ${customer.balance > 0 ? "(Credit)" : customer.balance < 0 ? "(Due)" : ""}',
            ),
            _InfoRow(
              label: 'Member Since',
              value: DateFormatter.formatDate(customer.createdAt),
            ),
          ],
        ),
        if (customer.notes != null && customer.notes!.isNotEmpty)
          _InfoCard(
            title: 'Notes',
            children: [
              Text(customer.notes!),
            ],
          ),
        const SizedBox(height: 16),
        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Calling ${customer.phone}...')),
                  );
                },
                icon: const Icon(Icons.phone),
                label: const Text('Call'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Messaging ${customer.phone}...')),
                  );
                },
                icon: const Icon(Icons.message),
                label: const Text('Message'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.children,
    this.highlight = false,
  });

  final String title;
  final List<Widget> children;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: highlight ? Theme.of(context).colorScheme.primaryContainer : null,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
