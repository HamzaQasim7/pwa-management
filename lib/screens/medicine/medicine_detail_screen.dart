import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/medicine.dart';
import '../../widgets/status_badge.dart';

class MedicineDetailScreen extends StatelessWidget {
  const MedicineDetailScreen({super.key, required this.medicine});

  final Medicine medicine;

  int get daysToExpiry {
    final expiry = DateTime.tryParse(medicine.expiryDate) ?? DateTime.now();
    return expiry.difference(DateTime.now()).inDays;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(title: Text(medicine.name)),
        body: Column(
          children: [
            Hero(
              tag: medicine.id,
              child: SizedBox(
                height: 220,
                child: InteractiveViewer(
                  child: CachedNetworkImage(
                    imageUrl: medicine.image,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
            ),
            TabBar(
              isScrollable: true,
              tabs: const [
                Tab(text: 'Info'),
                Tab(text: 'Batch'),
                Tab(text: 'Pricing'),
                Tab(text: 'Stock'),
                Tab(text: 'Details'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _InfoSection(medicine: medicine),
                  _BatchSection(medicine: medicine, daysToExpiry: daysToExpiry),
                  _PricingSection(medicine: medicine),
                  _StockSection(medicine: medicine),
                  _DetailSection(medicine: medicine),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _toast(context, 'Print label'),
                    icon: const Icon(Icons.print_rounded),
                    label: const Text('Print'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _toast(context, 'Share detail'),
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'medicine_detail_fab',
          onPressed: () => _toast(context, 'Edit medicine'),
          icon: const Icon(Icons.edit),
          label: const Text('Edit'),
        ),
      ),
    );
  }

  void _toast(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.medicine});

  final Medicine medicine;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _InfoCard(
          title: 'General',
          children: [
            _InfoTile('Name', medicine.name),
            _InfoTile('Generic', medicine.genericName),
            _InfoTile('Category', medicine.category),
            _InfoTile('Manufacturer', medicine.manufacturer),
          ],
        ),
      ],
    );
  }
}

class _BatchSection extends StatelessWidget {
  const _BatchSection({required this.medicine, required this.daysToExpiry});

  final Medicine medicine;
  final int daysToExpiry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _InfoCard(
          title: 'Batch Details',
          children: [
            _InfoTile('Batch', medicine.batchNo),
            _InfoTile('Mfg Date', medicine.mfgDate),
            _InfoTile('Expiry', medicine.expiryDate),
            const SizedBox(height: 12),
            StatusBadge(
              label: daysToExpiry > 0
                  ? '$daysToExpiry days remaining'
                  : 'Expired',
              color: daysToExpiry <= 0
                  ? Colors.red
                  : daysToExpiry < 60
                      ? Colors.orange
                      : Colors.green,
            ),
          ],
        ),
      ],
    );
  }
}

class _PricingSection extends StatelessWidget {
  const _PricingSection({required this.medicine});

  final Medicine medicine;

  @override
  Widget build(BuildContext context) {
    final margin = medicine.margin;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _InfoCard(
          title: 'Prices',
          children: [
            _InfoTile('Purchase', 'Rs ${medicine.purchasePrice.toStringAsFixed(0)}'),
            _InfoTile('Selling', 'Rs ${medicine.sellingPrice.toStringAsFixed(0)}'),
            _InfoTile('Discount', '${medicine.discount.toStringAsFixed(0)}%'),
            const SizedBox(height: 12),
            Center(
              child: Column(
                children: [
                  SizedBox(
                    height: 120,
                    width: 120,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: (margin / 100).clamp(0.0, 1.0),
                          strokeWidth: 8,
                        ),
                        Center(
                          child: Text('${margin.toStringAsFixed(1)}%'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Profit Margin'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StockSection extends StatelessWidget {
  const _StockSection({required this.medicine});

  final Medicine medicine;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _InfoCard(
          title: 'Stock Overview',
          children: [
            _InfoTile('Quantity', '${medicine.quantity} ${medicine.unit}'),
            _InfoTile('Minimum level', medicine.minStockLevel.toString()),
            _InfoTile('Status', medicine.isLowStock ? 'Low' : 'Healthy'),
          ],
        ),
      ],
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.medicine});

  final Medicine medicine;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _InfoCard(
          title: 'Storage & Description',
          children: [
            Text(medicine.storage),
            const SizedBox(height: 12),
            Text(medicine.description),
          ],
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
