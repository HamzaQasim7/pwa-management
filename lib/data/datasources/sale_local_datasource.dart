import 'package:hive/hive.dart';

import '../../core/database/hive_service.dart';
import '../../core/utils/uuid_generator.dart';
import '../models/sale_model.dart';
import '../models/sync_queue_model.dart';

/// Local datasource for Sale operations using Hive
/// 
/// Handles all local database operations for medicine sales including:
/// - CRUD operations
/// - Profit tracking
/// - Search and filtering
/// - Sync queue management
class SaleLocalDatasource {
  /// Get the sales box
  Box<SaleModel> get _box => HiveService.salesBox;

  /// Get the sync queue box
  Box<SyncQueueModel> get _syncQueueBox => HiveService.syncQueueBox;

  /// Get all sales
  Future<List<SaleModel>> getAllSales() async {
    final sales = _box.values.toList();
    // Sort by date (most recent first)
    sales.sort((a, b) => b.date.compareTo(a.date));
    return sales;
  }

  /// Get sale by ID
  Future<SaleModel?> getSaleById(String id) async {
    return _box.get(id);
  }

  /// Get sale by bill number
  Future<SaleModel?> getSaleByBillNumber(String billNumber) async {
    try {
      return _box.values.firstWhere((s) => s.billNumber == billNumber);
    } catch (e) {
      return null;
    }
  }

  /// Add a new sale
  Future<void> addSale(SaleModel sale) async {
    await _box.put(sale.id, sale);
    await _addToSyncQueue(sale.id, 'create', sale.toJson());
  }

  /// Update an existing sale
  Future<void> updateSale(SaleModel sale) async {
    sale.updatedAt = DateTime.now();
    sale.isSynced = false;
    await _box.put(sale.id, sale);
    await _addToSyncQueue(sale.id, 'update', sale.toJson());
  }

  /// Delete a sale
  Future<void> deleteSale(String id) async {
    await _box.delete(id);
    await _addToSyncQueue(id, 'delete', null);
  }

  /// Get sales that haven't been synced
  Future<List<SaleModel>> getUnsyncedSales() async {
    return _box.values.where((s) => !s.isSynced).toList();
  }

  /// Mark sale as synced
  Future<void> markAsSynced(String id, {String? firebaseId}) async {
    final sale = _box.get(id);
    if (sale != null) {
      sale.isSynced = true;
      if (firebaseId != null) {
        sale.firebaseId = firebaseId;
      }
      await _box.put(id, sale);
    }
  }

  /// Get sales by customer
  Future<List<SaleModel>> getSalesByCustomer(String customerId) async {
    final sales = _box.values.where((s) => s.customerId == customerId).toList();
    sales.sort((a, b) => b.date.compareTo(a.date));
    return sales;
  }

  /// Get sales by date range
  Future<List<SaleModel>> getSalesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final sales = _box.values.where((s) {
      return s.date.isAfter(start.subtract(const Duration(days: 1))) &&
          s.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
    sales.sort((a, b) => b.date.compareTo(a.date));
    return sales;
  }

  /// Get today's sales
  Future<List<SaleModel>> getTodaysSales() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return getSalesByDateRange(startOfDay, endOfDay);
  }

  /// Get sales by payment method
  Future<List<SaleModel>> getSalesByPaymentMethod(String method) async {
    final sales = _box.values.where((s) => s.paymentMethod == method).toList();
    sales.sort((a, b) => b.date.compareTo(a.date));
    return sales;
  }

  /// Search sales by bill number or customer name
  Future<List<SaleModel>> searchSales(String query) async {
    if (query.isEmpty) return getAllSales();

    final lowerQuery = query.toLowerCase();
    final sales = _box.values.where((sale) {
      return sale.billNumber.toLowerCase().contains(lowerQuery) ||
          (sale.customerName?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
    sales.sort((a, b) => b.date.compareTo(a.date));
    return sales;
  }

  /// Generate next bill number
  String generateBillNumber() {
    return UuidGenerator.generateBillNumber('MD');
  }

  /// Get total number of sales
  int get totalCount => _box.length;

  /// Get total revenue
  double get totalRevenue {
    return _box.values.fold(0.0, (sum, s) => sum + s.total);
  }

  /// Get total profit
  double get totalProfit {
    return _box.values.fold(0.0, (sum, s) => sum + s.profit);
  }

  /// Get total discount given
  double get totalDiscount {
    return _box.values.fold(0.0, (sum, s) => sum + s.discount);
  }

  /// Get today's revenue
  double get todaysRevenue {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    return _box.values
        .where((s) => s.date.isAfter(startOfDay))
        .fold(0.0, (sum, s) => sum + s.total);
  }

  /// Get today's profit
  double get todaysProfit {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    return _box.values
        .where((s) => s.date.isAfter(startOfDay))
        .fold(0.0, (sum, s) => sum + s.profit);
  }

  /// Get today's sales count
  int get todaysSalesCount {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    return _box.values.where((s) => s.date.isAfter(startOfDay)).length;
  }

  /// Get average profit margin
  double get averageProfitMargin {
    final totalRev = totalRevenue;
    if (totalRev == 0) return 0;
    return (totalProfit / totalRev) * 100;
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
      entityType: 'sale',
      action: action,
      timestamp: DateTime.now(),
      data: data,
    );
    await _syncQueueBox.put('sale_$entityId', queueItem);
  }

  /// Remove from sync queue after successful sync
  Future<void> removeFromSyncQueue(String entityId) async {
    await _syncQueueBox.delete('sale_$entityId');
  }

  /// Clear all sales (use with caution)
  Future<void> clearAll() async {
    await _box.clear();
  }

  /// Batch insert sales (for initial sync)
  Future<void> batchInsert(List<SaleModel> sales) async {
    final Map<String, SaleModel> entries = {
      for (var sale in sales) sale.id: sale
    };
    await _box.putAll(entries);
  }
}
