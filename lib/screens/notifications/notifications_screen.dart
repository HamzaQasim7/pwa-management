import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../presentation/providers/medicine_provider.dart';
import '../../presentation/providers/order_provider.dart';

/// Notification item model
class NotificationItem {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final String timestamp;
  final bool isUnread;

  NotificationItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.timestamp,
    this.isUnread = true,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationItem> _items = [];
  final Set<String> _dismissedIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateNotifications();
    });
  }

  void _generateNotifications() {
    final medicineProvider = context.read<MedicineProvider>();
    final orderProvider = context.read<OrderProvider>();
    
    final List<NotificationItem> notifications = [];
    
    // Generate notifications from medicines
    final expiringSoon = medicineProvider.expiringSoonMedicines;
    for (int i = 0; i < expiringSoon.take(3).length; i++) {
      final medicine = expiringSoon.elementAt(i);
      notifications.add(NotificationItem(
        id: 'exp_${medicine.id}',
        title: 'Medicine Expiring Soon',
        subtitle: '${medicine.name} will expire in ${medicine.daysUntilExpiry} days',
        category: 'Alerts',
        timestamp: 'Now',
        isUnread: true,
      ));
    }

    // Generate notifications from low stock
    final lowStock = medicineProvider.lowStockMedicines;
    for (int i = 0; i < lowStock.take(3).length; i++) {
      final medicine = lowStock.elementAt(i);
      notifications.add(NotificationItem(
        id: 'low_${medicine.id}',
        title: 'Low Stock Alert',
        subtitle: '${medicine.name} has only ${medicine.quantity} ${medicine.unit} left',
        category: 'Alerts',
        timestamp: '1h ago',
        isUnread: true,
      ));
    }

    // Generate notifications from pending orders
    final pendingOrders = orderProvider.pendingOrders;
    for (int i = 0; i < pendingOrders.take(2).length; i++) {
      final order = pendingOrders.elementAt(i);
      notifications.add(NotificationItem(
        id: 'order_${order.id}',
        title: 'Order Pending',
        subtitle: 'Order ${order.orderNumber} is waiting for delivery',
        category: 'Orders',
        timestamp: '2h ago',
        isUnread: i == 0,
      ));
    }

    // Add some general notifications
    if (medicineProvider.totalCount > 0) {
      notifications.add(NotificationItem(
        id: 'summary_1',
        title: 'Daily Summary',
        subtitle: 'You have ${medicineProvider.totalCount} medicines in inventory',
        category: 'Info',
        timestamp: '6h ago',
        isUnread: false,
      ));
    }

    if (orderProvider.allOrders.isNotEmpty) {
      notifications.add(NotificationItem(
        id: 'summary_2',
        title: 'Order Summary',
        subtitle: '${orderProvider.allOrders.length} total orders processed',
        category: 'Info',
        timestamp: '1d ago',
        isUnread: false,
      ));
    }

    setState(() {
      _items = notifications.where((n) => !_dismissedIds.contains(n.id)).toList();
    });
  }

  void _dismiss(String id) {
    setState(() {
      _dismissedIds.add(id);
      _items.removeWhere((element) => element.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
          actions: [
            TextButton(
              onPressed: () => setState(() {
                for (final item in _items) {
                  _dismissedIds.add(item.id);
                }
                _items.clear();
              }),
              child: const Text('Clear All'),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Unread'),
              Tab(text: 'Alerts'),
            ],
          ),
        ),
        body: Consumer2<MedicineProvider, OrderProvider>(
          builder: (context, medicineProvider, orderProvider, child) {
            if (medicineProvider.isLoading || orderProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return TabBarView(
              children: [
                _NotificationList(items: _items, onDismissed: _dismiss),
                _NotificationList(
                  items: _items.where((e) => e.isUnread).toList(),
                  onDismissed: _dismiss,
                ),
                _NotificationList(
                  items: _items.where((e) => e.category == 'Alerts').toList(),
                  onDismissed: _dismiss,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _NotificationList extends StatelessWidget {
  const _NotificationList({required this.items, required this.onDismissed});

  final List<NotificationItem> items;
  final ValueChanged<String> onDismissed;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('No notifications'),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final notification = items[index];
        return Dismissible(
          key: ValueKey(notification.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => onDismissed(notification.id),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            color: Colors.red,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getCategoryColor(notification.category).withOpacity(0.2),
                child: Icon(
                  _getCategoryIcon(notification.category),
                  color: _getCategoryColor(notification.category),
                ),
              ),
              title: Text(
                notification.title,
                style: TextStyle(
                  fontWeight: notification.isUnread ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              subtitle: Text(notification.subtitle),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(notification.timestamp),
                  if (notification.isUnread)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Alerts':
        return Icons.warning_amber;
      case 'Orders':
        return Icons.shopping_bag;
      case 'Info':
        return Icons.info_outline;
      default:
        return Icons.notifications;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Alerts':
        return Colors.orange;
      case 'Orders':
        return Colors.blue;
      case 'Info':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
