import 'package:flutter/material.dart';

import '../models/order.dart';
import 'status_badge.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
    required this.customerName,
    this.onTap,
  });

  final Order order;
  final String customerName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      borderRadius: BorderRadius.circular(24),
      color: theme.cardColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(order.orderNumber,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      )),
                  const Spacer(),
                  StatusBadge(label: order.paymentStatus),
                ],
              ),
              const SizedBox(height: 6),
              Text(customerName, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 6),
              Text(order.date,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                  )),
              const SizedBox(height: 12),
              Row(
                children: [
                  _AmountColumn(label: 'Subtotal', value: order.subtotal),
                  const SizedBox(width: 16),
                  _AmountColumn(label: 'Discount', value: order.discount),
                  const Spacer(),
                  _AmountColumn(
                    label: 'Total',
                    value: order.total,
                    highlight: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AmountColumn extends StatelessWidget {
  const _AmountColumn({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final double value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
            )),
        const SizedBox(height: 4),
        Text(
          '₹${value.toStringAsFixed(0)}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
            color: highlight ? theme.colorScheme.primary : null,
          ),
        ),
      ],
    );
  }
}
