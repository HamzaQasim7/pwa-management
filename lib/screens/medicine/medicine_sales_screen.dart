import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/customer_model.dart';
import '../../data/models/medicine_model.dart';
import '../../data/models/sale_model.dart';
import '../../presentation/providers/customer_provider.dart';
import '../../presentation/providers/medicine_provider.dart';
import '../../presentation/providers/sale_provider.dart';
import '../../utils/invoice_generator.dart';
import '../../utils/responsive_layout.dart';
import '../../widgets/custom_quantity_input.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/loading_shimmer.dart';
import '../../widgets/empty_state.dart';

class MedicineSalesScreen extends StatefulWidget {
  const MedicineSalesScreen({super.key});

  @override
  State<MedicineSalesScreen> createState() => _MedicineSalesScreenState();
}

class _MedicineSalesScreenState extends State<MedicineSalesScreen> {
  int currentStep = 0;
  CustomerModel? selectedCustomer;
  final Map<MedicineModel, double> billItems = {}; // Changed to double for custom quantities
  String paymentMethod = 'Cash';
  String paymentStatus = 'Pending';
  double amountReceived = 0;
  String _searchQuery = '';
  double _discountPercent = 0.0;
  final TextEditingController _discountController = TextEditingController();

  double get subtotal => billItems.entries
      .map((entry) => entry.key.sellingPrice * entry.value)
      .fold(0.0, (value, element) => value + element);

  double get discount => subtotal * (_discountPercent / 100);
  double get grandTotal => subtotal - discount;
  double get profit =>
      billItems.entries.map((e) => (e.key.sellingPrice - e.key.purchasePrice) * e.value).fold(0.0, (a, b) => a + b);

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
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Sales Wizard'),
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
              onStepContinue: _handleStepContinue,
              onStepCancel: () {
                if (currentStep > 0) setState(() => currentStep -= 1);
              },
              controlsBuilder: (context, details) {
                return Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    children: [
                      Consumer<SaleProvider>(
                        builder: (context, provider, child) {
                          final isLastStep = currentStep == 3;
                          return FilledButton.icon(
                            onPressed: provider.isLoading ? null : details.onStepContinue,
                            icon: provider.isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(isLastStep ? Icons.check : Icons.arrow_forward),
                            label: Text(isLastStep 
                                ? (provider.isLoading ? 'Saving...' : 'Finish') 
                                : 'Continue'),
                          );
                        },
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
                  subtitle: const Text('Select customer for this sale'),
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
                  title: const Text('Invoice'),
                  subtitle: const Text('Review and generate invoice'),
                  content: _buildInvoiceStep(),
                  isActive: currentStep >= 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleStepContinue() async {
    if (currentStep < 3) {
      setState(() => currentStep += 1);
    } else {
      // Final step - save sale
      await _saveSale();
    }
  }

  Widget _buildCustomerStep() {
    return Consumer<CustomerProvider>(
      builder: (context, customerProvider, child) {
        if (customerProvider.isLoading && customerProvider.allCustomers.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final customers = customerProvider.allCustomers;

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
            const SizedBox(height: 20),
            if (customers.isEmpty)
              const EmptyState(
                icon: Icons.person_outline,
                title: 'No Customers',
                subtitle: 'Add customers first to create sales',
              )
            else
              DropdownButtonFormField<CustomerModel>(
                value: selectedCustomer,
                decoration: const InputDecoration(
                  labelText: 'Search customers',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                items: customers
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(
                          '${c.name} • ${c.shopName ?? "No shop"}',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => selectedCustomer = value),
              ),
            const SizedBox(height: 20),
            if (selectedCustomer != null)
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
                                  selectedCustomer!.name,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  selectedCustomer!.phone,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                          StatusBadge(
                            label: selectedCustomer!.customerType,
                            color: selectedCustomer!.customerType == 'VIP' 
                                ? Colors.green 
                                : Colors.blue,
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
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
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
                        'Quick sale mode - customer is optional',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildMedicinesStep() {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    
    return Consumer<MedicineProvider>(
      builder: (context, medicineProvider, child) {
        final allMedicines = medicineProvider.allMedicines;
        final isLoading = medicineProvider.isLoading;

        if (isLoading && allMedicines.isEmpty) {
          return LoadingShimmer(
            child: Column(
              children: List.generate(
                4,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        if (allMedicines.isEmpty) {
          return const EmptyState(
            icon: Icons.medication_outlined,
            title: 'No Medicines',
            subtitle: 'Add medicines to your inventory first',
          );
        }

        // Filter medicines by search query
        final medicines = _searchQuery.isEmpty
            ? allMedicines
            : allMedicines.where((m) {
                final query = _searchQuery.toLowerCase();
                return m.name.toLowerCase().contains(query) ||
                    m.genericName.toLowerCase().contains(query) ||
                    m.category.toLowerCase().contains(query);
              }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search medicines',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            const SizedBox(height: 12),
            if (isDesktop)
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 3.5,
                children: medicines
                    .map((medicine) => _buildMedicineCard(context, medicine))
                    .toList(),
              )
            else
              ...medicines
                  .map((medicine) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildMedicineCard(context, medicine),
                      ))
                  .toList(),
          ],
        );
      },
    );
  }

  Widget _buildMedicineCard(BuildContext context, MedicineModel medicine) {
    final inBillQty = billItems[medicine] ?? 0.0;
    final availableStock = medicine.quantity.toDouble() - inBillQty;
    final canAddMore = availableStock > 0;
    final isOutOfStock = medicine.quantity <= 0;
    final isInBill = billItems.containsKey(medicine);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isOutOfStock ? BorderSide(
          color: Theme.of(context).colorScheme.error.withOpacity(0.3),
        ) : BorderSide.none,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isOutOfStock 
              ? Theme.of(context).colorScheme.errorContainer
              : Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.medication,
            color: isOutOfStock
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          medicine.name,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: isOutOfStock ? Theme.of(context).colorScheme.error : null,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        subtitle: Text(
          'Stock ${medicine.quantity} ${medicine.unit} • Batch ${medicine.batchNo}${isInBill ? ' (${inBillQty.toStringAsFixed(2)} ${medicine.unit} in bill)' : ''}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isOutOfStock ? Theme.of(context).colorScheme.error : null,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        trailing: FilledButton.icon(
          onPressed: canAddMore ? () {
            setState(() {
              // Add 0.1 for medicines (e.g., 100ml from 1000ml bottle)
              billItems.update(medicine, (value) => value + 0.1, ifAbsent: () => 0.1);
            });
            _toast('Added ${medicine.name} to bill');
          } : null,
          style: FilledButton.styleFrom(
            backgroundColor: isInBill
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.primaryContainer,
            foregroundColor: isInBill
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          icon: Icon(isInBill ? Icons.add_shopping_cart : Icons.add, size: 18),
          label: Text(
            isOutOfStock 
                ? 'Out' 
                : (isInBill && !canAddMore 
                    ? 'Max' 
                    : (isInBill ? 'Added' : 'Add')),
          ),
        ),
      ),
    );
  }

  Widget _buildBillReviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (billItems.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
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
                    'Your bill is empty',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Go back and add some medicines',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          )
        else ...[
          ...billItems.entries.map(
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
              onDismissed: (_) => setState(() => billItems.remove(entry.key)),
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
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        child: Icon(
                          Icons.medication,
                          color: Theme.of(context).colorScheme.primary,
                        ),
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
                              'Rs ${entry.key.sellingPrice.toStringAsFixed(0)} • Profit Rs ${(entry.key.sellingPrice - entry.key.purchasePrice).toStringAsFixed(0)}',
                              style: Theme.of(context).textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      CustomQuantityInput(
                        value: entry.value,
                        onChanged: (val) =>
                            setState(() => billItems[entry.key] = val),
                        min: 0.1,
                        max: entry.key.quantity.toDouble(),
                        step: 0.1,
                        unit: entry.key.unit,
                        allowDecimals: true,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Rs ${(entry.key.sellingPrice * entry.value).toStringAsFixed(0)}',
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
                    'Bill Summary',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(height: 24),
                  _AmountRow(label: 'Subtotal', value: subtotal),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _discountController,
                          decoration: InputDecoration(
                            labelText: 'Discount (%)',
                            hintText: '0',
                            prefixIcon: const Icon(Icons.percent),
                            suffixText: '%',
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              _discountPercent = double.tryParse(value) ?? 0.0;
                              if (_discountPercent < 0) _discountPercent = 0;
                              if (_discountPercent > 100) _discountPercent = 100;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: _AmountRow(
                          label: 'Discount',
                          value: discount,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _AmountRow(label: 'Total Profit', value: profit, highlighted: true),
                  const Divider(height: 24),
                  _AmountRow(
                    label: 'Grand Total',
                    value: grandTotal,
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
                  value: 'Partially Paid',
                  groupValue: paymentStatus,
                  title: const Text('Partial'),
                  subtitle: const Text('Part payment received'),
                  secondary: const Icon(Icons.pie_chart, color: Colors.blue),
                  onChanged: (value) =>
                      setState(() => paymentStatus = value ?? 'Partially Paid'),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInvoiceStep() {
    return Column(
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
                            'Review your sale details',
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
                  selectedCustomer?.name ?? 'Walk-in Customer',
                ),
                const SizedBox(height: 12),
                _buildInfoTile(
                  context,
                  Icons.shopping_bag,
                  'Total Items',
                  '${billItems.length} item(s)',
                ),
                const SizedBox(height: 12),
                _buildInfoTile(
                  context,
                  Icons.payments,
                  'Grand Total',
                  'Rs ${grandTotal.toStringAsFixed(2)}',
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
                        onPressed: billItems.isEmpty ? null : () => _showInvoice('Print'),
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
                        onPressed: billItems.isEmpty ? null : () => _showInvoice('Share'),
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
        if (billItems.isEmpty) ...[
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
                    'Bill is empty. Please add items to generate invoice.',
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
    );
  }

  InvoiceData _generateInvoiceData() {
    final items = billItems.entries.map((entry) {
      return InvoiceItem(
        name: entry.key.name,
        quantity: entry.value,
        unit: entry.key.unit,
        rate: entry.key.sellingPrice,
        amount: entry.key.sellingPrice * entry.value,
      );
    }).toList();

    return InvoiceData(
      invoiceNumber: 'SALE-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      date: DateTime.now(),
      customerName: selectedCustomer?.name ?? 'Walk-in Customer',
      customerPhone: selectedCustomer?.phone ?? '',
      customerAddress: selectedCustomer?.shopName ?? '',
      items: items,
      subtotal: subtotal,
      discount: discount,
      tax: 0,
      total: grandTotal,
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
        quantity: quantity.toInt(), // Convert to int for model (rounds down, but we track decimal in calculation)
        rate: medicine.sellingPrice,
        discount: 0,
        total: itemTotal, // Use decimal for accurate total
        purchasePrice: medicine.purchasePrice,
      ));
    }

    // Create sale
    final success = await saleProvider.createSale(
      paymentMethod: paymentMethod,
      discount: discount,
    );

    if (success) {
      // Deduct stock for each medicine in the sale (round decimal quantities)
      for (final entry in billItems.entries) {
        // Round to nearest integer for stock deduction
        final qtyToDeduct = entry.value.round();
        await medicineProvider.deductStock(entry.key.id, qtyToDeduct);
      }
      
      _toast('Sale recorded successfully!');
      // Clear local state
      setState(() {
        billItems.clear();
        selectedCustomer = null;
        currentStep = 0;
        amountReceived = 0;
        paymentMethod = 'Cash';
        paymentStatus = 'Pending';
        _discountPercent = 0.0;
        _discountController.clear();
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
  const _AmountRow({
    required this.label,
    required this.value,
    this.highlight = false,
    this.highlighted = false,
    this.color,
  });

  final String label;
  final double value;
  final bool highlight;
  final bool highlighted;
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
            'Rs ${value.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: (highlight || highlighted) ? FontWeight.bold : FontWeight.w600,
                  color: color ?? ((highlight || highlighted)
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
