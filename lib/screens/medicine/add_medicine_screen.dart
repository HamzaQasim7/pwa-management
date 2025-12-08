import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../presentation/providers/medicine_provider.dart';
import '../../utils/responsive_layout.dart';
import '../../widgets/date_picker_field.dart';
import '../../widgets/image_picker_widget.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _nameController = TextEditingController();
  final _genericNameController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _batchNoController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _discountController = TextEditingController();
  final _quantityController = TextEditingController();
  final _minStockController = TextEditingController();
  final _storageController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedCategory = 'Antibiotic';
  String _selectedUnit = 'bottles';
  DateTime _mfgDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 365));

  int get remainingDays => _expiryDate.difference(DateTime.now()).inDays;
  
  double get calculatedMargin {
    final purchase = double.tryParse(_purchasePriceController.text) ?? 0;
    final selling = double.tryParse(_sellingPriceController.text) ?? 0;
    if (purchase <= 0) return 0;
    return ((selling - purchase) / purchase) * 100;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _genericNameController.dispose();
    _manufacturerController.dispose();
    _batchNoController.dispose();
    _purchasePriceController.dispose();
    _sellingPriceController.dispose();
    _discountController.dispose();
    _quantityController.dispose();
    _minStockController.dispose();
    _storageController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveMedicine() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<MedicineProvider>();
    
    final success = await provider.addMedicine(
      name: _nameController.text.trim(),
      genericName: _genericNameController.text.trim(),
      category: _selectedCategory,
      batchNo: _batchNoController.text.trim(),
      mfgDate: _mfgDate,
      expiryDate: _expiryDate,
      manufacturer: _manufacturerController.text.trim(),
      purchasePrice: double.tryParse(_purchasePriceController.text) ?? 0,
      sellingPrice: double.tryParse(_sellingPriceController.text) ?? 0,
      discount: double.tryParse(_discountController.text) ?? 0,
      quantity: int.tryParse(_quantityController.text) ?? 0,
      minStockLevel: int.tryParse(_minStockController.text) ?? 10,
      unit: _selectedUnit,
      storage: _storageController.text.trim().isEmpty ? null : _storageController.text.trim(),
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
    );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Medicine added successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to add medicine'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

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
            child: Form(
              key: _formKey,
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
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Medicine Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.medication),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter medicine name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _genericNameController,
                      decoration: const InputDecoration(
                        labelText: 'Generic name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.science),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter generic name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
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
                        DropdownMenuItem(value: 'Antifungal', child: Text('Antifungal')),
                        DropdownMenuItem(value: 'Dewormer', child: Text('Dewormer')),
                        DropdownMenuItem(value: 'Supplement', child: Text('Supplement')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value ?? 'Antibiotic';
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _manufacturerController,
                      decoration: const InputDecoration(
                        labelText: 'Manufacturer',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.business),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter manufacturer';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    const _SectionTitle('Batch & Dates'),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _batchNoController,
                      decoration: const InputDecoration(
                        labelText: 'Batch number',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.qr_code),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter batch number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DatePickerField(
                      label: 'Manufactured on',
                      initialDate: _mfgDate,
                      onChanged: (value) => setState(() => _mfgDate = value),
                    ),
                    const SizedBox(height: 12),
                    DatePickerField(
                      label: 'Expiry date',
                      initialDate: _expiryDate,
                      onChanged: (value) => setState(() => _expiryDate = value),
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
                          child: TextFormField(
                            controller: _purchasePriceController,
                            decoration: const InputDecoration(
                              labelText: 'Purchase price',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.shopping_cart),
                              prefixText: 'Rs  ',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setState(() {}),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Required';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Invalid';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _sellingPriceController,
                            decoration: const InputDecoration(
                              labelText: 'Selling price',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.attach_money),
                              prefixText: 'Rs  ',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setState(() {}),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Required';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Invalid';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _discountController,
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
                                color: calculatedMargin > 0
                                    ? Colors.green.shade50
                                    : Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.percent,
                                color: calculatedMargin > 0
                                    ? Colors.green
                                    : Colors.red,
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
                                    '${calculatedMargin.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: calculatedMargin > 0
                                          ? Colors.green
                                          : Colors.red,
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
                          child: TextFormField(
                            controller: _quantityController,
                            decoration: const InputDecoration(
                              labelText: 'Quantity',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.inventory),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Required';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Invalid';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedUnit,
                            decoration: const InputDecoration(
                              labelText: 'Unit',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'bottles', child: Text('Bottles')),
                              DropdownMenuItem(value: 'strips', child: Text('Strips')),
                              DropdownMenuItem(value: 'packs', child: Text('Packs')),
                              DropdownMenuItem(value: 'boxes', child: Text('Boxes')),
                              DropdownMenuItem(value: 'vials', child: Text('Vials')),
                              DropdownMenuItem(value: 'tubes', child: Text('Tubes')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedUnit = value ?? 'bottles';
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _minStockController,
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
                    TextFormField(
                      controller: _storageController,
                      decoration: const InputDecoration(
                        labelText: 'Storage instructions',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.storage),
                        hintText: 'e.g., Store in cool, dry place',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
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
      ),
      floatingActionButton: Consumer<MedicineProvider>(
        builder: (context, provider, child) {
          return FloatingActionButton.extended(
            heroTag: 'add_medicine_fab',
            onPressed: provider.isLoading ? null : _saveMedicine,
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
            label: Text(provider.isLoading ? 'Saving...' : 'Save Medicine'),
          );
        },
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
