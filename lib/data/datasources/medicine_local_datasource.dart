import 'package:hive/hive.dart';

import '../../core/database/hive_service.dart';
import '../../core/utils/uuid_generator.dart';
import '../models/medicine_model.dart';
import '../models/sync_queue_model.dart';

/// Local datasource for Medicine operations using Hive
/// 
/// Handles all local database operations for medicines including:
/// - CRUD operations
/// - Stock management
/// - Expiry tracking
/// - Search and filtering
/// - Sync queue management
class MedicineLocalDatasource {
  /// Get the medicines box
  Box<MedicineModel> get _box => HiveService.medicinesBox;

  /// Get the sync queue box
  Box<SyncQueueModel> get _syncQueueBox => HiveService.syncQueueBox;

  /// Get all medicines
  Future<List<MedicineModel>> getAllMedicines() async {
    final medicines = _box.values.toList();
    // Sort by name
    medicines.sort((a, b) => a.name.compareTo(b.name));
    return medicines;
  }

  /// Get medicine by ID
  Future<MedicineModel?> getMedicineById(String id) async {
    return _box.get(id);
  }

  /// Add a new medicine
  Future<void> addMedicine(MedicineModel medicine) async {
    await _box.put(medicine.id, medicine);
    await _addToSyncQueue(medicine.id, 'create', medicine.toJson());
  }

  /// Update an existing medicine
  Future<void> updateMedicine(MedicineModel medicine) async {
    medicine.updatedAt = DateTime.now();
    medicine.isSynced = false;
    await _box.put(medicine.id, medicine);
    await _addToSyncQueue(medicine.id, 'update', medicine.toJson());
  }

  /// Delete a medicine
  Future<void> deleteMedicine(String id) async {
    await _box.delete(id);
    await _addToSyncQueue(id, 'delete', null);
  }

  /// Get medicines that haven't been synced
  Future<List<MedicineModel>> getUnsyncedMedicines() async {
    return _box.values.where((m) => !m.isSynced).toList();
  }

  /// Mark medicine as synced
  Future<void> markAsSynced(String id, {String? firebaseId}) async {
    final medicine = _box.get(id);
    if (medicine != null) {
      medicine.isSynced = true;
      if (firebaseId != null) {
        medicine.firebaseId = firebaseId;
      }
      await _box.put(id, medicine);
    }
  }

  /// Search medicines by name, generic name, or manufacturer
  Future<List<MedicineModel>> searchMedicines(String query) async {
    if (query.isEmpty) return getAllMedicines();

    final lowerQuery = query.toLowerCase();
    return _box.values.where((medicine) {
      return medicine.name.toLowerCase().contains(lowerQuery) ||
          medicine.genericName.toLowerCase().contains(lowerQuery) ||
          medicine.manufacturer.toLowerCase().contains(lowerQuery) ||
          medicine.batchNo.toLowerCase().contains(lowerQuery) ||
          medicine.category.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Get medicines by category
  Future<List<MedicineModel>> getMedicinesByCategory(String category) async {
    return _box.values.where((m) => m.category == category).toList();
  }

  /// Get medicines with low stock
  Future<List<MedicineModel>> getLowStockMedicines() async {
    return _box.values.where((m) => m.isLowStock).toList();
  }

  /// Get out of stock medicines
  Future<List<MedicineModel>> getOutOfStockMedicines() async {
    return _box.values.where((m) => m.quantity <= 0).toList();
  }

  /// Get expired medicines
  Future<List<MedicineModel>> getExpiredMedicines() async {
    return _box.values.where((m) => m.isExpired).toList();
  }

  /// Get medicines expiring soon (within given days)
  Future<List<MedicineModel>> getExpiringSoonMedicines({int days = 30}) async {
    final now = DateTime.now();
    final threshold = now.add(Duration(days: days));
    return _box.values.where((m) {
      return m.expiryDate.isAfter(now) && m.expiryDate.isBefore(threshold);
    }).toList();
  }

  /// Get medicines expiring within a date range
  Future<List<MedicineModel>> getMedicinesExpiringBetween(
    DateTime start,
    DateTime end,
  ) async {
    return _box.values.where((m) {
      return m.expiryDate.isAfter(start) && m.expiryDate.isBefore(end);
    }).toList();
  }

  /// Update medicine stock
  Future<void> updateStock(String id, int quantity, {bool add = true}) async {
    final medicine = _box.get(id);
    if (medicine != null) {
      if (add) {
        medicine.quantity += quantity;
      } else {
        medicine.quantity = (medicine.quantity - quantity).clamp(0, double.infinity).toInt();
      }
      medicine.updatedAt = DateTime.now();
      medicine.isSynced = false;
      await _box.put(id, medicine);
      await _addToSyncQueue(id, 'update', medicine.toJson());
    }
  }

  /// Deduct stock (for sales)
  Future<bool> deductStock(String id, int quantity) async {
    final medicine = _box.get(id);
    if (medicine != null && medicine.quantity >= quantity) {
      medicine.quantity -= quantity;
      medicine.updatedAt = DateTime.now();
      medicine.isSynced = false;
      await _box.put(id, medicine);
      await _addToSyncQueue(id, 'update', medicine.toJson());
      return true;
    }
    return false;
  }

  /// Get all categories
  List<String> getAllCategories() {
    return _box.values.map((m) => m.category).toSet().toList()..sort();
  }

  /// Get all manufacturers
  List<String> getAllManufacturers() {
    return _box.values.map((m) => m.manufacturer).toSet().toList()..sort();
  }

  /// Get total number of medicines
  int get totalCount => _box.length;

  /// Get total stock value (at purchase price)
  double get totalStockValueAtCost {
    return _box.values.fold(0.0, (sum, m) => sum + (m.quantity * m.purchasePrice));
  }

  /// Get total stock value (at selling price)
  double get totalStockValueAtSale {
    return _box.values.fold(0.0, (sum, m) => sum + (m.quantity * m.sellingPrice));
  }

  /// Get potential profit
  double get potentialProfit => totalStockValueAtSale - totalStockValueAtCost;

  /// Get count of low stock medicines
  int get lowStockCount {
    return _box.values.where((m) => m.isLowStock).length;
  }

  /// Get count of expired medicines
  int get expiredCount {
    return _box.values.where((m) => m.isExpired).length;
  }

  /// Get count of medicines expiring soon
  int get expiringSoonCount {
    final now = DateTime.now();
    final threshold = now.add(const Duration(days: 30));
    return _box.values.where((m) {
      return m.expiryDate.isAfter(now) && m.expiryDate.isBefore(threshold);
    }).length;
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
      entityType: 'medicine',
      action: action,
      timestamp: DateTime.now(),
      data: data,
    );
    await _syncQueueBox.put('medicine_$entityId', queueItem);
  }

  /// Remove from sync queue after successful sync
  Future<void> removeFromSyncQueue(String entityId) async {
    await _syncQueueBox.delete('medicine_$entityId');
  }

  /// Clear all medicines (use with caution)
  Future<void> clearAll() async {
    await _box.clear();
  }

  /// Batch insert medicines (for initial sync)
  Future<void> batchInsert(List<MedicineModel> medicines) async {
    final Map<String, MedicineModel> entries = {
      for (var medicine in medicines) medicine.id: medicine
    };
    await _box.putAll(entries);
  }
}
