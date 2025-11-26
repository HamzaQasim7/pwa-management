import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/medicine.dart';
import '../../widgets/quantity_stepper.dart';
import '../../widgets/status_badge.dart';
import 'invoice_preview_screen.dart';

class MedicineSalesScreen extends StatefulWidget {
  const MedicineSalesScreen({super.key});

  @override
  State<MedicineSalesScreen> createState() => _MedicineSalesScreenState();
}

class _MedicineSalesScreenState extends State<MedicineSalesScreen> {
  int currentStep = 0;
  String? selectedCustomer;
  final Map<Medicine, int> billItems = {};
  String paymentMethod = 'Cash';
  double amountReceived = 0;

  double get subtotal => billItems.entries
      .map((entry) => entry.key.sellingPrice * entry.value)
      .fold(0, (value, element) => value + element);

  double get discount => subtotal * 0.04;
  double get grandTotal => subtotal - discount;
  double get profit =>
      billItems.entries.map((e) => (e.key.sellingPrice - e.key.purchasePrice) * e.value).fold(0, (a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medicine Sales Wizard')),
      body: SafeArea(
        child: Stepper(
          currentStep: currentStep,
          onStepContinue: () {
            if (currentStep < 3) {
              setState(() => currentStep += 1);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Invoice generated (mock).')),
              );
            }
          },
          onStepCancel: () {
            if (currentStep > 0) setState(() => currentStep -= 1);
          },
          steps: [
            Step(
              title: const Text('Customer'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FilledButton.icon(
                    onPressed: () => _toast('Quick sale started'),
                    icon: const Icon(Icons.flash_on),
                    label: const Text('Quick Sale'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Select customer'),
                    items: mockCustomers
                        .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                        .toList(),
                    onChanged: (value) => setState(() => selectedCustomer = value),
                  ),
                  const SizedBox(height: 12),
                  if (selectedCustomer != null)
                    Card(
                      child: ListTile(
                        title: Text(mockCustomers.firstWhere((c) => c.id == selectedCustomer).shopName),
                        subtitle: Text(mockCustomers.firstWhere((c) => c.id == selectedCustomer).phone),
                        trailing: StatusBadge(label: 'Trusted', color: Colors.green),
                      ),
                    ),
                ],
              ),
              isActive: currentStep >= 0,
            ),
            Step(
              title: const Text('Add Medicines'),
              content: Column(
                children: [
                  TextField(decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search medicines')),
                  const SizedBox(height: 12),
                  ...mockMedicines.take(5).map(
                    (medicine) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(medicine.name, style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 4),
                            Text('Stock ${medicine.quantity} • Batch ${medicine.batchNo}'),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(labelText: 'Batch'),
                                    items: [medicine.batchNo]
                                        .map((batch) => DropdownMenuItem(value: batch, child: Text(batch)))
                                        .toList(),
                                    onChanged: (_) {},
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    decoration: const InputDecoration(labelText: 'Quantity'),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text('₹${medicine.sellingPrice}'),
                              subtitle: const Text('Price breakdown soon'),
                              trailing: FilledButton(
                                onPressed: () {
                                  setState(() {
                                    billItems.update(medicine, (value) => value + 1, ifAbsent: () => 1);
                                  });
                                },
                                child: const Text('Add to Bill'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              isActive: currentStep >= 1,
            ),
            Step(
              title: const Text('Bill Review'),
              content: Column(
                children: [
                  if (billItems.isEmpty)
                    const Text('No medicines added yet')
                  else
                    ...billItems.entries.map(
                      (entry) => Dismissible(
                        key: ValueKey(entry.key.id),
                        onDismissed: (_) => setState(() => billItems.remove(entry.key)),
                        child: Card(
                          child: ListTile(
                            title: Text(entry.key.name),
                            subtitle: Text('₹${entry.key.sellingPrice} • Profit ₹${(entry.key.sellingPrice - entry.key.purchasePrice).toStringAsFixed(0)}'),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                QuantityStepper(
                                  value: entry.value,
                                  min: 1,
                                  onChanged: (value) => setState(() => billItems[entry.key] = value),
                                ),
                                Text('Line: ₹${(entry.key.sellingPrice * entry.value).toStringAsFixed(0)}'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _AmountRow(label: 'Subtotal', value: subtotal),
                          _AmountRow(label: 'Discount', value: discount),
                          _AmountRow(label: 'Total profit', value: profit, highlighted: true),
                          const Divider(),
                          _AmountRow(label: 'Grand total', value: grandTotal, highlighted: true),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              isActive: currentStep >= 2,
            ),
            Step(
              title: const Text('Payment'),
              content: Column(
                children: [
                  Wrap(
                    spacing: 12,
                    children: ['Cash', 'UPI', 'Card']
                        .map(
                          (method) => ChoiceChip(
                            label: Text(method),
                            selected: paymentMethod == method,
                            onSelected: (_) => setState(() => paymentMethod = method),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Amount received'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => setState(() => amountReceived = double.tryParse(value) ?? 0),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Change: ₹${(amountReceived - grandTotal).toStringAsFixed(0)}'),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: ListTile(
                      leading: const Icon(Icons.receipt_long),
                      title: const Text('Invoice Preview'),
                      subtitle: Text('Total ₹${grandTotal.toStringAsFixed(0)}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.open_in_new),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const InvoicePreviewScreen()),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _toast('Print invoice'),
                          icon: const Icon(Icons.print),
                          label: const Text('Print'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => _toast('Share invoice'),
                          icon: const Icon(Icons.share),
                          label: const Text('Share'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              isActive: currentStep >= 3,
            ),
          ],
        ),
      ),
    );
  }

  void _toast(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({required this.label, required this.value, this.highlighted = false});

  final String label;
  final double value;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label),
          const Spacer(),
          Text(
            '₹${value.toStringAsFixed(0)}',
            style: TextStyle(
              fontWeight: highlighted ? FontWeight.bold : FontWeight.w600,
              color: highlighted ? Theme.of(context).colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }
}
