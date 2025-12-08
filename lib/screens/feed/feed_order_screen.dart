import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/feed_product.dart';
import '../../utils/invoice_generator.dart';
import '../../utils/responsive_layout.dart';
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
    final isDesktop = ResponsiveLayout.isDesktop(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed Order Wizard'),
        centerTitle: isDesktop,
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 1200 : double.infinity,
            ),
            padding: ResponsiveLayout.padding(context),
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
                return Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    children: [
                      FilledButton.icon(
                        onPressed: details.onStepContinue,
                        icon: Icon(currentStep == 3 ? Icons.check : Icons.arrow_forward),
                        label: Text(currentStep == 3 ? 'Finish' : 'Continue'),
                      ),
                      const SizedBox(width: 12),
                      if (currentStep > 0)
                        OutlinedButton.icon(
                          onPressed: details.onStepCancel,
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Back'),
                        ),
                    ],
                  ),
                );
              },
              steps: [
            Step(
              title: const Text('Customer'),
              subtitle: const Text('Select customer for this order'),
              isActive: currentStep >= 0,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedCustomerId,
                    decoration: const InputDecoration(
                      labelText: 'Search customers',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    items: mockCustomers
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(
                              '${c.name} • ${c.shopName}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => selectedCustomerId = value),
                  ),
                  const SizedBox(height: 20),
                  if (selectedCustomerId != null)
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selected Customer',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const Divider(height: 20),
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                  child: Icon(
                                    Icons.person,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        mockCustomers
                                            .firstWhere((c) => c.id == selectedCustomerId!)
                                            .name,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        mockCustomers
                                            .firstWhere((c) => c.id == selectedCustomerId!)
                                            .phone,
                                        style: Theme.of(context).textTheme.bodyMedium,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                StatusBadge(
                                  label:
                                      '₹${mockCustomers.firstWhere((c) => c.id == selectedCustomerId!).balance.toStringAsFixed(0)}',
                                  color: mockCustomers
                                              .firstWhere((c) => c.id == selectedCustomerId!)
                                              .balance >
                                          0
                                      ? Colors.orange
                                      : Colors.green,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Please select a customer to continue',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Step(
              title: const Text('Products'),
              subtitle: const Text('Select products for this order'),
              isActive: currentStep >= 1,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isDesktop)
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 3.5,
                      children: mockFeedProducts
                          .map((product) => _buildProductCard(context, product))
                          .toList(),
                    )
                  else
                    ...mockFeedProducts
                        .map((product) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildProductCard(context, product),
                            ))
                        .toList(),
                ],
              ),
            ),
            Step(
              title: const Text('Cart'),
              subtitle: Text('${cart.length} item(s) in cart'),
              isActive: currentStep >= 2,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (cart.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 48,
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Your cart is empty',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Go back and add some products',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    )
                  else ...[
                    ...cart.entries.map(
                      (entry) => Dismissible(
                        key: ValueKey(entry.key.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => setState(() => cart.remove(entry.key)),
                        child: Card(
                          elevation: 1,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: NetworkImage(entry.key.image),
                                  radius: 24,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry.key.name,
                                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '₹${entry.key.rate.toStringAsFixed(0)} per ${entry.key.unit}',
                                        style: Theme.of(context).textTheme.bodySmall,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                QuantityStepper(
                                  value: entry.value,
                                  onChanged: (val) =>
                                      setState(() => cart[entry.key] = val),
                                  min: 1,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '₹${(entry.key.rate * entry.value).toStringAsFixed(0)}',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order Summary',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(height: 24),
                            _AmountRow(label: 'Subtotal', value: subtotal),
                            const SizedBox(height: 8),
                            _AmountRow(
                              label: 'Discount (5%)',
                              value: discount,
                              color: Colors.green,
                            ),
                            const Divider(height: 24),
                            _AmountRow(
                              label: 'Grand Total',
                              value: total,
                              highlight: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Payment Status',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 1,
                      child: Column(
                        children: [
                          RadioListTile<String>(
                            value: 'Paid',
                            groupValue: paymentStatus,
                            title: const Text('Paid'),
                            subtitle: const Text('Payment received in full'),
                            secondary: const Icon(Icons.check_circle, color: Colors.green),
                            onChanged: (value) =>
                                setState(() => paymentStatus = value ?? 'Pending'),
                          ),
                          const Divider(height: 1),
                          RadioListTile<String>(
                            value: 'Pending',
                            groupValue: paymentStatus,
                            title: const Text('Pending'),
                            subtitle: const Text('Payment will be collected later'),
                            secondary: const Icon(Icons.schedule, color: Colors.orange),
                            onChanged: (value) =>
                                setState(() => paymentStatus = value ?? 'Pending'),
                          ),
                          const Divider(height: 1),
                          RadioListTile<String>(
                            value: 'Partial',
                            groupValue: paymentStatus,
                            title: const Text('Partial'),
                            subtitle: const Text('Part payment received'),
                            secondary: const Icon(Icons.pie_chart, color: Colors.blue),
                            onChanged: (value) =>
                                setState(() => paymentStatus = value ?? 'Partial'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Step(
              title: const Text('Invoice'),
              subtitle: const Text('Review and generate invoice'),
              isActive: currentStep >= 3,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.receipt_long,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Invoice Preview',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Review your order details',
                                      style: Theme.of(context).textTheme.bodySmall,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 32),
                          _buildInfoTile(
                            context,
                            Icons.person,
                            'Customer',
                            selectedCustomerId != null
                                ? mockCustomers.firstWhere((c) => c.id == selectedCustomerId!).name
                                : 'Not selected',
                          ),
                          const SizedBox(height: 12),
                          _buildInfoTile(
                            context,
                            Icons.shopping_bag,
                            'Total Items',
                            '${cart.length} item(s)',
                          ),
                          const SizedBox(height: 12),
                          _buildInfoTile(
                            context,
                            Icons.payments,
                            'Grand Total',
                            '₹${total.toStringAsFixed(2)}',
                          ),
                          const SizedBox(height: 12),
                          _buildInfoTile(
                            context,
                            Icons.account_balance_wallet,
                            'Payment Status',
                            paymentStatus,
                          ),
                          const Divider(height: 32),
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: cart.isEmpty ? null : () => _showInvoice('Print'),
                                  icon: const Icon(Icons.print_outlined),
                                  label: const Text('Print Invoice'),
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.all(16),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FilledButton.tonalIcon(
                                  onPressed: cart.isEmpty ? null : () => _showInvoice('Share'),
                                  icon: const Icon(Icons.ios_share),
                                  label: const Text('Share Invoice'),
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.all(16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (cart.isEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber, color: Colors.orange.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Cart is empty. Please add items to generate invoice.',
                              style: TextStyle(
                                color: Colors.orange.shade900,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, FeedProduct product) {
    final isInCart = cart.containsKey(product);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(product.image),
          radius: 24,
        ),
        title: Text(
          product.name,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        subtitle: Text(
          '₹${product.rate.toStringAsFixed(0)} • ${product.stock} ${product.unit} left',
          style: Theme.of(context).textTheme.bodySmall,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        trailing: FilledButton.icon(
          onPressed: () {
            setState(() {
              cart.update(product, (value) => value + 1, ifAbsent: () => 1);
            });
          },
          style: FilledButton.styleFrom(
            backgroundColor: isInCart
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.primaryContainer,
            foregroundColor: isInCart
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          icon: Icon(isInCart ? Icons.add_shopping_cart : Icons.add, size: 18),
          label: Text(isInCart ? 'Added' : 'Add'),
        ),
      ),
    );
  }

  InvoiceData _generateInvoiceData() {
    final customer = mockCustomers.firstWhere(
      (c) => c.id == selectedCustomerId,
      orElse: () => mockCustomers.first,
    );

    final items = cart.entries.map((entry) {
      return InvoiceItem(
        name: entry.key.name,
        quantity: entry.value,
        unit: entry.key.unit,
        rate: entry.key.rate,
        amount: entry.key.rate * entry.value,
      );
    }).toList();

    return InvoiceData(
      invoiceNumber: 'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      date: DateTime.now(),
      customerName: customer.name,
      customerPhone: customer.phone,
      customerAddress: customer.shopName,
      items: items,
      subtotal: subtotal,
      discount: discount,
      tax: 0,
      total: total,
      paymentStatus: paymentStatus,
      notes: 'Thank you for your business!',
    );
  }

  Future<void> _showInvoice(String action) async {
    final invoiceData = _generateInvoiceData();
    
    if (action == 'Print') {
      await InvoiceGenerator.show(context, data: invoiceData);
    } else if (action == 'Share') {
      await InvoiceGenerator.show(context, data: invoiceData);
    }
  }
}

  Widget _buildInfoTile(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.value,
    this.highlight = false,
    this.color,
  });

  final String label;
  final double value;
  final bool highlight;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '₹${value.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
                  color: color ?? (highlight
                      ? Theme.of(context).colorScheme.primary
                      : null),
                ),
            overflow: TextOverflow.visible,
          ),
        ],
      ),
    );
  }
}
