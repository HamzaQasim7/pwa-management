import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/database/hive_service.dart';
import '../../core/network/network_info.dart';

/// Provider for managing sync state
/// 
/// Handles offline data synchronization status and operations.
/// Monitors connectivity and pending sync items.
class SyncProvider with ChangeNotifier {
  bool _isSyncing = false;
  bool _isOnline = true;
  int _pendingCount = 0;
  DateTime? _lastSyncTime;
  String? _lastSyncError;
  bool _autoSyncEnabled = true;
  Timer? _autoSyncTimer;
  StreamSubscription<bool>? _connectivitySubscription;

  SyncProvider() {
    _init();
  }

  // Getters
  bool get isSyncing => _isSyncing;
  bool get isOnline => _isOnline;
  int get pendingCount => _pendingCount;
  DateTime? get lastSyncTime => _lastSyncTime;
  String? get lastSyncError => _lastSyncError;
  bool get autoSyncEnabled => _autoSyncEnabled;
  bool get hasPendingChanges => _pendingCount > 0;

  /// Initialize sync provider
  Future<void> _init() async {
    // Check initial connectivity
    _isOnline = await networkInfo.isConnected;
    
    // Listen for connectivity changes
    _connectivitySubscription = networkInfo.onConnectivityChanged.listen((isOnline) {
      _isOnline = isOnline;
      notifyListeners();
      
      // Sync when coming back online
      if (isOnline && _pendingCount > 0) {
        syncAll();
      }
    });

    // Check pending items
    _updatePendingCount();

    // Start auto sync timer
    _startAutoSyncTimer();
  }

  /// Update pending count from sync queue
  void _updatePendingCount() {
    try {
      _pendingCount = HiveService.syncQueueBox.length;
      notifyListeners();
    } catch (e) {
      // Box might not be initialized yet
      _pendingCount = 0;
    }
  }

  /// Start auto sync timer (every 5 minutes)
  void _startAutoSyncTimer() {
    _autoSyncTimer?.cancel();
    if (_autoSyncEnabled) {
      _autoSyncTimer = Timer.periodic(
        const Duration(minutes: 5),
        (_) => syncAll(),
      );
    }
  }

  /// Sync all pending changes
  /// 
  /// In this implementation, sync is handled locally only.
  /// Firebase sync can be added later by implementing remote datasources.
  Future<void> syncAll() async {
    if (_isSyncing) return;
    if (!_isOnline) {
      _lastSyncError = 'No internet connection';
      notifyListeners();
      return;
    }

    _isSyncing = true;
    _lastSyncError = null;
    notifyListeners();

    try {
      // In offline-first mode, all data is already saved locally
      // This is where Firebase sync would happen
      
      // For now, just mark all items as synced
      await _markAllAsSynced();
      
      _lastSyncTime = DateTime.now();
      _updatePendingCount();
    } catch (e) {
      _lastSyncError = 'Sync failed: ${e.toString()}';
    } finally {
      _isSyncing = false;
      notifyListeners();
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
    if (enabled) {
      _startAutoSyncTimer();
    } else {
      _autoSyncTimer?.cancel();
    }
    notifyListeners();
  }

  /// Force refresh pending count
  void refreshPendingCount() {
    _updatePendingCount();
  }

  /// Clear sync error
  void clearError() {
    _lastSyncError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _autoSyncTimer?.cancel();
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
