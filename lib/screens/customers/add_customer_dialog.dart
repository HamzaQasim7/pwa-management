import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../presentation/providers/customer_provider.dart';

/// Show Add Customer Dialog (Desktop)
void showAddCustomerDialog(BuildContext context) {
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
                    Icons.person_add_alt_1,
                    color: Theme.of(context).colorScheme.primary,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add New Customer',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Register a new customer',
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
            const Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: _CustomerForm(),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Show Add Customer Bottom Sheet (Mobile)
void showAddCustomerBottomSheet(BuildContext context) {
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
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            Icons.person_add_alt_1,
                            color: Theme.of(context).colorScheme.primary,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Add New Customer',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Register a new customer',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const _CustomerForm(),
              ],
            ),
          );
        },
      );
    },
  );
}

/// Customer Form Widget
class _CustomerForm extends StatefulWidget {
  const _CustomerForm();

  @override
  State<_CustomerForm> createState() => _CustomerFormState();
}

class _CustomerFormState extends State<_CustomerForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _shopNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _areaController = TextEditingController();
  final _creditLimitController = TextEditingController();
  final _notesController = TextEditingController();
  String _customerType = 'Retail';

  @override
  void dispose() {
    _nameController.dispose();
    _shopNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _areaController.dispose();
    _creditLimitController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<CustomerProvider>();
    
    final success = await provider.addCustomer(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      shopName: _shopNameController.text.trim().isEmpty ? null : _shopNameController.text.trim(),
      address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      customerType: _customerType,
      city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
      area: _areaController.text.trim().isEmpty ? null : _areaController.text.trim(),
      creditLimit: _creditLimitController.text.trim().isEmpty 
          ? null 
          : double.tryParse(_creditLimitController.text.trim()),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          key: const ValueKey('customer_added_snackbar'),
          content: const Text('Customer added successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          key: const ValueKey('customer_error_snackbar'),
          content: Text(provider.error ?? 'Failed to add customer'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Customer Type
          DropdownButtonFormField<String>(
            value: _customerType,
            decoration: const InputDecoration(
              labelText: 'Customer Type',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.category),
            ),
            items: const [
              DropdownMenuItem(value: 'Retail', child: Text('Retail Customer')),
              DropdownMenuItem(value: 'Wholesale', child: Text('Wholesale Customer')),
              DropdownMenuItem(value: 'VIP', child: Text('VIP Customer')),
            ],
            onChanged: (value) {
              setState(() {
                _customerType = value ?? 'Retail';
              });
            },
          ),
          const SizedBox(height: 12),

          // Name
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Customer Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
              hintText: 'Enter full name',
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter customer name';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Shop/Business Name
          TextFormField(
            controller: _shopNameController,
            decoration: const InputDecoration(
              labelText: 'Shop/Business Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.store),
              hintText: 'Enter shop name',
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),

          // Phone Number
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),
              hintText: '+91 98765 43210',
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Email (Optional)
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email (Optional)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
              hintText: 'customer@example.com',
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),

          // Address
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Address',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_on),
              hintText: 'Enter complete address',
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 12),

          // City and Area in Row
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(
                    labelText: 'City',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_city),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _areaController,
                  decoration: const InputDecoration(
                    labelText: 'Area',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.map),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Credit Limit (for wholesale)
          if (_customerType != 'Retail') ...[
            TextFormField(
              controller: _creditLimitController,
              decoration: const InputDecoration(
                labelText: 'Credit Limit',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.account_balance_wallet),
                hintText: '0',
                prefixText: 'Rs  ',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
          ],

          // Notes
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Notes (Optional)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.note),
              hintText: 'Any additional information',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 20),

          // Save Button
          Consumer<CustomerProvider>(
            builder: (context, provider, child) {
              return FilledButton.icon(
                onPressed: provider.isLoading ? null : _saveCustomer,
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
                label: Text(provider.isLoading ? 'Saving...' : 'Save Customer'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
