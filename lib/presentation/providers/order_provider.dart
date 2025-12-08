import 'package:flutter/foundation.dart';

import '../../core/utils/uuid_generator.dart';
import '../../data/models/order_model.dart';
import '../../domain/repositories/order_repository.dart';

/// Provider for managing order state
/// 
/// Handles all order-related operations and state management.
/// Uses the repository pattern for data access.
class OrderProvider with ChangeNotifier {
  final OrderRepository _repository;

  List<OrderModel> _orders = [];
  OrderModel? _selectedOrder;
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _typeFilter = 'All'; // All, feed, medicine
  String _statusFilter = 'All'; // All, Paid, Pending, Partially Paid
  DateTime? _startDate;
  DateTime? _endDate;

  // Cart for creating new orders
  List<OrderItemModel> _cartItems = [];
  String? _selectedCustomerId;
  String? _selectedCustomerName;

  OrderProvider(this._repository) {
    loadOrders();
  }

  // Getters
  List<OrderModel> get orders {
    var filtered = _orders;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final lowerQuery = _searchQuery.toLowerCase();
      filtered = filtered.where((o) {
        return o.orderNumber.toLowerCase().contains(lowerQuery) ||
            (o.customerName?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();
    }

    // Apply type filter
    if (_typeFilter != 'All') {
      filtered = filtered.where((o) => o.orderType == _typeFilter).toList();
    }

    // Apply status filter
    if (_statusFilter != 'All') {
      filtered = filtered.where((o) => o.paymentStatus == _statusFilter).toList();
    }

    // Apply date filter
    if (_startDate != null) {
      filtered = filtered.where((o) => o.date.isAfter(_startDate!.subtract(const Duration(days: 1)))).toList();
    }
    if (_endDate != null) {
      filtered = filtered.where((o) => o.date.isBefore(_endDate!.add(const Duration(days: 1)))).toList();
    }

    return filtered;
  }

  List<OrderModel> get allOrders => _orders;
  OrderModel? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get typeFilter => _typeFilter;
  String get statusFilter => _statusFilter;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  // Cart getters
  List<OrderItemModel> get cartItems => _cartItems;
  String? get selectedCustomerId => _selectedCustomerId;
  String? get selectedCustomerName => _selectedCustomerName;
  bool get hasItemsInCart => _cartItems.isNotEmpty;
  double get cartSubtotal => _cartItems.fold(0.0, (sum, item) => sum + item.total);
  double get cartDiscount => _cartItems.fold(0.0, (sum, item) => sum + item.discount);
  double get cartTotal => cartSubtotal - cartDiscount;

  int get totalCount => _repository.totalCount;
  double get totalRevenue => _repository.totalRevenue;
  double get totalPending => _repository.totalPending;
  double get todaysRevenue => _repository.todaysRevenue;

  /// Get feed orders
  List<OrderModel> get feedOrders =>
      _orders.where((o) => o.orderType == 'feed').toList();

  /// Get medicine orders
  List<OrderModel> get medicineOrders =>
      _orders.where((o) => o.orderType == 'medicine').toList();

  /// Get pending orders
  List<OrderModel> get pendingOrders =>
      _orders.where((o) => o.paymentStatus == 'Pending').toList();

  /// Load all orders from repository
  Future<void> loadOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await _repository.getAllOrders();
      _error = null;
    } catch (e) {
      _error = 'Failed to load orders: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new order from cart
  Future<bool> createOrder({
    required String orderType,
    String? notes,
    double discount = 0,
    String paymentStatus = 'Pending',
  }) async {
    if (_cartItems.isEmpty) {
      _error = 'Cart is empty';
      notifyListeners();
      return false;
    }

    if (_selectedCustomerId == null) {
      _error = 'Please select a customer';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final subtotal = cartSubtotal;
      final total = subtotal - discount;

      final order = OrderModel(
        id: UuidGenerator.generate(),
        customerId: _selectedCustomerId!,
        customerName: _selectedCustomerName,
        orderNumber: _repository.generateOrderNumber(orderType),
        date: DateTime.now(),
        subtotal: subtotal,
        discount: discount,
        total: total,
        paymentStatus: paymentStatus,
        orderType: orderType,
        items: List.from(_cartItems),
        notes: notes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isSynced: false,
      );

      await _repository.addOrder(order);
      clearCart();
      await loadOrders();
      return true;
    } catch (e) {
      _error = 'Failed to create order: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update an existing order
  Future<bool> updateOrder(OrderModel order) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateOrder(order);
      await loadOrders();
      
      if (_selectedOrder?.id == order.id) {
        _selectedOrder = order;
      }
      
      return true;
    } catch (e) {
      _error = 'Failed to update order: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete an order
  Future<bool> deleteOrder(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteOrder(id);
      await loadOrders();
      
      if (_selectedOrder?.id == id) {
        _selectedOrder = null;
      }
      
      return true;
    } catch (e) {
      _error = 'Failed to delete order: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Record payment for an order
  Future<bool> recordPayment(String id, double amount) async {
    try {
      await _repository.recordPayment(id, amount);
      await loadOrders();
      return true;
    } catch (e) {
      _error = 'Failed to record payment: ${e.toString()}';
      return false;
    }
  }

  /// Update payment status
  Future<bool> updatePaymentStatus(String id, String status) async {
    try {
      await _repository.updatePaymentStatus(id, status);
      await loadOrders();
      return true;
    } catch (e) {
      _error = 'Failed to update status: ${e.toString()}';
      return false;
    }
  }

  // Cart methods
  /// Set selected customer
  void setSelectedCustomer(String? id, String? name) {
    _selectedCustomerId = id;
    _selectedCustomerName = name;
    notifyListeners();
  }

  /// Add item to cart
  void addToCart(OrderItemModel item) {
    final existingIndex = _cartItems.indexWhere((i) => i.productId == item.productId);
    if (existingIndex >= 0) {
      // Update quantity if item exists
      final existing = _cartItems[existingIndex];
      _cartItems[existingIndex] = OrderItemModel(
        productId: existing.productId,
        productName: existing.productName,
        quantity: existing.quantity + item.quantity,
        rate: existing.rate,
        discount: existing.discount + item.discount,
        total: existing.total + item.total,
      );
    } else {
      _cartItems.add(item);
    }
    notifyListeners();
  }

  /// Remove item from cart
  void removeFromCart(String productId) {
    _cartItems.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  /// Update cart item quantity
  void updateCartItemQuantity(String productId, int quantity) {
    final index = _cartItems.indexWhere((i) => i.productId == productId);
    if (index >= 0) {
      final item = _cartItems[index];
      final newTotal = item.rate * quantity;
      _cartItems[index] = OrderItemModel(
        productId: item.productId,
        productName: item.productName,
        quantity: quantity,
        rate: item.rate,
        discount: 0,
        total: newTotal,
      );
      notifyListeners();
    }
  }

  /// Clear cart
  void clearCart() {
    _cartItems.clear();
    _selectedCustomerId = null;
    _selectedCustomerName = null;
    notifyListeners();
  }

  /// Select an order
  void selectOrder(OrderModel? order) {
    _selectedOrder = order;
    notifyListeners();
  }

  /// Get order by ID
  Future<OrderModel?> getOrderById(String id) async {
    return _repository.getOrderById(id);
  }

  /// Get orders by customer
  Future<List<OrderModel>> getOrdersByCustomer(String customerId) async {
    return _repository.getOrdersByCustomer(customerId);
  }

  /// Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Set type filter
  void setTypeFilter(String type) {
    _typeFilter = type;
    notifyListeners();
  }

  /// Set status filter
  void setStatusFilter(String status) {
    _statusFilter = status;
    notifyListeners();
  }

  /// Set date range filter
  void setDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }

  /// Clear filters
  void clearFilters() {
    _searchQuery = '';
    _typeFilter = 'All';
    _statusFilter = 'All';
    _startDate = null;
    _endDate = null;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Refresh orders
  Future<void> refresh() async {
    await loadOrders();
  }
}
