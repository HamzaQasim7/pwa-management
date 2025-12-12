import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Custom quantity input widget that supports decimal quantities
/// for partial purchases (e.g., 2.5 kg, 100ml from 1000ml bottle)
class CustomQuantityInput extends StatefulWidget {
  const CustomQuantityInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 999999.0,
    this.step = 0.1,
    this.unit = '',
    this.allowDecimals = true,
    this.label,
    this.hintText,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final double step;
  final String unit;
  final bool allowDecimals;
  final String? label;
  final String? hintText;

  @override
  State<CustomQuantityInput> createState() => _CustomQuantityInputState();
}

class _CustomQuantityInputState extends State<CustomQuantityInput> {
  late TextEditingController _controller;
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
    _controller = TextEditingController(text: _formatValue(widget.value));
  }

  @override
  void didUpdateWidget(CustomQuantityInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _currentValue = widget.value;
      _controller.text = _formatValue(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatValue(double value) {
    if (widget.allowDecimals) {
      // Remove trailing zeros
      return value.toStringAsFixed(2).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
    } else {
      return value.toInt().toString();
    }
  }

  void _updateValue(double newValue) {
    final clamped = newValue.clamp(widget.min, widget.max);
    if (clamped != _currentValue) {
      setState(() {
        _currentValue = clamped;
        _controller.text = _formatValue(clamped);
      });
      widget.onChanged(clamped);
    }
  }

  void _onTextChanged(String text) {
    final parsed = widget.allowDecimals
        ? double.tryParse(text) ?? _currentValue
        : (int.tryParse(text)?.toDouble() ?? _currentValue);
    _updateValue(parsed);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
        ],
        IntrinsicWidth(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Decrease button
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: _currentValue > widget.min
                    ? () => _updateValue(_currentValue - widget.step)
                    : null,
                tooltip: 'Decrease',
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
              ),
              // Text input
              SizedBox(
                width: 100,
                child: TextFormField(
                  controller: _controller,
                  keyboardType: TextInputType.numberWithOptions(
                    decimal: widget.allowDecimals,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      widget.allowDecimals
                          ? RegExp(r'^\d+\.?\d{0,2}')
                          : RegExp(r'^\d+'),
                    ),
                  ],
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: widget.hintText ?? '0',
                    suffixText: widget.unit.isNotEmpty ? widget.unit : null,
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                    isDense: true,
                  ),
                  onChanged: _onTextChanged,
                  onEditingComplete: () {
                    // Ensure value is within bounds
                    _updateValue(_currentValue);
                  },
                ),
              ),
              // Increase button
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: _currentValue < widget.max
                    ? () => _updateValue(_currentValue + widget.step)
                    : null,
                tooltip: 'Increase',
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

