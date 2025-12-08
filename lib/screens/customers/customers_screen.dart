import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/customer.dart';
import '../../utils/responsive_layout.dart';
import '../../widgets/customer_card.dart';
import 'customer_detail_screen.dart';
import 'add_customer_dialog.dart';

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key, required this.drawerBuilder});

  final WidgetBuilder drawerBuilder;

  void _openDetails(BuildContext context, Customer customer) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CustomerDetailScreen(customer: customer)),
    );
  }

  void _showAddCustomerDialog(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    
    if (isDesktop) {
      showAddCustomerDialog(context);
    } else {
      showAddCustomerBottomSheet(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: context.isMobile ? Builder(builder: drawerBuilder) : null,
      appBar: context.isDesktop ? null : AppBar(
        title: const Text('Customers'),
      ),
      body: SafeArea(
        child: ResponsiveContentContainer(
          child: ResponsiveLayout.builder(
            context: context,
            mobile: (ctx) => ListView.builder(
              padding: ResponsiveLayout.padding(ctx),
              itemCount: mockCustomers.length,
              itemBuilder: (context, index) {
                final customer = mockCustomers[index];
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: ResponsiveLayout.spacing(ctx) * 0.75,
                  ),
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
            desktop: (ctx) => GridView.builder(
              padding: ResponsiveLayout.padding(ctx),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: ResponsiveLayout.gridCrossAxisCount(
                  ctx,
                  mobile: 1,
                  tablet: 2,
                  desktop: 2,
                ),
                crossAxisSpacing: ResponsiveLayout.spacing(ctx),
                mainAxisSpacing: ResponsiveLayout.spacing(ctx),
                childAspectRatio: 2.5,
              ),
              itemCount: mockCustomers.length,
              itemBuilder: (context, index) {
                final customer = mockCustomers[index];
                return CustomerCard(
                  customer: customer,
                  onTap: () => _openDetails(context, customer),
                  onCall: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Calling ${customer.phone} (mock)')),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCustomerDialog(context),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add Customer'),
      ),
    );
  }
}
