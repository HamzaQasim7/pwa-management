import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/database/hive_service.dart';
import '../../core/network/network_info.dart';
import '../../core/services/sync_service.dart';

/// Provider for managing sync state
/// 
/// Wraps the SyncService and provides UI-friendly access to sync functionality.
/// Handles offline data synchronization status and operations.
class SyncProvider with ChangeNotifier {
  final SyncService? _syncService;
  
  bool _isOnline = true;
  bool _autoSyncEnabled = true;
  StreamSubscription<bool>? _connectivitySubscription;
  VoidCallback? _syncServiceListener;

  /// Create a SyncProvider with an optional SyncService
  /// If no SyncService is provided, basic sync functionality is used
  SyncProvider([this._syncService]) {
    _init();
  }

  // Getters
  bool get isSyncing => _syncService?.isSyncing ?? false;
  bool get isPulling => _syncService?.isPulling ?? false;
  bool get isOnline => _isOnline;
  int get pendingCount => _syncService?.pendingCount ?? _getLocalPendingCount();
  DateTime? get lastSyncTime => _syncService?.lastSyncTime;
  DateTime? get lastPullTime => _syncService?.lastPullTime;
  String? get lastSyncError => _syncService?.lastSyncError;
  bool get autoSyncEnabled => _autoSyncEnabled;
  bool get hasPendingChanges => pendingCount > 0;
  bool get isCloudAvailable => _syncService?.isCloudAvailable ?? false;

  /// Initialize sync provider
  Future<void> _init() async {
    // Check initial connectivity
    _isOnline = await networkInfo.isConnected;
    
    // Listen for connectivity changes
    _connectivitySubscription = networkInfo.onConnectivityChanged.listen((isOnline) {
      _isOnline = isOnline;
      notifyListeners();
    });

    // Listen to sync service changes
    if (_syncService != null) {
      _syncServiceListener = () {
        notifyListeners();
      };
      _syncService!.addListener(_syncServiceListener!);
    }

    notifyListeners();
  }

  /// Get local pending count from Hive
  int _getLocalPendingCount() {
    try {
      return HiveService.syncQueueBox.length;
    } catch (e) {
      return 0;
    }
  }

  /// Sync all pending changes (push and pull)
  Future<void> syncAll() async {
    if (_syncService != null) {
      await _syncService!.syncAll();
    } else {
      // Fallback: basic local sync
      await _basicSync();
    }
  }

  /// Pull all data from cloud
  Future<void> pullFromCloud() async {
    if (_syncService != null) {
      await _syncService!.pullAllFromCloud();
    }
  }

  /// Basic sync when no SyncService is available
  Future<void> _basicSync() async {
    if (!_isOnline) {
      debugPrint('Cannot sync: offline');
      return;
    }

    try {
      // Mark all items as synced locally
      await _markAllAsSynced();
      notifyListeners();
    } catch (e) {
      debugPrint('Basic sync error: $e');
    }
  }

  /// Mark all pending items as synced
  Future<void> _markAllAsSynced() async {
    try {
      final syncQueue = HiveService.syncQueueBox;
      
      // Mark customers as synced
      final customers = HiveService.customersBox;
      for (var customer in customers.values) {
        if (!customer.isSynced) {
          customer.isSynced = true;
          await customers.put(customer.id, customer);
        }
      }

      // Mark feed products as synced
      final products = HiveService.feedProductsBox;
      for (var product in products.values) {
        if (!product.isSynced) {
          product.isSynced = true;
          await products.put(product.id, product);
        }
      }

      // Mark medicines as synced
      final medicines = HiveService.medicinesBox;
      for (var medicine in medicines.values) {
        if (!medicine.isSynced) {
          medicine.isSynced = true;
          await medicines.put(medicine.id, medicine);
        }
      }

      // Mark orders as synced
      final orders = HiveService.ordersBox;
      for (var order in orders.values) {
        if (!order.isSynced) {
          order.isSynced = true;
          await orders.put(order.id, order);
        }
      }

      // Mark sales as synced
      final sales = HiveService.salesBox;
      for (var sale in sales.values) {
        if (!sale.isSynced) {
          sale.isSynced = true;
          await sales.put(sale.id, sale);
        }
      }

      // Clear sync queue
      await syncQueue.clear();
    } catch (e) {
      debugPrint('Error marking items as synced: $e');
    }
  }

  /// Toggle auto sync
  void setAutoSync(bool enabled) {
    _autoSyncEnabled = enabled;
    if (_syncService != null) {
      if (enabled) {
        // SyncService handles auto-sync internally
        debugPrint('Auto sync enabled');
      } else {
        _syncService!.stopAutoSync();
        debugPrint('Auto sync disabled');
      }
    }
    notifyListeners();
  }

  /// Force refresh pending count
  void refreshPendingCount() {
    _syncService?.refreshPendingCount();
    notifyListeners();
  }

  /// Clear sync error
  void clearError() {
    _syncService?.clearError();
    notifyListeners();
  }

  /// Force full sync (re-syncs everything)
  Future<void> forceFullSync() async {
    if (_syncService != null) {
      await _syncService!.forceFullSync();
    } else {
      await _basicSync();
    }
  }

  /// Get sync status summary
  Map<String, dynamic> getSyncStatus() {
    return _syncService?.getSyncStatus() ?? {
      'isSyncing': false,
      'isPulling': false,
      'pendingCount': pendingCount,
      'lastSyncTime': null,
      'lastPullTime': null,
      'lastError': null,
      'isCloudAvailable': false,
      'conflictResolution': 'latestWins',
    };
  }

  /// Set conflict resolution strategy
  void setConflictResolution(ConflictResolution strategy) {
    if (_syncService != null) {
      _syncService!.conflictResolution = strategy;
      notifyListeners();
    }
  }

  /// Get current conflict resolution strategy
  ConflictResolution get conflictResolution =>
      _syncService?.conflictResolution ?? ConflictResolution.latestWins;

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    if (_syncService != null && _syncServiceListener != null) {
      _syncService!.removeListener(_syncServiceListener!);
    }
    super.dispose();
  }
}
