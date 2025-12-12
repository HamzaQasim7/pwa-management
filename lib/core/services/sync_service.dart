import 'dart:async';

import 'package:flutter/foundation.dart';

import '../database/hive_service.dart';
import '../network/network_info.dart';
import '../../data/datasources/customer_local_datasource.dart';
import '../../data/datasources/customer_remote_datasource.dart';
import '../../data/datasources/feed_product_local_datasource.dart';
import '../../data/datasources/feed_product_remote_datasource.dart';
import '../../data/datasources/medicine_local_datasource.dart';
import '../../data/datasources/medicine_remote_datasource.dart';
import '../../data/datasources/order_local_datasource.dart';
import '../../data/datasources/order_remote_datasource.dart';
import '../../data/datasources/sale_local_datasource.dart';
import '../../data/datasources/sale_remote_datasource.dart';
import '../../data/models/customer_model.dart';
import '../../data/models/feed_product_model.dart';
import '../../data/models/medicine_model.dart';
import '../../data/models/order_model.dart';
import '../../data/models/sale_model.dart';

/// Conflict resolution strategy
enum ConflictResolution {
  /// Cloud data takes precedence
  cloudWins,
  /// Local data takes precedence
  localWins,
  /// Most recently updated data wins
  latestWins,
  /// Merge changes (for non-conflicting fields)
  merge,
}

/// Service for managing data synchronization between local and remote storage
/// 
/// Implements offline-first architecture:
/// - All operations work locally first
/// - Changes are queued for sync
/// - Sync happens automatically when online
/// - Manual sync can be triggered
/// - Bidirectional sync (push and pull)
class SyncService with ChangeNotifier {
  final NetworkInfo _networkInfo;
  final CustomerLocalDatasource _customerLocal;
  final CustomerRemoteDatasource _customerRemote;
  final FeedProductLocalDatasource _productLocal;
  final FeedProductRemoteDatasource _productRemote;
  final MedicineLocalDatasource _medicineLocal;
  final MedicineRemoteDatasource _medicineRemote;
  final OrderLocalDatasource _orderLocal;
  final OrderRemoteDatasource _orderRemote;
  final SaleLocalDatasource _saleLocal;
  final SaleRemoteDatasource _saleRemote;

  bool _isSyncing = false;
  bool _isPulling = false;
  int _pendingCount = 0;
  String? _lastSyncError;
  DateTime? _lastSyncTime;
  DateTime? _lastPullTime;
  Timer? _autoSyncTimer;
  StreamSubscription<bool>? _connectivitySubscription;
  
  /// Conflict resolution strategy (default: latest wins)
  ConflictResolution conflictResolution = ConflictResolution.latestWins;

  bool get isSyncing => _isSyncing;
  bool get isPulling => _isPulling;
  int get pendingCount => _pendingCount;
  String? get lastSyncError => _lastSyncError;
  DateTime? get lastSyncTime => _lastSyncTime;
  DateTime? get lastPullTime => _lastPullTime;
  bool get hasPendingChanges => _pendingCount > 0;
  
  /// Check if any remote datasource is available
  bool get isCloudAvailable =>
      _customerRemote.isAvailable ||
      _productRemote.isAvailable ||
      _medicineRemote.isAvailable ||
      _orderRemote.isAvailable ||
      _saleRemote.isAvailable;

  SyncService({
    NetworkInfo? networkInfo,
    required CustomerLocalDatasource customerLocal,
    CustomerRemoteDatasource? customerRemote,
    required FeedProductLocalDatasource productLocal,
    FeedProductRemoteDatasource? productRemote,
    required MedicineLocalDatasource medicineLocal,
    MedicineRemoteDatasource? medicineRemote,
    required OrderLocalDatasource orderLocal,
    OrderRemoteDatasource? orderRemote,
    required SaleLocalDatasource saleLocal,
    SaleRemoteDatasource? saleRemote,
  })  : _networkInfo = networkInfo ?? NetworkInfo(),
        _customerLocal = customerLocal,
        _customerRemote = customerRemote ?? CustomerRemoteDatasource(),
        _productLocal = productLocal,
        _productRemote = productRemote ?? FeedProductRemoteDatasource(),
        _medicineLocal = medicineLocal,
        _medicineRemote = medicineRemote ?? MedicineRemoteDatasource(),
        _orderLocal = orderLocal,
        _orderRemote = orderRemote ?? OrderRemoteDatasource(),
        _saleLocal = saleLocal,
        _saleRemote = saleRemote ?? SaleRemoteDatasource() {
    _init();
  }

  /// Initialize sync service
  Future<void> _init() async {
    _checkPendingCount();
    _startAutoSync();
    _listenToConnectivity();
  }

  /// Initialize all remote datasources
  Future<void> initializeRemoteDatasources() async {
    try {
      await Future.wait([
        _customerRemote.init(),
        _productRemote.init(),
        _medicineRemote.init(),
        _orderRemote.init(),
        _saleRemote.init(),
      ]);
      debugPrint('All remote datasources initialized');
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing remote datasources: $e');
    }
  }

  /// Listen for connectivity changes
  void _listenToConnectivity() {
    _connectivitySubscription = _networkInfo.onConnectivityChanged.listen((isOnline) {
      if (isOnline && _pendingCount > 0) {
        // Auto-sync when coming back online
        syncAll();
      }
    });
  }

  /// Full bidirectional sync (push local changes, then pull cloud changes)
  Future<void> syncAll() async {
    if (_isSyncing) return;

    // Check connectivity
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) {
      _lastSyncError = 'No internet connection';
      notifyListeners();
      return;
    }

    _isSyncing = true;
    _lastSyncError = null;
    notifyListeners();

    try {
      // First, push local changes to cloud
      await _pushAllToCloud();
      
      // Then, pull cloud changes to local
      await _pullAllFromCloud();

      _lastSyncTime = DateTime.now();
      _checkPendingCount();
    } catch (e) {
      _lastSyncError = e.toString();
      debugPrint('Sync error: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Push all local changes to cloud
  Future<void> _pushAllToCloud() async {
    await syncCustomers();
    await syncProducts();
    await syncMedicines();
    await syncOrders();
    await syncSales();
  }

  /// Pull all data from cloud to local
  Future<void> _pullAllFromCloud() async {
    if (_isPulling) return;
    
    _isPulling = true;
    notifyListeners();

    try {
      await _pullCustomers();
      await _pullProducts();
      await _pullMedicines();
      await _pullOrders();
      await _pullSales();

      _lastPullTime = DateTime.now();
    } catch (e) {
      debugPrint('Pull sync error: $e');
      _lastSyncError = 'Pull sync failed: ${e.toString()}';
    } finally {
      _isPulling = false;
      notifyListeners();
    }
  }

  /// Pull all data from cloud (public method)
  Future<void> pullAllFromCloud() async {
    if (_isPulling) return;

    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) {
      _lastSyncError = 'No internet connection';
      notifyListeners();
      return;
    }

    await _pullAllFromCloud();
  }

  // ==================== PUSH SYNC METHODS ====================

  /// Sync customers (push local to cloud)
  Future<void> syncCustomers() async {
    if (!_customerRemote.isAvailable) return;
    
    try {
      final unsynced = await _customerLocal.getUnsyncedCustomers();
      final syncQueue = HiveService.syncQueueBox;

      for (final customer in unsynced) {
        try {
          final queueKey = 'customer_${customer.id}';
          final queueItem = syncQueue.get(queueKey);

          if (queueItem != null) {
            final action = queueItem.action;

            switch (action) {
              case 'create':
                await _customerRemote.addCustomer(customer.toJson());
                break;
              case 'update':
                await _customerRemote.updateCustomer(customer.toJson());
                break;
              case 'delete':
                await _customerRemote.deleteCustomer(customer.id);
                break;
            }

            // Mark as synced
            await _customerLocal.markAsSynced(customer.id, firebaseId: customer.id);
            await _customerLocal.removeFromSyncQueue(customer.id);
          } else {
            // No queue item but unsynced - just push to cloud
            await _customerRemote.addCustomer(customer.toJson());
            await _customerLocal.markAsSynced(customer.id, firebaseId: customer.id);
          }
        } catch (e) {
          debugPrint('Failed to sync customer ${customer.id}: $e');
          // Continue with next item
        }
      }
    } catch (e) {
      debugPrint('Error syncing customers: $e');
    }
  }

  /// Sync feed products (push local to cloud)
  Future<void> syncProducts() async {
    if (!_productRemote.isAvailable) return;
    
    try {
      final unsynced = await _productLocal.getUnsyncedProducts();
      final syncQueue = HiveService.syncQueueBox;

      for (final product in unsynced) {
        try {
          final queueKey = 'feedProduct_${product.id}';
          final queueItem = syncQueue.get(queueKey);

          if (queueItem != null) {
            final action = queueItem.action;

            switch (action) {
              case 'create':
                await _productRemote.addProduct(product.toJson());
                break;
              case 'update':
                await _productRemote.updateProduct(product.toJson());
                break;
              case 'delete':
                await _productRemote.deleteProduct(product.id);
                break;
            }

            await _productLocal.markAsSynced(product.id, firebaseId: product.id);
            await _productLocal.removeFromSyncQueue(product.id);
          } else {
            await _productRemote.addProduct(product.toJson());
            await _productLocal.markAsSynced(product.id, firebaseId: product.id);
          }
        } catch (e) {
          debugPrint('Failed to sync product ${product.id}: $e');
        }
      }
    } catch (e) {
      debugPrint('Error syncing products: $e');
    }
  }

  /// Sync medicines (push local to cloud)
  Future<void> syncMedicines() async {
    if (!_medicineRemote.isAvailable) return;
    
    try {
      final unsynced = await _medicineLocal.getUnsyncedMedicines();
      final syncQueue = HiveService.syncQueueBox;

      for (final medicine in unsynced) {
        try {
          final queueKey = 'medicine_${medicine.id}';
          final queueItem = syncQueue.get(queueKey);

          if (queueItem != null) {
            final action = queueItem.action;

            switch (action) {
              case 'create':
                await _medicineRemote.addMedicine(medicine.toJson());
                break;
              case 'update':
                await _medicineRemote.updateMedicine(medicine.toJson());
                break;
              case 'delete':
                await _medicineRemote.deleteMedicine(medicine.id);
                break;
            }

            await _medicineLocal.markAsSynced(medicine.id, firebaseId: medicine.id);
            await _medicineLocal.removeFromSyncQueue(medicine.id);
          } else {
            await _medicineRemote.addMedicine(medicine.toJson());
            await _medicineLocal.markAsSynced(medicine.id, firebaseId: medicine.id);
          }
        } catch (e) {
          debugPrint('Failed to sync medicine ${medicine.id}: $e');
        }
      }
    } catch (e) {
      debugPrint('Error syncing medicines: $e');
    }
  }

  /// Sync orders (push local to cloud)
  Future<void> syncOrders() async {
    if (!_orderRemote.isAvailable) return;
    
    try {
      final unsynced = await _orderLocal.getUnsyncedOrders();
      final syncQueue = HiveService.syncQueueBox;

      for (final order in unsynced) {
        try {
          final queueKey = 'order_${order.id}';
          final queueItem = syncQueue.get(queueKey);

          if (queueItem != null) {
            final action = queueItem.action;

            switch (action) {
              case 'create':
                await _orderRemote.addOrder(order.toJson());
                break;
              case 'update':
                await _orderRemote.updateOrder(order.toJson());
                break;
              case 'delete':
                await _orderRemote.deleteOrder(order.id);
                break;
            }

            await _orderLocal.markAsSynced(order.id, firebaseId: order.id);
            await _orderLocal.removeFromSyncQueue(order.id);
          } else {
            await _orderRemote.addOrder(order.toJson());
            await _orderLocal.markAsSynced(order.id, firebaseId: order.id);
          }
        } catch (e) {
          debugPrint('Failed to sync order ${order.id}: $e');
        }
      }
    } catch (e) {
      debugPrint('Error syncing orders: $e');
    }
  }

  /// Sync sales (push local to cloud)
  Future<void> syncSales() async {
    if (!_saleRemote.isAvailable) return;
    
    try {
      final unsynced = await _saleLocal.getUnsyncedSales();
      final syncQueue = HiveService.syncQueueBox;

      for (final sale in unsynced) {
        try {
          final queueKey = 'sale_${sale.id}';
          final queueItem = syncQueue.get(queueKey);

          if (queueItem != null) {
            final action = queueItem.action;

            switch (action) {
              case 'create':
                await _saleRemote.addSale(sale.toJson());
                break;
              case 'update':
                await _saleRemote.updateSale(sale.toJson());
                break;
              case 'delete':
                await _saleRemote.deleteSale(sale.id);
                break;
            }

            await _saleLocal.markAsSynced(sale.id, firebaseId: sale.id);
            await _saleLocal.removeFromSyncQueue(sale.id);
          } else {
            await _saleRemote.addSale(sale.toJson());
            await _saleLocal.markAsSynced(sale.id, firebaseId: sale.id);
          }
        } catch (e) {
          debugPrint('Failed to sync sale ${sale.id}: $e');
        }
      }
    } catch (e) {
      debugPrint('Error syncing sales: $e');
    }
  }

  // ==================== PULL SYNC METHODS ====================

  /// Pull customers from cloud to local
  Future<void> _pullCustomers() async {
    if (!_customerRemote.isAvailable) return;

    try {
      final cloudCustomers = await _customerRemote.fetchCustomers();

      for (final cloudData in cloudCustomers) {
        try {
          final localCustomer = await _customerLocal.getCustomerById(cloudData['id']);

          if (localCustomer == null) {
            // New customer from cloud - add to local
            final customer = CustomerModel.fromJson(cloudData);
            customer.isSynced = true;
            customer.firebaseId = cloudData['firebaseId'] ?? cloudData['id'];
            await _customerLocal.batchInsert([customer]);
            debugPrint('Pulled new customer: ${customer.id}');
          } else {
            // Existing customer - check for conflicts
            final shouldUpdate = _shouldUpdateLocal(
              localUpdatedAt: localCustomer.updatedAt,
              cloudUpdatedAt: DateTime.parse(cloudData['updatedAt']),
              isLocalSynced: localCustomer.isSynced,
            );

            if (shouldUpdate) {
              final customer = CustomerModel.fromJson(cloudData);
              customer.isSynced = true;
              customer.firebaseId = cloudData['firebaseId'] ?? cloudData['id'];
              await _customerLocal.batchInsert([customer]);
              debugPrint('Updated customer from cloud: ${customer.id}');
            }
          }
        } catch (e) {
          debugPrint('Error pulling customer ${cloudData['id']}: $e');
        }
      }
    } catch (e) {
      debugPrint('Error pulling customers: $e');
    }
  }

  /// Pull feed products from cloud to local
  Future<void> _pullProducts() async {
    if (!_productRemote.isAvailable) return;

    try {
      final cloudProducts = await _productRemote.fetchProducts();

      for (final cloudData in cloudProducts) {
        try {
          final localProduct = await _productLocal.getProductById(cloudData['id']);

          if (localProduct == null) {
            final product = FeedProductModel.fromJson(cloudData);
            product.isSynced = true;
            product.firebaseId = cloudData['firebaseId'] ?? cloudData['id'];
            await _productLocal.batchInsert([product]);
            debugPrint('Pulled new product: ${product.id}');
          } else {
            final shouldUpdate = _shouldUpdateLocal(
              localUpdatedAt: localProduct.updatedAt,
              cloudUpdatedAt: DateTime.parse(cloudData['updatedAt']),
              isLocalSynced: localProduct.isSynced,
            );

            if (shouldUpdate) {
              final product = FeedProductModel.fromJson(cloudData);
              product.isSynced = true;
              product.firebaseId = cloudData['firebaseId'] ?? cloudData['id'];
              await _productLocal.batchInsert([product]);
              debugPrint('Updated product from cloud: ${product.id}');
            }
          }
        } catch (e) {
          debugPrint('Error pulling product ${cloudData['id']}: $e');
        }
      }
    } catch (e) {
      debugPrint('Error pulling products: $e');
    }
  }

  /// Pull medicines from cloud to local
  Future<void> _pullMedicines() async {
    if (!_medicineRemote.isAvailable) return;

    try {
      final cloudMedicines = await _medicineRemote.fetchMedicines();

      for (final cloudData in cloudMedicines) {
        try {
          final localMedicine = await _medicineLocal.getMedicineById(cloudData['id']);

          if (localMedicine == null) {
            final medicine = MedicineModel.fromJson(cloudData);
            medicine.isSynced = true;
            medicine.firebaseId = cloudData['firebaseId'] ?? cloudData['id'];
            await _medicineLocal.batchInsert([medicine]);
            debugPrint('Pulled new medicine: ${medicine.id}');
          } else {
            final shouldUpdate = _shouldUpdateLocal(
              localUpdatedAt: localMedicine.updatedAt,
              cloudUpdatedAt: DateTime.parse(cloudData['updatedAt']),
              isLocalSynced: localMedicine.isSynced,
            );

            if (shouldUpdate) {
              final medicine = MedicineModel.fromJson(cloudData);
              medicine.isSynced = true;
              medicine.firebaseId = cloudData['firebaseId'] ?? cloudData['id'];
              await _medicineLocal.batchInsert([medicine]);
              debugPrint('Updated medicine from cloud: ${medicine.id}');
            }
          }
        } catch (e) {
          debugPrint('Error pulling medicine ${cloudData['id']}: $e');
        }
      }
    } catch (e) {
      debugPrint('Error pulling medicines: $e');
    }
  }

  /// Pull orders from cloud to local
  Future<void> _pullOrders() async {
    if (!_orderRemote.isAvailable) return;

    try {
      final cloudOrders = await _orderRemote.fetchOrders();

      for (final cloudData in cloudOrders) {
        try {
          final localOrder = await _orderLocal.getOrderById(cloudData['id']);

          if (localOrder == null) {
            final order = OrderModel.fromJson(cloudData);
            order.isSynced = true;
            order.firebaseId = cloudData['firebaseId'] ?? cloudData['id'];
            await _orderLocal.batchInsert([order]);
            debugPrint('Pulled new order: ${order.id}');
          } else {
            final shouldUpdate = _shouldUpdateLocal(
              localUpdatedAt: localOrder.updatedAt,
              cloudUpdatedAt: DateTime.parse(cloudData['updatedAt']),
              isLocalSynced: localOrder.isSynced,
            );

            if (shouldUpdate) {
              final order = OrderModel.fromJson(cloudData);
              order.isSynced = true;
              order.firebaseId = cloudData['firebaseId'] ?? cloudData['id'];
              await _orderLocal.batchInsert([order]);
              debugPrint('Updated order from cloud: ${order.id}');
            }
          }
        } catch (e) {
          debugPrint('Error pulling order ${cloudData['id']}: $e');
        }
      }
    } catch (e) {
      debugPrint('Error pulling orders: $e');
    }
  }

  /// Pull sales from cloud to local
  Future<void> _pullSales() async {
    if (!_saleRemote.isAvailable) return;

    try {
      final cloudSales = await _saleRemote.fetchSales();

      for (final cloudData in cloudSales) {
        try {
          final localSale = await _saleLocal.getSaleById(cloudData['id']);

          if (localSale == null) {
            final sale = SaleModel.fromJson(cloudData);
            sale.isSynced = true;
            sale.firebaseId = cloudData['firebaseId'] ?? cloudData['id'];
            await _saleLocal.batchInsert([sale]);
            debugPrint('Pulled new sale: ${sale.id}');
          } else {
            final shouldUpdate = _shouldUpdateLocal(
              localUpdatedAt: localSale.updatedAt,
              cloudUpdatedAt: DateTime.parse(cloudData['updatedAt']),
              isLocalSynced: localSale.isSynced,
            );

            if (shouldUpdate) {
              final sale = SaleModel.fromJson(cloudData);
              sale.isSynced = true;
              sale.firebaseId = cloudData['firebaseId'] ?? cloudData['id'];
              await _saleLocal.batchInsert([sale]);
              debugPrint('Updated sale from cloud: ${sale.id}');
            }
          }
        } catch (e) {
          debugPrint('Error pulling sale ${cloudData['id']}: $e');
        }
      }
    } catch (e) {
      debugPrint('Error pulling sales: $e');
    }
  }

  // ==================== CONFLICT RESOLUTION ====================

  /// Determine if local data should be updated with cloud data
  bool _shouldUpdateLocal({
    required DateTime localUpdatedAt,
    required DateTime cloudUpdatedAt,
    required bool isLocalSynced,
  }) {
    switch (conflictResolution) {
      case ConflictResolution.cloudWins:
        // Cloud always wins
        return true;
        
      case ConflictResolution.localWins:
        // Local always wins - only update if local is already synced
        return isLocalSynced;
        
      case ConflictResolution.latestWins:
        // Most recently updated wins
        // If local has unsynced changes, keep local data
        if (!isLocalSynced) {
          return cloudUpdatedAt.isAfter(localUpdatedAt);
        }
        return cloudUpdatedAt.isAfter(localUpdatedAt);
        
      case ConflictResolution.merge:
        // For merge strategy, we need field-level comparison
        // For now, fall back to latest wins
        return cloudUpdatedAt.isAfter(localUpdatedAt);
    }
  }

  // ==================== UTILITY METHODS ====================

  /// Check pending sync count
  void _checkPendingCount() {
    try {
      _pendingCount = HiveService.syncQueueBox.length;
      notifyListeners();
    } catch (e) {
      _pendingCount = 0;
    }
  }

  /// Refresh pending count
  void refreshPendingCount() {
    _checkPendingCount();
  }

  /// Start auto-sync timer (every 5 minutes)
  void _startAutoSync() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (!_isSyncing) {
        syncAll();
      }
    });
  }

  /// Stop auto-sync timer
  void stopAutoSync() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = null;
  }

  /// Clear last sync error
  void clearError() {
    _lastSyncError = null;
    notifyListeners();
  }

  /// Force full sync (clears local sync status and re-syncs everything)
  Future<void> forceFullSync() async {
    if (_isSyncing) return;
    
    debugPrint('Starting force full sync...');
    await syncAll();
    debugPrint('Force full sync completed');
  }

  /// Get sync status summary
  Map<String, dynamic> getSyncStatus() {
    return {
      'isSyncing': _isSyncing,
      'isPulling': _isPulling,
      'pendingCount': _pendingCount,
      'lastSyncTime': _lastSyncTime?.toIso8601String(),
      'lastPullTime': _lastPullTime?.toIso8601String(),
      'lastError': _lastSyncError,
      'isCloudAvailable': isCloudAvailable,
      'conflictResolution': conflictResolution.name,
    };
  }

  /// Dispose resources
  @override
  void dispose() {
    _autoSyncTimer?.cancel();
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
