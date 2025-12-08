import 'package:flutter/material.dart';

import 'status_badge.dart';

/// Alert message model for real data from providers
class AlertMessage {
  AlertMessage({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.badgeColor,
    this.alertType = AlertType.warning,
  });

  final String id;
  final String title;
  final String subtitle;
  final Color badgeColor;
  final AlertType alertType;
}

enum AlertType {
  warning,
  error,
  info,
  success,
}

class AlertCard extends StatelessWidget {
  const AlertCard({super.key, required this.alert, this.onDismissed});

  final AlertMessage alert;
  final DismissDirectionCallback? onDismissed;

  IconData _getAlertIcon() {
    switch (alert.alertType) {
      case AlertType.error:
        return Icons.error_outline;
      case AlertType.info:
        return Icons.info_outline;
      case AlertType.success:
        return Icons.check_circle_outline;
      case AlertType.warning:
      default:
        return Icons.warning_amber_outlined;
    }
  }

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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: alert.badgeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getAlertIcon(),
                  color: alert.badgeColor,
                  size: 24,
                ),
              ),
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
              StatusBadge(label: 'Alert', color: alert.badgeColor),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper class to generate real alerts from providers
class AlertGenerator {
  /// Generate alerts from medicine provider data
  static List<AlertMessage> generateMedicineAlerts({
    required List<dynamic> expiringSoon,
    required List<dynamic> lowStock,
    required List<dynamic> expired,
  }) {
    final alerts = <AlertMessage>[];

    // Expired medicines (highest priority)
    if (expired.isNotEmpty) {
      final count = expired.length;
      final names = expired.take(3).map((m) => m.name).join(', ');
      alerts.add(AlertMessage(
        id: 'expired_medicines',
        title: '$count medicine${count > 1 ? 's' : ''} expired',
        subtitle: count <= 3 ? names : '$names and ${count - 3} more',
        badgeColor: Colors.red,
        alertType: AlertType.error,
      ));
    }

    // Expiring soon medicines
    if (expiringSoon.isNotEmpty) {
      final count = expiringSoon.length;
      final nearestExpiry = expiringSoon.first;
      alerts.add(AlertMessage(
        id: 'expiring_medicines',
        title: '$count medicine${count > 1 ? 's' : ''} expiring soon',
        subtitle: '${nearestExpiry.name} expires in ${nearestExpiry.daysUntilExpiry} days',
        badgeColor: Colors.orange,
        alertType: AlertType.warning,
      ));
    }

    // Low stock medicines
    if (lowStock.isNotEmpty) {
      final count = lowStock.length;
      final firstLow = lowStock.first;
      alerts.add(AlertMessage(
        id: 'low_stock_medicines',
        title: '$count medicine${count > 1 ? 's' : ''} low on stock',
        subtitle: '${firstLow.name}: ${firstLow.quantity} ${firstLow.unit} remaining',
        badgeColor: Colors.amber,
        alertType: AlertType.warning,
      ));
    }

    return alerts;
  }

  /// Generate alerts from feed product provider data
  static List<AlertMessage> generateFeedAlerts({
    required List<dynamic> lowStock,
    required List<dynamic> outOfStock,
  }) {
    final alerts = <AlertMessage>[];

    // Out of stock products
    if (outOfStock.isNotEmpty) {
      final count = outOfStock.length;
      final names = outOfStock.take(3).map((p) => p.name).join(', ');
      alerts.add(AlertMessage(
        id: 'out_of_stock_products',
        title: '$count product${count > 1 ? 's' : ''} out of stock',
        subtitle: count <= 3 ? names : '$names and ${count - 3} more',
        badgeColor: Colors.red,
        alertType: AlertType.error,
      ));
    }

    // Low stock products
    if (lowStock.isNotEmpty) {
      final count = lowStock.length;
      final firstLow = lowStock.first;
      alerts.add(AlertMessage(
        id: 'low_stock_products',
        title: '$count product${count > 1 ? 's' : ''} low on stock',
        subtitle: '${firstLow.name}: ${firstLow.stock} ${firstLow.unit} remaining',
        badgeColor: Colors.amber,
        alertType: AlertType.warning,
      ));
    }

    return alerts;
  }

  /// Generate alerts from order provider data
  static List<AlertMessage> generateOrderAlerts({
    required List<dynamic> pendingOrders,
    required double totalPending,
  }) {
    final alerts = <AlertMessage>[];

    if (pendingOrders.isNotEmpty) {
      final count = pendingOrders.length;
      alerts.add(AlertMessage(
        id: 'pending_orders',
        title: '$count pending order${count > 1 ? 's' : ''}',
        subtitle: 'Total pending amount: Rs ${totalPending.toStringAsFixed(0)}',
        badgeColor: Colors.blue,
        alertType: AlertType.info,
      ));
    }

    return alerts;
  }
}
