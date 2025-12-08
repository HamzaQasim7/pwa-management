import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/customer_model.dart';
import '../../presentation/providers/customer_provider.dart';
import '../../presentation/providers/order_provider.dart';
import '../../utils/responsive_layout.dart';
import '../../core/utils/date_formatter.dart';

class AddPaymentDialog extends StatefulWidget {
  const AddPaymentDialog({
    super.key,
    required this.customer,
  });

  final CustomerModel customer;

  @override
  State<AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends State<AddPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  String _paymentMethod = 'Cash';
  DateTime _paymentDate = DateTime.now();
  String? _selectedOrderId;
  bool _applyToOrder = false;

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _savePayment() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final customerProvider = context.read<CustomerProvider>();
    final orderProvider = context.read<OrderProvider>();

    // If applying to order, record payment on that order
    if (_applyToOrder && _selectedOrderId != null) {
      final success =
          await orderProvider.recordPayment(_selectedOrderId!, amount);
      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(orderProvider.error ?? 'Failed to record payment'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
        return;
      }
    }

    // Update customer balance
    // Payment adds to balance (reduces debt if negative, increases credit if positive)
    // Example: If balance is -5000 (owes 5000) and payment is 2000, new balance = -3000
    final balanceChange = amount; // Add payment amount to balance
    final success =
        await customerProvider.updateBalance(widget.customer.id, balanceChange);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Payment of Rs ${amount.toStringAsFixed(0)} recorded successfully'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
    } else if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(customerProvider.error ?? 'Failed to record payment'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final outstandingBalance = widget.customer.balance.abs();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 600 : double.infinity,
          maxHeight: isDesktop ? 700 : MediaQuery.of(context).size.height * 0.9,
        ),
        child: Form(
          key: _formKey,
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
                      Icons.payment,
                      color: Theme.of(context).colorScheme.primary,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add Payment',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.customer.name,
                            style: Theme.of(context).textTheme.bodyMedium,
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
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Outstanding Balance Card
                      Card(
                        color: widget.customer.balance < 0
                            ? Colors.orange.shade50
                            : widget.customer.balance > 0
                                ? Colors.green.shade50
                                : Colors.grey.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                widget.customer.balance < 0
                                    ? Icons.warning_amber
                                    : widget.customer.balance > 0
                                        ? Icons.account_balance_wallet
                                        : Icons.check_circle,
                                color: widget.customer.balance < 0
                                    ? Colors.orange
                                    : widget.customer.balance > 0
                                        ? Colors.green
                                        : Colors.grey,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.customer.balance < 0
                                          ? 'Outstanding Due'
                                          : widget.customer.balance > 0
                                              ? 'Credit Balance'
                                              : 'No Balance',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                    Text(
                                      'Rs ${outstandingBalance.toStringAsFixed(0)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: widget.customer.balance < 0
                                                ? Colors.orange.shade900
                                                : widget.customer.balance > 0
                                                    ? Colors.green.shade900
                                                    : Colors.grey.shade900,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Amount
                      TextFormField(
                        controller: _amountController,
                        decoration: const InputDecoration(
                          labelText: 'Payment Amount',
                          hintText: 'Enter amount',
                          prefixIcon: Icon(Icons.attach_money),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter payment amount';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null || amount <= 0) {
                            return 'Please enter a valid amount';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Payment Method
                      DropdownButtonFormField<String>(
                        value: _paymentMethod,
                        decoration: const InputDecoration(
                          labelText: 'Payment Method',
                          prefixIcon: Icon(Icons.payment),
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          'Cash',
                          'EasyPaisa Or Jazz Cash',
                          'Card',
                          'Bank Transfer',
                          'Cheque'
                        ]
                            .map((method) => DropdownMenuItem(
                                  value: method,
                                  child: Text(method),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _paymentMethod = value);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      // Payment Date
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _paymentDate,
                            firstDate: DateTime.now()
                                .subtract(const Duration(days: 365)),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() => _paymentDate = date);
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Payment Date',
                            prefixIcon: Icon(Icons.calendar_today),
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            DateFormatter.formatDate(_paymentDate),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Apply to Order Checkbox
                      Consumer<OrderProvider>(
                        builder: (context, orderProvider, child) {
                          final pendingOrders = orderProvider.allOrders
                              .where((o) =>
                                  o.customerId == widget.customer.id &&
                                  (o.paymentStatus == 'Pending' ||
                                      o.paymentStatus == 'Partially Paid'))
                              .toList();

                          if (pendingOrders.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CheckboxListTile(
                                title: const Text('Apply payment to order'),
                                value: _applyToOrder,
                                onChanged: (value) {
                                  setState(() {
                                    _applyToOrder = value ?? false;
                                    if (!_applyToOrder) {
                                      _selectedOrderId = null;
                                    } else if (pendingOrders.isNotEmpty) {
                                      _selectedOrderId = pendingOrders.first.id;
                                    }
                                  });
                                },
                              ),
                              if (_applyToOrder) ...[
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: _selectedOrderId,
                                  decoration: const InputDecoration(
                                    labelText: 'Select Order',
                                    prefixIcon: Icon(Icons.receipt_long),
                                    border: OutlineInputBorder(),
                                  ),
                                  items: pendingOrders.map((order) {
                                    final remaining =
                                        order.total - (order.paidAmount ?? 0);
                                    return DropdownMenuItem(
                                      value: order.id,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            order.orderNumber,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12),
                                          ),
                                          Text(
                                            'Rs ${order.total.toStringAsFixed(0)} • Remaining: Rs ${remaining.toStringAsFixed(0)}',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() => _selectedOrderId = value);
                                  },
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      // Notes
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes (Optional)',
                          hintText: 'Add any notes about this payment',
                          prefixIcon: Icon(Icons.note),
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              // Footer Actions
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Consumer<CustomerProvider>(
                        builder: (context, provider, child) {
                          return FilledButton.icon(
                            onPressed: provider.isLoading ? null : _savePayment,
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
                            label: const Text('Record Payment'),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
