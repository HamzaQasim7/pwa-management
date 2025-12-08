import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/customer_model.dart';
import '../../data/models/medicine_model.dart';
import '../../data/models/sale_model.dart';
import '../../presentation/providers/customer_provider.dart';
import '../../presentation/providers/medicine_provider.dart';
import '../../presentation/providers/sale_provider.dart';
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
  CustomerModel? selectedCustomer;
  final Map<MedicineModel, int> billItems = {};
  String paymentMethod = 'Cash';
  double amountReceived = 0;
  String _searchQuery = '';

  double get subtotal => billItems.entries
      .map((entry) => entry.key.sellingPrice * entry.value)
      .fold(0, (value, element) => value + element);

  double get discount => subtotal * 0.04;
  double get grandTotal => subtotal - discount;
  double get profit =>
      billItems.entries.map((e) => (e.key.sellingPrice - e.key.purchasePrice) * e.value).fold(0, (a, b) => a + b);

  @override
  void initState() {
    super.initState();
    // Load customers and medicines when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerProvider>().loadCustomers();
      context.read<MedicineProvider>().loadMedicines();
    });
  }

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
              _saveSale();
            }
          },
          onStepCancel: () {
            if (currentStep > 0) setState(() => currentStep -= 1);
          },
          steps: [
            Step(
              title: const Text('Customer'),
              content: _buildCustomerStep(),
              isActive: currentStep >= 0,
            ),
            Step(
              title: const Text('Add Medicines'),
              content: _buildMedicinesStep(),
              isActive: currentStep >= 1,
            ),
            Step(
              title: const Text('Bill Review'),
              content: _buildBillReviewStep(),
              isActive: currentStep >= 2,
            ),
            Step(
              title: const Text('Payment'),
              content: _buildPaymentStep(),
              isActive: currentStep >= 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerStep() {
    return Consumer<CustomerProvider>(
      builder: (context, customerProvider, child) {
        final customers = customerProvider.allCustomers;
        final isLoading = customerProvider.isLoading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FilledButton.icon(
              onPressed: () {
                setState(() {
                  selectedCustomer = null;
                });
                _toast('Quick sale started - no customer selected');
              },
              icon: const Icon(Icons.flash_on),
              label: const Text('Quick Sale'),
            ),
            const SizedBox(height: 12),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (customers.isEmpty)
              const Text('No customers found. Add customers first.')
            else
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Select customer'),
                value: selectedCustomer?.id,
                items: customers
                    .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedCustomer = customers.firstWhere((c) => c.id == value);
                    });
                  }
                },
              ),
            const SizedBox(height: 12),
            if (selectedCustomer != null)
              Card(
                child: ListTile(
                  title: Text(selectedCustomer!.shopName ?? selectedCustomer!.name),
                  subtitle: Text(selectedCustomer!.phone),
                  trailing: StatusBadge(
                    label: selectedCustomer!.customerType,
                    color: selectedCustomer!.customerType == 'VIP' 
                        ? Colors.green 
                        : Colors.blue,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildMedicinesStep() {
    return Consumer<MedicineProvider>(
      builder: (context, medicineProvider, child) {
        final allMedicines = medicineProvider.allMedicines;
        final isLoading = medicineProvider.isLoading;

        // Filter medicines by search query
        final medicines = _searchQuery.isEmpty
            ? allMedicines.take(5).toList()
            : allMedicines.where((m) {
                final query = _searchQuery.toLowerCase();
                return m.name.toLowerCase().contains(query) ||
                    m.genericName.toLowerCase().contains(query) ||
                    m.category.toLowerCase().contains(query);
              }).take(10).toList();

        return Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search medicines',
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            const SizedBox(height: 12),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (medicines.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No medicines found. Add medicines first.'),
              )
            else
              ...medicines.map(
                (medicine) {
                  final inBillQty = billItems[medicine] ?? 0;
                  final availableStock = medicine.quantity - inBillQty;
                  final canAddMore = availableStock > 0;
                  final isOutOfStock = medicine.quantity <= 0;
                  
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: isOutOfStock ? BorderSide(
                        color: Theme.of(context).colorScheme.error.withOpacity(0.3),
                      ) : BorderSide.none,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  medicine.name, 
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: isOutOfStock 
                                        ? Theme.of(context).colorScheme.error 
                                        : null,
                                  ),
                                ),
                              ),
                              if (inBillQty > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '$inBillQty in bill',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Stock ${medicine.quantity} • Batch ${medicine.batchNo}',
                            style: TextStyle(
                              color: isOutOfStock 
                                  ? Theme.of(context).colorScheme.error 
                                  : null,
                            ),
                          ),
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
                            title: Text('Rs ${medicine.sellingPrice}'),
                            subtitle: Text(
                              'Margin: ${medicine.margin.toStringAsFixed(1)}%',
                            ),
                            trailing: FilledButton(
                              onPressed: canAddMore
                                  ? () {
                                      setState(() {
                                        billItems.update(medicine, (value) => value + 1, ifAbsent: () => 1);
                                      });
                                      _toast('Added ${medicine.name} to bill');
                                    }
                                  : null,
                              child: Text(
                                isOutOfStock 
                                    ? 'Out of Stock' 
                                    : (canAddMore ? 'Add to Bill' : 'Max Qty'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildBillReviewStep() {
    return Column(
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
                  subtitle: Text('Rs ${entry.key.sellingPrice} • Profit Rs ${(entry.key.sellingPrice - entry.key.purchasePrice).toStringAsFixed(0)}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      QuantityStepper(
                        value: entry.value,
                        min: 1,
                        onChanged: (value) => setState(() => billItems[entry.key] = value),
                      ),
                      Text('Line: Rs ${(entry.key.sellingPrice * entry.value).toStringAsFixed(0)}'),
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
    );
  }

  Widget _buildPaymentStep() {
    return Consumer<SaleProvider>(
      builder: (context, saleProvider, child) {
        final isLoading = saleProvider.isLoading;

        return Column(
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
              child: Text('Change: Rs ${(amountReceived - grandTotal).toStringAsFixed(0)}'),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: ListTile(
                leading: const Icon(Icons.receipt_long),
                title: const Text('Invoice Preview'),
                subtitle: Text('Total Rs ${grandTotal.toStringAsFixed(0)}'),
                trailing: IconButton(
                  icon: const Icon(Icons.open_in_new),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const InvoicePreviewScreen()),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else
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
        );
      },
    );
  }

  Future<void> _saveSale() async {
    if (billItems.isEmpty) {
      _toast('Please add medicines to the bill');
      return;
    }

    final saleProvider = context.read<SaleProvider>();
    final medicineProvider = context.read<MedicineProvider>();

    // Validate stock availability before creating sale
    for (final entry in billItems.entries) {
      if (entry.key.quantity < entry.value) {
        _toast('Insufficient stock for ${entry.key.name}. Available: ${entry.key.quantity}, Requested: ${entry.value}');
        return;
      }
    }

    // Clear existing cart and add current items
    saleProvider.clearCart();

    // Set selected customer if any
    if (selectedCustomer != null) {
      saleProvider.setSelectedCustomer(
        selectedCustomer!.id,
        selectedCustomer!.name,
      );
    }

    // Add all bill items to cart
    for (final entry in billItems.entries) {
      final medicine = entry.key;
      final quantity = entry.value;
      final itemTotal = medicine.sellingPrice * quantity;

      saleProvider.addToCart(SaleItemModel(
        productId: medicine.id,
        productName: medicine.name,
        quantity: quantity,
        rate: medicine.sellingPrice,
        discount: 0,
        total: itemTotal,
        purchasePrice: medicine.purchasePrice,
      ));
    }

    // Create sale
    final success = await saleProvider.createSale(
      paymentMethod: paymentMethod,
      discount: discount,
    );

    if (success) {
      // Deduct stock for each medicine in the sale
      for (final entry in billItems.entries) {
        await medicineProvider.deductStock(entry.key.id, entry.value);
      }
      
      _toast('Sale recorded successfully!');
      // Clear local state
      setState(() {
        billItems.clear();
        selectedCustomer = null;
        currentStep = 0;
        amountReceived = 0;
        paymentMethod = 'Cash';
      });
      if (mounted) {
        Navigator.of(context).pop();
      }
    } else {
      _toast(saleProvider.error ?? 'Failed to record sale');
    }
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
            'Rs ${value.toStringAsFixed(0)}',
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
