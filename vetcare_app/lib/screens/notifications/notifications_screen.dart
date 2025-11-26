import 'package:flutter/material.dart';

import '../../data/mock_data.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<NotificationItem> items = List.from(mockNotifications);

  void _dismiss(String id) {
    setState(() => items.removeWhere((element) => element.id == id));
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
              onPressed: () => setState(() => items.clear()),
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
        body: TabBarView(
          children: [
            _NotificationList(items: items, onDismissed: _dismiss),
            _NotificationList(
              items: items.where((e) => e.isUnread).toList(),
              onDismissed: _dismiss,
            ),
            _NotificationList(
              items: items.where((e) => e.category == 'Alerts').toList(),
              onDismissed: _dismiss,
            ),
          ],
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
                backgroundColor: Colors.primaries[index % Colors.primaries.length].withOpacity(0.2),
                child: Icon(Icons.notifications, color: Colors.primaries[index % Colors.primaries.length]),
              ),
              title: Text(notification.title),
              subtitle: Text(notification.subtitle),
              trailing: Text(notification.timestamp),
            ),
          ),
        );
      },
    );
  }
}
