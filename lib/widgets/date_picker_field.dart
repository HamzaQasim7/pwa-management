import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerField extends StatefulWidget {
  const DatePickerField({
    super.key,
    required this.label,
    required this.initialDate,
    this.onChanged,
  });

  final String label;
  final DateTime initialDate;
  final ValueChanged<DateTime>? onChanged;

  @override
  State<DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  late DateTime selected;

  @override
  void initState() {
    super.initState();
    selected = widget.initialDate;
  }

  Future<void> _pick() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selected,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => selected = picked);
      widget.onChanged?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pick,
      child: InputDecorator(
        decoration: InputDecoration(labelText: widget.label),
        child: Row(
          children: [
            Text(DateFormat.yMMMd().format(selected)),
            const Spacer(),
            const Icon(Icons.calendar_today, size: 18),
          ],
        ),
      ),
    );
  }
}
