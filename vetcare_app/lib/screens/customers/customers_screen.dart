import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/customer.dart';
import '../../widgets/customer_card.dart';
import 'customer_detail_screen.dart';

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key, required this.drawerBuilder});

  final WidgetBuilder drawerBuilder;

  void _openDetails(BuildContext context, Customer customer) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CustomerDetailScreen(customer: customer)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Builder(builder: drawerBuilder),
      appBar: AppBar(
        title: const Text('Customers'),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: mockCustomers.length,
          itemBuilder: (context, index) {
            final customer = mockCustomers[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: CustomerCard(
                customer: customer,
                onTap: () => _openDetails(context, customer),
                onCall: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Calling ${customer.phone} (mock)')),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add Customer form coming soon.')),
        ),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add Customer'),
      ),
    );
  }
}
