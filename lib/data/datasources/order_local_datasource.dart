import 'package:hive/hive.dart';

import '../../core/database/hive_service.dart';
import '../../core/utils/uuid_generator.dart';
import '../models/order_model.dart';
import '../models/sync_queue_model.dart';

/// Local datasource for Order operations using Hive
/// 
/// Handles all local database operations for orders including:
/// - CRUD operations
/// - Payment status tracking
/// - Search and filtering
/// - Sync queue management
class OrderLocalDatasource {
  /// Get the orders box
  Box<OrderModel> get _box => HiveService.ordersBox;

  /// Get the sync queue box
  Box<SyncQueueModel> get _syncQueueBox => HiveService.syncQueueBox;

  /// Get all orders
  Future<List<OrderModel>> getAllOrders() async {
    final orders = _box.values.toList();
    // Sort by date (most recent first)
    orders.sort((a, b) => b.date.compareTo(a.date));
    return orders;
  }

  /// Get order by ID
  Future<OrderModel?> getOrderById(String id) async {
    return _box.get(id);
  }

  /// Get order by order number
  Future<OrderModel?> getOrderByNumber(String orderNumber) async {
    try {
      return _box.values.firstWhere((o) => o.orderNumber == orderNumber);
    } catch (e) {
      return null;
    }
  }

  /// Add a new order
  Future<void> addOrder(OrderModel order) async {
    await _box.put(order.id, order);
    await _addToSyncQueue(order.id, 'create', order.toJson());
  }

  /// Update an existing order
  Future<void> updateOrder(OrderModel order) async {
    order.updatedAt = DateTime.now();
    order.isSynced = false;
    await _box.put(order.id, order);
    await _addToSyncQueue(order.id, 'update', order.toJson());
  }

  /// Delete an order
  Future<void> deleteOrder(String id) async {
    await _box.delete(id);
    await _addToSyncQueue(id, 'delete', null);
  }

  /// Get orders that haven't been synced
  Future<List<OrderModel>> getUnsyncedOrders() async {
    return _box.values.where((o) => !o.isSynced).toList();
  }

  /// Mark order as synced
  Future<void> markAsSynced(String id, {String? firebaseId}) async {
    final order = _box.get(id);
    if (order != null) {
      order.isSynced = true;
      if (firebaseId != null) {
        order.firebaseId = firebaseId;
      }
      await _box.put(id, order);
    }
  }

  /// Get orders by customer
  Future<List<OrderModel>> getOrdersByCustomer(String customerId) async {
    final orders = _box.values.where((o) => o.customerId == customerId).toList();
    orders.sort((a, b) => b.date.compareTo(a.date));
    return orders;
  }

  /// Get orders by type (feed or medicine)
  Future<List<OrderModel>> getOrdersByType(String orderType) async {
    final orders = _box.values.where((o) => o.orderType == orderType).toList();
    orders.sort((a, b) => b.date.compareTo(a.date));
    return orders;
  }

  /// Get orders by payment status
  Future<List<OrderModel>> getOrdersByPaymentStatus(String status) async {
    final orders = _box.values.where((o) => o.paymentStatus == status).toList();
    orders.sort((a, b) => b.date.compareTo(a.date));
    return orders;
  }

  /// Get orders by date range
  Future<List<OrderModel>> getOrdersByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final orders = _box.values.where((o) {
      return o.date.isAfter(start.subtract(const Duration(days: 1))) &&
          o.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
    orders.sort((a, b) => b.date.compareTo(a.date));
    return orders;
  }

  /// Get today's orders
  Future<List<OrderModel>> getTodaysOrders() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return getOrdersByDateRange(startOfDay, endOfDay);
  }

  /// Get pending orders
  Future<List<OrderModel>> getPendingOrders() async {
    return getOrdersByPaymentStatus('Pending');
  }

  /// Update payment status
  Future<void> updatePaymentStatus(
    String id,
    String status, {
    double? paidAmount,
  }) async {
    final order = _box.get(id);
    if (order != null) {
      order.paymentStatus = status;
      if (paidAmount != null) {
        order.paidAmount = paidAmount;
      }
      order.updatedAt = DateTime.now();
      order.isSynced = false;
      await _box.put(id, order);
      await _addToSyncQueue(id, 'update', order.toJson());
    }
  }

  /// Record payment
  Future<void> recordPayment(String id, double amount) async {
    final order = _box.get(id);
    if (order != null) {
      final newPaidAmount = (order.paidAmount ?? 0) + amount;
      order.paidAmount = newPaidAmount;

      if (newPaidAmount >= order.total) {
        order.paymentStatus = 'Paid';
      } else if (newPaidAmount > 0) {
        order.paymentStatus = 'Partially Paid';
      }

      order.updatedAt = DateTime.now();
      order.isSynced = false;
      await _box.put(id, order);
      await _addToSyncQueue(id, 'update', order.toJson());
    }
  }

  /// Search orders by order number or customer name
  Future<List<OrderModel>> searchOrders(String query) async {
    if (query.isEmpty) return getAllOrders();

    final lowerQuery = query.toLowerCase();
    final orders = _box.values.where((order) {
      return order.orderNumber.toLowerCase().contains(lowerQuery) ||
          (order.customerName?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
    orders.sort((a, b) => b.date.compareTo(a.date));
    return orders;
  }

  /// Generate next order number
  String generateOrderNumber(String type) {
    final prefix = type == 'feed' ? 'FD' : 'MD';
    return UuidGenerator.generateOrderNumber(prefix);
  }

  /// Get total number of orders
  int get totalCount => _box.length;

  /// Get total revenue
  double get totalRevenue {
    return _box.values.fold(0.0, (sum, o) => sum + o.total);
  }

  /// Get total pending amount
  double get totalPending {
    return _box.values
        .where((o) => o.paymentStatus != 'Paid')
        .fold(0.0, (sum, o) => sum + o.remainingAmount);
  }

  /// Get today's revenue
  double get todaysRevenue {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    return _box.values
        .where((o) => o.date.isAfter(startOfDay))
        .fold(0.0, (sum, o) => sum + o.total);
  }

  /// Add entry to sync queue
  Future<void> _addToSyncQueue(
    String entityId,
    String action,
    Map<String, dynamic>? data,
  ) async {
    final queueItem = SyncQueueModel(
      id: UuidGenerator.generate(),
      entityId: entityId,
      entityType: 'order',
      action: action,
      timestamp: DateTime.now(),
      data: data,
    );
    await _syncQueueBox.put('order_$entityId', queueItem);
  }

  /// Remove from sync queue after successful sync
  Future<void> removeFromSyncQueue(String entityId) async {
    await _syncQueueBox.delete('order_$entityId');
  }

  /// Clear all orders (use with caution)
  Future<void> clearAll() async {
    await _box.clear();
  }

  /// Batch insert orders (for initial sync)
  Future<void> batchInsert(List<OrderModel> orders) async {
    final Map<String, OrderModel> entries = {
      for (var order in orders) order.id: order
    };
    await _box.putAll(entries);
  }
}
