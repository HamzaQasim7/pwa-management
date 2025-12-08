import 'package:flutter/material.dart';

class InvoicePreviewScreen extends StatefulWidget {
  const InvoicePreviewScreen({super.key});

  @override
  State<InvoicePreviewScreen> createState() => _InvoicePreviewScreenState();
}

class _InvoicePreviewScreenState extends State<InvoicePreviewScreen> {
  bool thermalMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice'),
        actions: [
          TextButton(
            onPressed: () => setState(() => thermalMode = !thermalMode),
            child: Text(thermalMode ? 'A4 View' : 'Thermal'),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            width: thermalMode ? 320 : 420,
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(blurRadius: 20, color: Colors.black12, offset: Offset(0, 10)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('VetCare Distributors',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Bill #MD-2219 • 21 Nov 2025'),
                const Divider(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Billed To', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text('Green Pastures Dairy'),
                          Text('Nashik, Maharashtra'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Payment'),
                          SizedBox(height: 4),
                          Text('UPI - Completed'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                DataTable(
                  columns: const [
                    DataColumn(label: Text('Medicine')),
                    DataColumn(label: Text('Qty')),
                    DataColumn(label: Text('Rate')),
                    DataColumn(label: Text('Amount')),
                  ],
                  rows: const [
                    DataRow(cells: [
                      DataCell(Text('VetAmox 500')),
                      DataCell(Text('5')),
                      DataCell(Text('Rs 280')),
                      DataCell(Text('Rs 1,400')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('NeoVita Boost')),
                      DataCell(Text('3')),
                      DataCell(Text('Rs 160')),
                      DataCell(Text('Rs 480')),
                    ]),
                  ],
                ),
                const Divider(height: 32),
                Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: const [
                      _Amount(label: 'Subtotal', value: 'Rs 1,880'),
                      _Amount(label: 'Discount', value: 'Rs 90'),
                      _Amount(label: 'Total', value: 'Rs 1,790', highlight: true),
                    ],
                  ),
                ),
                const Spacer(),
                const Text('Thanks for trusting VetCare!'),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.print),
              onPressed: () => _toast(context, 'Print dialog'),
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => _toast(context, 'Share sheet'),
            ),
            const Spacer(),
            Switch(
              value: thermalMode,
              onChanged: (value) => setState(() => thermalMode = value),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Text('Thermal format'),
            ),
          ],
        ),
      ),
    );
  }

  void _toast(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}

class _Amount extends StatelessWidget {
  const _Amount({required this.label, required this.value, this.highlight = false});

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 12),
          Text(
            value,
            style: TextStyle(
              fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
              fontSize: highlight ? 20 : 16,
            ),
          ),
        ],
      ),
    );
  }
}
