import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/customer.dart';
import '../../widgets/status_badge.dart';

class CustomerDetailScreen extends StatelessWidget {
  const CustomerDetailScreen({super.key, required this.customer});

  final Customer customer;

  List<DataRow> _orderRows() {
    final orders = mockFeedOrders.where((o) => o.customerId == customer.id);
    return orders
        .map(
          (order) => DataRow(
            cells: [
              DataCell(Text(order.orderNumber)),
              DataCell(Text(order.date)),
              DataCell(Text('₹${order.total.toStringAsFixed(0)}')),
              DataCell(Text(order.paymentStatus)),
            ],
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(customer.name),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Orders'),
              Tab(text: 'Payments'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _OrdersTab(rows: _orderRows(), customer: customer),
            _PaymentsTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add payment flow mocked.')),
          ),
          label: const Text('Add Payment'),
          icon: const Icon(Icons.currency_rupee),
        ),
      ),
    );
  }
}

class _OrdersTab extends StatelessWidget {
  const _OrdersTab({required this.rows, required this.customer});

  final List<DataRow> rows;
  final Customer customer;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _InfoCard(
          title: 'Personal Information',
          children: [
            _InfoRow(label: 'Shop', value: customer.shopName),
            _InfoRow(label: 'Phone', value: customer.phone),
            _InfoRow(label: 'Address', value: customer.address),
          ],
        ),
        _InfoCard(
          title: 'Outstanding Balance',
          highlight: true,
          children: [
            Row(
              children: [
                Text(
                  '₹${customer.balance.abs().toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                StatusBadge(
                  label: customer.balance >= 0 ? 'Due' : 'Advance',
                  color: customer.balance >= 0 ? Colors.orange : Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Last paid on 18 Nov 2025'),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Order')),
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Value')),
              DataColumn(label: Text('Status')),
            ],
            rows: rows,
          ),
        ),
      ],
    );
  }
}

class _PaymentsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: mockPaymentTimeline.length,
      itemBuilder: (context, index) {
        final entry = mockPaymentTimeline[index];
        return TimelineTile(entry: entry, isFirst: index == 0);
      },
    );
  }
}

class TimelineTile extends StatelessWidget {
  const TimelineTile({super.key, required this.entry, this.isFirst = false});

  final MockTimelineEntry entry;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            if (!isFirst)
              Container(
                width: 2,
                height: 60,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.title,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(entry.subtitle,
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(entry.date),
                      const Spacer(),
                      if (entry.amount != null)
                        Text(
                          '₹${entry.amount!.toStringAsFixed(0)}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.children, this.highlight = false});

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
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodySmall)),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
