import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/feed_product.dart';
import '../../widgets/quantity_stepper.dart';
import '../../widgets/status_badge.dart';

class FeedOrderScreen extends StatefulWidget {
  const FeedOrderScreen({super.key});

  @override
  State<FeedOrderScreen> createState() => _FeedOrderScreenState();
}

class _FeedOrderScreenState extends State<FeedOrderScreen> {
  int currentStep = 0;
  String? selectedCustomerId;
  final Map<FeedProduct, int> cart = {};
  String paymentStatus = 'Pending';

  double get subtotal => cart.entries
      .map((entry) => entry.key.rate * entry.value)
      .fold(0, (prev, amount) => prev + amount);

  double get discount => subtotal * 0.05;
  double get total => subtotal - discount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed Order Wizard'),
      ),
      body: SafeArea(
        child: Stepper(
          currentStep: currentStep,
          onStepContinue: () {
            if (currentStep < 3) {
              setState(() => currentStep += 1);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Order sent for review (mock).')),
              );
            }
          },
          onStepCancel: () {
            if (currentStep > 0) {
              setState(() => currentStep -= 1);
            }
          },
          controlsBuilder: (context, details) {
            return Row(
              children: [
                FilledButton(
                  onPressed: details.onStepContinue,
                  child: Text(currentStep == 3 ? 'Finish' : 'Next'),
                ),
                const SizedBox(width: 12),
                if (currentStep > 0)
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text('Back'),
                  ),
              ],
            );
          },
          steps: [
            Step(
              title: const Text('Customer'),
              isActive: currentStep >= 0,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Search customers',
                      prefixIcon: Icon(Icons.search),
                    ),
                    items: mockCustomers
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text('${c.name} • ${c.shopName}'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => selectedCustomerId = value),
                  ),
                  const SizedBox(height: 16),
                  if (selectedCustomerId != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mockCustomers
                                .firstWhere((c) => c.id == selectedCustomerId!)
                                .name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(mockCustomers
                              .firstWhere((c) => c.id == selectedCustomerId!)
                              .phone),
                          const SizedBox(height: 8),
                          StatusBadge(
                            label:
                                'Balance: ₹${mockCustomers.firstWhere((c) => c.id == selectedCustomerId!).balance.toStringAsFixed(0)}',
                            color: mockCustomers
                                        .firstWhere((c) => c.id == selectedCustomerId!)
                                        .balance >
                                    0
                                ? Colors.orange
                                : Colors.green,
                          ),
                        ],
                      ),
                    )
                  else
                    Text('Pick a customer to continue',
                        style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Step(
              title: const Text('Products'),
              isActive: currentStep >= 1,
              content: Column(
                children: mockFeedProducts
                    .map(
                      (product) => Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(backgroundImage: NetworkImage(product.image)),
                          title: Text(product.name),
                          subtitle: Text('₹${product.rate.toStringAsFixed(0)} • ${product.stock} ${product.unit} left'),
                          trailing: FilledButton.tonal(
                            onPressed: () {
                              setState(() {
                                cart.update(product, (value) => value + 1, ifAbsent: () => 1);
                              });
                            },
                            child: const Text('Add'),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            Step(
              title: const Text('Cart'),
              isActive: currentStep >= 2,
              content: Column(
                children: [
                  if (cart.isEmpty)
                    Text('No items yet',
                        style: Theme.of(context).textTheme.bodyMedium)
                  else
                    ...cart.entries.map(
                      (entry) => Dismissible(
                        key: ValueKey(entry.key.id),
                        onDismissed: (_) => setState(() => cart.remove(entry.key)),
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(entry.key.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium),
                                      Text('₹${entry.key.rate.toStringAsFixed(0)}'),
                                    ],
                                  ),
                                ),
                                QuantityStepper(
                                  value: entry.value,
                                  onChanged: (val) =>
                                      setState(() => cart[entry.key] = val),
                                  min: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _AmountRow(label: 'Subtotal', value: subtotal),
                          _AmountRow(label: 'Discount (5%)', value: discount),
                          const Divider(),
                          _AmountRow(
                            label: 'Grand Total',
                            value: total,
                            highlight: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RadioListTile<String>(
                        value: 'Paid',
                        groupValue: paymentStatus,
                        title: const Text('Paid'),
                        onChanged: (value) =>
                            setState(() => paymentStatus = value ?? 'Pending'),
                      ),
                      RadioListTile<String>(
                        value: 'Pending',
                        groupValue: paymentStatus,
                        title: const Text('Pending'),
                        onChanged: (value) =>
                            setState(() => paymentStatus = value ?? 'Pending'),
                      ),
                      RadioListTile<String>(
                        value: 'Partial',
                        groupValue: paymentStatus,
                        title: const Text('Partial'),
                        onChanged: (value) =>
                            setState(() => paymentStatus = value ?? 'Partial'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Step(
              title: const Text('Invoice'),
              isActive: currentStep >= 3,
              content: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Invoice Preview',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 12),
                        Text('Customer: ${selectedCustomerId ?? 'NA'}'),
                        const SizedBox(height: 8),
                        Text('Items: ${cart.length} • Total: ₹${total.toStringAsFixed(0)}'),
                        const SizedBox(height: 8),
                        Text('Payment Status: $paymentStatus'),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _showDialog('Print'),
                                icon: const Icon(Icons.print_outlined),
                                label: const Text('Print'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _showDialog('Share'),
                                icon: const Icon(Icons.ios_share),
                                label: const Text('Share'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDialog(String action) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$action invoice'),
        content: const Text('This is a mock preview only.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final double value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(label),
          const Spacer(),
          Text(
            '₹${value.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
                  color: highlight
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
          ),
        ],
      ),
    );
  }
}
