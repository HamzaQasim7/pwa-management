import 'package:flutter/material.dart';

import '../models/order.dart';
import '../theme/app_theme.dart';
import '../utils/responsive_layout.dart';
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
      borderRadius: BorderRadius.circular(16),
      color: theme.cardColor,
      elevation: context.isDesktop ? 1 : 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: ResponsiveLayout.cardPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    order.orderNumber,
                    style: ResponsiveTextStyles.bodyLarge(context).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  StatusBadge(label: order.paymentStatus),
                ],
              ),
              SizedBox(height: ResponsiveLayout.spacing(context) * 0.33),
              Text(
                customerName,
                style: ResponsiveTextStyles.bodyMedium(context),
              ),
              SizedBox(height: ResponsiveLayout.spacing(context) * 0.33),
              Text(
                order.date,
                style: ResponsiveTextStyles.bodySmall(context).copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              SizedBox(height: ResponsiveLayout.spacing(context) * 0.75),
              Row(
                children: [
                  _AmountColumn(label: 'Subtotal', value: order.subtotal),
                  SizedBox(width: ResponsiveLayout.spacing(context)),
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
        Text(
          label,
          style: ResponsiveTextStyles.bodySmall(context).copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '₹${value.toStringAsFixed(0)}',
          style: ResponsiveTextStyles.bodyLarge(context).copyWith(
            fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
            color: highlight ? theme.colorScheme.primary : null,
          ),
        ),
      ],
    );
  }
}
