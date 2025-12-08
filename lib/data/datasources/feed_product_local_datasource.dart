import 'package:hive/hive.dart';

import '../../core/database/hive_service.dart';
import '../../core/utils/uuid_generator.dart';
import '../models/feed_product_model.dart';
import '../models/sync_queue_model.dart';

/// Local datasource for Feed Product operations using Hive
/// 
/// Handles all local database operations for feed products including:
/// - CRUD operations
/// - Stock management
/// - Search and filtering
/// - Sync queue management
class FeedProductLocalDatasource {
  /// Get the feed products box
  Box<FeedProductModel> get _box => HiveService.feedProductsBox;

  /// Get the sync queue box
  Box<SyncQueueModel> get _syncQueueBox => HiveService.syncQueueBox;

  /// Get all feed products
  Future<List<FeedProductModel>> getAllProducts() async {
    final products = _box.values.toList();
    // Sort by name
    products.sort((a, b) => a.name.compareTo(b.name));
    return products;
  }

  /// Get product by ID
  Future<FeedProductModel?> getProductById(String id) async {
    return _box.get(id);
  }

  /// Add a new product
  Future<void> addProduct(FeedProductModel product) async {
    await _box.put(product.id, product);
    await _addToSyncQueue(product.id, 'create', product.toJson());
  }

  /// Update an existing product
  Future<void> updateProduct(FeedProductModel product) async {
    product.updatedAt = DateTime.now();
    product.isSynced = false;
    await _box.put(product.id, product);
    await _addToSyncQueue(product.id, 'update', product.toJson());
  }

  /// Delete a product
  Future<void> deleteProduct(String id) async {
    await _box.delete(id);
    await _addToSyncQueue(id, 'delete', null);
  }

  /// Get products that haven't been synced
  Future<List<FeedProductModel>> getUnsyncedProducts() async {
    return _box.values.where((p) => !p.isSynced).toList();
  }

  /// Mark product as synced
  Future<void> markAsSynced(String id, {String? firebaseId}) async {
    final product = _box.get(id);
    if (product != null) {
      product.isSynced = true;
      if (firebaseId != null) {
        product.firebaseId = firebaseId;
      }
      await _box.put(id, product);
    }
  }

  /// Search products by name or category
  Future<List<FeedProductModel>> searchProducts(String query) async {
    if (query.isEmpty) return getAllProducts();

    final lowerQuery = query.toLowerCase();
    return _box.values.where((product) {
      return product.name.toLowerCase().contains(lowerQuery) ||
          product.category.toLowerCase().contains(lowerQuery) ||
          (product.supplier?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  /// Get products by category
  Future<List<FeedProductModel>> getProductsByCategory(String category) async {
    return _box.values.where((p) => p.category == category).toList();
  }

  /// Get products with low stock
  Future<List<FeedProductModel>> getLowStockProducts() async {
    return _box.values.where((p) => p.isLowStock).toList();
  }

  /// Get out of stock products
  Future<List<FeedProductModel>> getOutOfStockProducts() async {
    return _box.values.where((p) => p.stock <= 0).toList();
  }

  /// Update product stock
  Future<void> updateStock(String id, int quantity, {bool add = true}) async {
    final product = _box.get(id);
    if (product != null) {
      if (add) {
        product.stock += quantity;
      } else {
        product.stock = (product.stock - quantity).clamp(0, double.infinity).toInt();
      }
      product.updatedAt = DateTime.now();
      product.isSynced = false;
      await _box.put(id, product);
      await _addToSyncQueue(id, 'update', product.toJson());
    }
  }

  /// Deduct stock (for orders/sales)
  Future<bool> deductStock(String id, int quantity) async {
    final product = _box.get(id);
    if (product != null && product.stock >= quantity) {
      product.stock -= quantity;
      product.updatedAt = DateTime.now();
      product.isSynced = false;
      await _box.put(id, product);
      await _addToSyncQueue(id, 'update', product.toJson());
      return true;
    }
    return false;
  }

  /// Get all categories
  List<String> getAllCategories() {
    return _box.values.map((p) => p.category).toSet().toList()..sort();
  }

  /// Get total number of products
  int get totalCount => _box.length;

  /// Get total stock value
  double get totalStockValue {
    return _box.values.fold(0.0, (sum, p) => sum + (p.stock * p.rate));
  }

  /// Get count of low stock products
  int get lowStockCount {
    return _box.values.where((p) => p.isLowStock).length;
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
      entityType: 'feedProduct',
      action: action,
      timestamp: DateTime.now(),
      data: data,
    );
    await _syncQueueBox.put('feedProduct_$entityId', queueItem);
  }

  /// Remove from sync queue after successful sync
  Future<void> removeFromSyncQueue(String entityId) async {
    await _syncQueueBox.delete('feedProduct_$entityId');
  }

  /// Clear all products (use with caution)
  Future<void> clearAll() async {
    await _box.clear();
  }

  /// Batch insert products (for initial sync)
  Future<void> batchInsert(List<FeedProductModel> products) async {
    final Map<String, FeedProductModel> entries = {
      for (var product in products) product.id: product
    };
    await _box.putAll(entries);
  }
}
