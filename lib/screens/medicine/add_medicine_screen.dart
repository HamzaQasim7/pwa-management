import 'package:flutter/material.dart';

import '../../utils/responsive_layout.dart';
import '../../widgets/date_picker_field.dart';
import '../../widgets/image_picker_widget.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  DateTime mfgDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime expiryDate = DateTime.now().add(const Duration(days: 365));

  int get remainingDays => expiryDate.difference(DateTime.now()).inDays;

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Medicine'),
        centerTitle: isDesktop,
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 900 : double.infinity,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(
                ResponsiveLayout.value<double>(
                  context: context,
                  mobile: 16.0,
                  tablet: 20.0,
                  desktop: 24.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle('Basic'),
                  const SizedBox(height: 16),
                  const ImagePickerWidget(label: 'Tap to choose medicine photo'),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Medicine Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.medication),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Generic name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.science),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Antibiotic', child: Text('Antibiotic')),
                      DropdownMenuItem(value: 'Vitamin', child: Text('Vitamin')),
                      DropdownMenuItem(value: 'Vaccine', child: Text('Vaccine')),
                      DropdownMenuItem(value: 'Antiseptic', child: Text('Antiseptic')),
                      DropdownMenuItem(value: 'Painkiller', child: Text('Painkiller')),
                    ],
                    onChanged: (_) {},
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Manufacturer',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.business),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const _SectionTitle('Batch & Dates'),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Batch number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.qr_code),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DatePickerField(
                    label: 'Manufactured on',
                    initialDate: mfgDate,
                    onChanged: (value) => setState(() => mfgDate = value),
                  ),
                  const SizedBox(height: 12),
                  DatePickerField(
                    label: 'Expiry date',
                    initialDate: expiryDate,
                    onChanged: (value) => setState(() => expiryDate = value),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: remainingDays < 30
                          ? Colors.red.shade50
                          : remainingDays < 90
                              ? Colors.orange.shade50
                              : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: remainingDays < 30
                            ? Colors.red.shade200
                            : remainingDays < 90
                                ? Colors.orange.shade200
                                : Colors.green.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          remainingDays < 30
                              ? Icons.warning
                              : remainingDays < 90
                                  ? Icons.info
                                  : Icons.check_circle,
                          color: remainingDays < 30
                              ? Colors.red
                              : remainingDays < 90
                                  ? Colors.orange
                                  : Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Auto calculated: $remainingDays days remaining',
                          style: TextStyle(
                            color: remainingDays < 30
                                ? Colors.red.shade900
                                : remainingDays < 90
                                    ? Colors.orange.shade900
                                    : Colors.green.shade900,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const _SectionTitle('Pricing'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Purchase price',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.shopping_cart),
                            prefixText: '₹ ',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Selling price',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.currency_rupee),
                            prefixText: '₹ ',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Discount %',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.percent),
                      suffixText: '%',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.percent,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Profit margin',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Will be auto calculated once backend arrives.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
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
                  const _SectionTitle('Stock'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Quantity',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.inventory),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Unit',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'bottles', child: Text('Bottles')),
                            DropdownMenuItem(value: 'strips', child: Text('Strips')),
                            DropdownMenuItem(value: 'packs', child: Text('Packs')),
                            DropdownMenuItem(value: 'boxes', child: Text('Boxes')),
                          ],
                          onChanged: (_) {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Minimum stock level',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.warning_amber),
                      hintText: 'Alert when stock falls below this',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  const _SectionTitle('Additional'),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Storage instructions',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.storage),
                      hintText: 'e.g., Store in cool, dry place',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                      hintText: 'Additional notes or description',
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medicine saved successfully (mock).'),
            behavior: SnackBarBehavior.floating,
          ),
        ),
        icon: const Icon(Icons.check),
        label: const Text('Save Medicine'),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}
