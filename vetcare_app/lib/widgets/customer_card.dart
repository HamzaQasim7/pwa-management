import 'package:flutter/material.dart';

import '../models/customer.dart';
import 'status_badge.dart';

class CustomerCard extends StatelessWidget {
  const CustomerCard({
    super.key,
    required this.customer,
    this.onTap,
    this.onCall,
  });

  final Customer customer;
  final VoidCallback? onTap;
  final VoidCallback? onCall;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = customer.name
        .split(' ')
        .map((part) => part.isNotEmpty ? part[0] : '')
        .take(2)
        .join()
        .toUpperCase();
    return Material(
      borderRadius: BorderRadius.circular(24),
      color: theme.cardColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                child: Text(initials),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(customer.shopName,
                        style: theme.textTheme.bodySmall),
                    const SizedBox(height: 6),
                    Text(customer.phone,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
                        )),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusBadge(
                    label:
                        '₹${customer.balance.toStringAsFixed(0).replaceAll('-','')}',
                    color: customer.balance >= 0
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
                    icon: customer.balance >= 0
                        ? Icons.pending_actions
                        : Icons.check_circle_outline,
                  ),
                  const SizedBox(height: 12),
                  IconButton(
                    onPressed: onCall,
                    icon: const Icon(Icons.call),
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
