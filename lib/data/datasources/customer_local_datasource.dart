import 'package:hive/hive.dart';

import '../../core/database/hive_service.dart';
import '../../core/database/hive_boxes.dart';
import '../../core/utils/uuid_generator.dart';
import '../models/customer_model.dart';
import '../models/sync_queue_model.dart';

/// Local datasource for Customer operations using Hive
/// 
/// Handles all local database operations for customers including:
/// - CRUD operations
/// - Search and filtering
/// - Sync queue management
class CustomerLocalDatasource {
  /// Get the customers box
  Box<CustomerModel> get _box => HiveService.customersBox;

  /// Get the sync queue box
  Box<SyncQueueModel> get _syncQueueBox => HiveService.syncQueueBox;

  /// Get all customers
  Future<List<CustomerModel>> getAllCustomers() async {
    final customers = _box.values.toList();
    // Sort by name
    customers.sort((a, b) => a.name.compareTo(b.name));
    return customers;
  }

  /// Get customer by ID
  Future<CustomerModel?> getCustomerById(String id) async {
    return _box.get(id);
  }

  /// Add a new customer
  Future<void> addCustomer(CustomerModel customer) async {
    await _box.put(customer.id, customer);
    await _addToSyncQueue(customer.id, 'create', customer.toJson());
  }

  /// Update an existing customer
  Future<void> updateCustomer(CustomerModel customer) async {
    customer.updatedAt = DateTime.now();
    customer.isSynced = false;
    await _box.put(customer.id, customer);
    await _addToSyncQueue(customer.id, 'update', customer.toJson());
  }

  /// Delete a customer
  Future<void> deleteCustomer(String id) async {
    await _box.delete(id);
    await _addToSyncQueue(id, 'delete', null);
  }

  /// Get customers that haven't been synced
  Future<List<CustomerModel>> getUnsyncedCustomers() async {
    return _box.values.where((c) => !c.isSynced).toList();
  }

  /// Mark customer as synced
  Future<void> markAsSynced(String id, {String? firebaseId}) async {
    final customer = _box.get(id);
    if (customer != null) {
      customer.isSynced = true;
      if (firebaseId != null) {
        customer.firebaseId = firebaseId;
      }
      await _box.put(id, customer);
    }
  }

  /// Search customers by name, phone, or shop name
  Future<List<CustomerModel>> searchCustomers(String query) async {
    if (query.isEmpty) return getAllCustomers();

    final lowerQuery = query.toLowerCase();
    return _box.values.where((customer) {
      return customer.name.toLowerCase().contains(lowerQuery) ||
          customer.phone.contains(query) ||
          (customer.shopName?.toLowerCase().contains(lowerQuery) ?? false) ||
          (customer.address?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  /// Get customers by type (Retail, Wholesale, VIP)
  Future<List<CustomerModel>> getCustomersByType(String type) async {
    return _box.values.where((c) => c.customerType == type).toList();
  }

  /// Get customers with positive balance (credit)
  Future<List<CustomerModel>> getCustomersWithCredit() async {
    return _box.values.where((c) => c.balance > 0).toList();
  }

  /// Get customers with negative balance (debt)
  Future<List<CustomerModel>> getCustomersWithDebt() async {
    return _box.values.where((c) => c.balance < 0).toList();
  }

  /// Update customer balance
  Future<void> updateBalance(String id, double amount) async {
    final customer = _box.get(id);
    if (customer != null) {
      customer.balance += amount;
      customer.updatedAt = DateTime.now();
      customer.isSynced = false;
      await _box.put(id, customer);
      await _addToSyncQueue(id, 'update', customer.toJson());
    }
  }

  /// Get total number of customers
  int get totalCount => _box.length;

  /// Get total credit amount
  double get totalCredit {
    return _box.values
        .where((c) => c.balance > 0)
        .fold(0.0, (sum, c) => sum + c.balance);
  }

  /// Get total debt amount
  double get totalDebt {
    return _box.values
        .where((c) => c.balance < 0)
        .fold(0.0, (sum, c) => sum + c.balance.abs());
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
      entityType: 'customer',
      action: action,
      timestamp: DateTime.now(),
      data: data,
    );
    await _syncQueueBox.put('customer_$entityId', queueItem);
  }

  /// Remove from sync queue after successful sync
  Future<void> removeFromSyncQueue(String entityId) async {
    await _syncQueueBox.delete('customer_$entityId');
  }

  /// Clear all customers (use with caution)
  Future<void> clearAll() async {
    await _box.clear();
  }

  /// Batch insert customers (for initial sync)
  Future<void> batchInsert(List<CustomerModel> customers) async {
    final Map<String, CustomerModel> entries = {
      for (var customer in customers) customer.id: customer
    };
    await _box.putAll(entries);
  }
}
