import 'package:hive_flutter/hive_flutter.dart';

import '../../data/models/customer_model.dart';
import '../../data/models/feed_product_model.dart';
import '../../data/models/medicine_model.dart';
import '../../data/models/order_model.dart';
import '../../data/models/sale_model.dart';
import '../../data/models/sync_queue_model.dart';
import 'hive_boxes.dart';

/// Service for managing Hive local database
/// 
/// This service handles:
/// - Hive initialization
/// - Adapter registration
/// - Box management
/// - Database cleanup
class HiveService {
  static bool _isInitialized = false;

  /// Initialize Hive database with all adapters
  /// 
  /// This should be called once at app startup before accessing any boxes.
  static Future<void> init() async {
    if (_isInitialized) return;

    // Initialize Hive with Flutter
    await Hive.initFlutter();

    // Register all adapters
    _registerAdapters();

    // Open all boxes
    await _openBoxes();

    _isInitialized = true;
  }

  /// Register all Hive type adapters
  static void _registerAdapters() {
    // Customer adapter (typeId: 0)
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CustomerModelAdapter());
    }

    // FeedProduct adapter (typeId: 1)
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(FeedProductModelAdapter());
    }

    // Medicine adapter (typeId: 2)
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(MedicineModelAdapter());
    }

    // Order adapter (typeId: 3)
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(OrderModelAdapter());
    }

    // Sale adapter (typeId: 4)
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(SaleModelAdapter());
    }

    // SyncQueue adapter (typeId: 5)
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(SyncQueueModelAdapter());
    }

    // OrderItem adapter (typeId: 6)
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(OrderItemModelAdapter());
    }

    // SaleItem adapter (typeId: 7)
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(SaleItemModelAdapter());
    }
  }

  /// Open all Hive boxes
  static Future<void> _openBoxes() async {
    await Future.wait([
      Hive.openBox<CustomerModel>(HiveBoxes.customers),
      Hive.openBox<FeedProductModel>(HiveBoxes.feedProducts),
      Hive.openBox<MedicineModel>(HiveBoxes.medicines),
      Hive.openBox<OrderModel>(HiveBoxes.orders),
      Hive.openBox<SaleModel>(HiveBoxes.sales),
      Hive.openBox<SyncQueueModel>(HiveBoxes.syncQueue),
      Hive.openBox(HiveBoxes.settings),
      Hive.openBox(HiveBoxes.preferences),
      Hive.openBox(HiveBoxes.cache),
    ]);
  }

  /// Get typed box by name
  static Box<T> getBox<T>(String name) {
    if (!Hive.isBoxOpen(name)) {
      throw HiveError('Box $name is not open. Call HiveService.init() first.');
    }
    return Hive.box<T>(name);
  }

  /// Get customers box
  static Box<CustomerModel> get customersBox =>
      Hive.box<CustomerModel>(HiveBoxes.customers);

  /// Get feed products box
  static Box<FeedProductModel> get feedProductsBox =>
      Hive.box<FeedProductModel>(HiveBoxes.feedProducts);

  /// Get medicines box
  static Box<MedicineModel> get medicinesBox =>
      Hive.box<MedicineModel>(HiveBoxes.medicines);

  /// Get orders box
  static Box<OrderModel> get ordersBox =>
      Hive.box<OrderModel>(HiveBoxes.orders);

  /// Get sales box
  static Box<SaleModel> get salesBox => 
      Hive.box<SaleModel>(HiveBoxes.sales);

  /// Get sync queue box
  static Box<SyncQueueModel> get syncQueueBox =>
      Hive.box<SyncQueueModel>(HiveBoxes.syncQueue);

  /// Get settings box
  static Box get settingsBox => Hive.box(HiveBoxes.settings);

  /// Get preferences box
  static Box get preferencesBox => Hive.box(HiveBoxes.preferences);

  /// Get cache box
  static Box get cacheBox => Hive.box(HiveBoxes.cache);

  /// Clear all data from all boxes
  /// 
  /// Use with caution! This will delete all local data.
  static Future<void> clearAllData() async {
    await Future.wait([
      customersBox.clear(),
      feedProductsBox.clear(),
      medicinesBox.clear(),
      ordersBox.clear(),
      salesBox.clear(),
      syncQueueBox.clear(),
      cacheBox.clear(),
    ]);
  }

  /// Clear sync queue
  static Future<void> clearSyncQueue() async {
    await syncQueueBox.clear();
  }

  /// Clear cache data
  static Future<void> clearCache() async {
    await cacheBox.clear();
  }

  /// Get total count of unsynced items
  static int get unsyncedCount {
    return syncQueueBox.length;
  }

  /// Check if database is initialized
  static bool get isInitialized => _isInitialized;

  /// Close all boxes
  static Future<void> closeAll() async {
    await Hive.close();
    _isInitialized = false;
  }
}
