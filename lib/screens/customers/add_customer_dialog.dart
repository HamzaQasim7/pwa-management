import 'package:flutter/material.dart';

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
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _CustomerForm(
                  onSave: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Customer saved successfully (mock)'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
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
                _CustomerForm(
                  onSave: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Customer saved successfully (mock)'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
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
  final VoidCallback onSave;

  const _CustomerForm({required this.onSave});

  @override
  State<_CustomerForm> createState() => _CustomerFormState();
}

class _CustomerFormState extends State<_CustomerForm> {
  final _formKey = GlobalKey<FormState>();
  String _customerType = 'Retail';

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
            decoration: const InputDecoration(
              labelText: 'Customer Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
              hintText: 'Enter full name',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter customer name';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Shop/Business Name
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Shop/Business Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.store),
              hintText: 'Enter shop name',
            ),
          ),
          const SizedBox(height: 12),

          // Phone Number
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),
              hintText: '+92 300 1234567',
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Email (Optional)
          TextFormField(
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
                  decoration: const InputDecoration(
                    labelText: 'City',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_city),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Area',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.map),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Credit Limit (for wholesale)
          if (_customerType != 'Retail') ...[
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Credit Limit',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.account_balance_wallet),
                hintText: '0',
                prefixText: '₹ ',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
          ],

          // Notes
          TextFormField(
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
          FilledButton.icon(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                widget.onSave();
              }
            },
            icon: const Icon(Icons.check),
            label: const Text('Save Customer'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }
}

