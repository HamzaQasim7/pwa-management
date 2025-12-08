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

/// Service for managing data synchronization between local and remote storage
/// 
/// Implements offline-first architecture:
/// - All operations work locally first
/// - Changes are queued for sync
/// - Sync happens automatically when online
/// - Manual sync can be triggered
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
  int _pendingCount = 0;
  String? _lastSyncError;
  DateTime? _lastSyncTime;
  Timer? _autoSyncTimer;
  StreamSubscription<bool>? _connectivitySubscription;

  bool get isSyncing => _isSyncing;
  int get pendingCount => _pendingCount;
  String? get lastSyncError => _lastSyncError;
  DateTime? get lastSyncTime => _lastSyncTime;
  bool get hasPendingChanges => _pendingCount > 0;

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

  /// Listen for connectivity changes
  void _listenToConnectivity() {
    _connectivitySubscription = _networkInfo.onConnectivityChanged.listen((isOnline) {
      if (isOnline && _pendingCount > 0) {
        // Auto-sync when coming back online
        syncAll();
      }
    });
  }

  /// Sync all entities
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
      await syncCustomers();
      await syncProducts();
      await syncMedicines();
      await syncOrders();
      await syncSales();

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

  /// Sync customers
  Future<void> syncCustomers() async {
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
            await _customerLocal.markAsSynced(customer.id);
            await _customerLocal.removeFromSyncQueue(customer.id);
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

  /// Sync feed products
  Future<void> syncProducts() async {
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

            await _productLocal.markAsSynced(product.id);
            await _productLocal.removeFromSyncQueue(product.id);
          }
        } catch (e) {
          debugPrint('Failed to sync product ${product.id}: $e');
        }
      }
    } catch (e) {
      debugPrint('Error syncing products: $e');
    }
  }

  /// Sync medicines
  Future<void> syncMedicines() async {
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

            await _medicineLocal.markAsSynced(medicine.id);
            await _medicineLocal.removeFromSyncQueue(medicine.id);
          }
        } catch (e) {
          debugPrint('Failed to sync medicine ${medicine.id}: $e');
        }
      }
    } catch (e) {
      debugPrint('Error syncing medicines: $e');
    }
  }

  /// Sync orders
  Future<void> syncOrders() async {
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

            await _orderLocal.markAsSynced(order.id);
            await _orderLocal.removeFromSyncQueue(order.id);
          }
        } catch (e) {
          debugPrint('Failed to sync order ${order.id}: $e');
        }
      }
    } catch (e) {
      debugPrint('Error syncing orders: $e');
    }
  }

  /// Sync sales
  Future<void> syncSales() async {
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

            await _saleLocal.markAsSynced(sale.id);
            await _saleLocal.removeFromSyncQueue(sale.id);
          }
        } catch (e) {
          debugPrint('Failed to sync sale ${sale.id}: $e');
        }
      }
    } catch (e) {
      debugPrint('Error syncing sales: $e');
    }
  }

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

  /// Dispose resources
  @override
  void dispose() {
    _autoSyncTimer?.cancel();
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
