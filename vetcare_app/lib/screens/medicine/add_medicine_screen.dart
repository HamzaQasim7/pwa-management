import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('Add Medicine')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle('Basic'),
              const SizedBox(height: 12),
              const ImagePickerWidget(label: 'Tap to choose medicine photo'),
              const SizedBox(height: 12),
              TextField(decoration: const InputDecoration(labelText: 'Name')),
              const SizedBox(height: 12),
              TextField(decoration: const InputDecoration(labelText: 'Generic name')),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Category'),
                items: const [
                  DropdownMenuItem(value: 'Antibiotic', child: Text('Antibiotic')),
                  DropdownMenuItem(value: 'Vitamin', child: Text('Vitamin')),
                  DropdownMenuItem(value: 'Vaccine', child: Text('Vaccine')),
                ],
                onChanged: (_) {},
              ),
              const SizedBox(height: 12),
              TextField(decoration: const InputDecoration(labelText: 'Manufacturer')),
              const SizedBox(height: 24),
              const _SectionTitle('Batch & Dates'),
              const SizedBox(height: 12),
              TextField(decoration: const InputDecoration(labelText: 'Batch number')),
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
              Text('Auto calculated: $remainingDays days remaining'),
              const SizedBox(height: 24),
              const _SectionTitle('Pricing'),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(labelText: 'Purchase price'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(labelText: 'Selling price'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(labelText: 'Discount %'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.percent),
                  title: const Text('Profit margin'),
                  subtitle: const Text('Will be auto calculated once backend arrives.'),
                ),
              ),
              const SizedBox(height: 24),
              const _SectionTitle('Stock'),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Unit'),
                items: const [
                  DropdownMenuItem(value: 'bottles', child: Text('Bottles')),
                  DropdownMenuItem(value: 'strips', child: Text('Strips')),
                  DropdownMenuItem(value: 'packs', child: Text('Packs')),
                ],
                onChanged: (_) {},
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(labelText: 'Minimum stock level'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              const _SectionTitle('Additional'),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(labelText: 'Storage instructions'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 4,
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medicine saved successfully (mock).')),
        ),
        icon: const Icon(Icons.check),
        label: const Text('Save'),
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
