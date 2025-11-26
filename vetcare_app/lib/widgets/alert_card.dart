import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import 'status_badge.dart';

class AlertCard extends StatelessWidget {
  const AlertCard({super.key, required this.alert, this.onDismissed});

  final AlertMessage alert;
  final DismissDirectionCallback? onDismissed;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(alert.id),
      onDismissed: onDismissed,
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: Material(
        borderRadius: BorderRadius.circular(24),
        color: Theme.of(context).cardColor,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              StatusBadge(label: 'Alert', color: alert.badgeColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(alert.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            )),
                    const SizedBox(height: 4),
                    Text(alert.subtitle,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
