import 'package:flutter/foundation.dart';

import '../../core/utils/uuid_generator.dart';
import '../../data/models/sale_model.dart';
import '../../domain/repositories/sale_repository.dart';

/// Provider for managing medicine sale state
/// 
/// Handles all sale-related operations and state management.
/// Uses the repository pattern for data access.
class SaleProvider with ChangeNotifier {
  final SaleRepository _repository;

  List<SaleModel> _sales = [];
  SaleModel? _selectedSale;
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _paymentMethodFilter = 'All'; // All, Cash, Card, UPI, Credit
  DateTime? _startDate;
  DateTime? _endDate;

  // Cart for creating new sales
  List<SaleItemModel> _cartItems = [];
  String? _selectedCustomerId;
  String? _selectedCustomerName;

  SaleProvider(this._repository) {
    loadSales();
  }

  // Getters
  List<SaleModel> get sales {
    var filtered = _sales;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final lowerQuery = _searchQuery.toLowerCase();
      filtered = filtered.where((s) {
        return s.billNumber.toLowerCase().contains(lowerQuery) ||
            (s.customerName?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();
    }

    // Apply payment method filter
    if (_paymentMethodFilter != 'All') {
      filtered = filtered.where((s) => s.paymentMethod == _paymentMethodFilter).toList();
    }

    // Apply date filter
    if (_startDate != null) {
      filtered = filtered.where((s) => s.date.isAfter(_startDate!.subtract(const Duration(days: 1)))).toList();
    }
    if (_endDate != null) {
      filtered = filtered.where((s) => s.date.isBefore(_endDate!.add(const Duration(days: 1)))).toList();
    }

    return filtered;
  }

  List<SaleModel> get allSales => _sales;
  SaleModel? get selectedSale => _selectedSale;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get paymentMethodFilter => _paymentMethodFilter;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  // Cart getters
  List<SaleItemModel> get cartItems => _cartItems;
  String? get selectedCustomerId => _selectedCustomerId;
  String? get selectedCustomerName => _selectedCustomerName;
  bool get hasItemsInCart => _cartItems.isNotEmpty;
  double get cartSubtotal => _cartItems.fold(0.0, (sum, item) => sum + item.total);
  double get cartDiscount => _cartItems.fold(0.0, (sum, item) => sum + item.discount);
  double get cartTotal => cartSubtotal - cartDiscount;
  double get cartProfit => _cartItems.fold(0.0, (sum, item) => sum + item.profit);

  int get totalCount => _repository.totalCount;
  double get totalRevenue => _repository.totalRevenue;
  double get totalProfit => _repository.totalProfit;
  double get totalDiscount => _repository.totalDiscount;
  double get todaysRevenue => _repository.todaysRevenue;
  double get todaysProfit => _repository.todaysProfit;
  int get todaysSalesCount => _repository.todaysSalesCount;
  double get averageProfitMargin => _repository.averageProfitMargin;

  /// Load all sales from repository
  Future<void> loadSales() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _sales = await _repository.getAllSales();
      _error = null;
    } catch (e) {
      _error = 'Failed to load sales: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new sale from cart
  Future<bool> createSale({
    String paymentMethod = 'Cash',
    String? notes,
    double discount = 0,
  }) async {
    if (_cartItems.isEmpty) {
      _error = 'Cart is empty';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final subtotal = cartSubtotal;
      final total = subtotal - discount;
      final profit = cartProfit;

      final sale = SaleModel(
        id: UuidGenerator.generate(),
        billNumber: _repository.generateBillNumber(),
        date: DateTime.now(),
        subtotal: subtotal,
        discount: discount,
        total: total,
        profit: profit,
        customerId: _selectedCustomerId,
        customerName: _selectedCustomerName,
        items: List.from(_cartItems),
        paymentMethod: paymentMethod,
        notes: notes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isSynced: false,
      );

      await _repository.addSale(sale);
      clearCart();
      await loadSales();
      return true;
    } catch (e) {
      _error = 'Failed to create sale: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update an existing sale
  Future<bool> updateSale(SaleModel sale) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateSale(sale);
      await loadSales();
      
      if (_selectedSale?.id == sale.id) {
        _selectedSale = sale;
      }
      
      return true;
    } catch (e) {
      _error = 'Failed to update sale: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete a sale
  Future<bool> deleteSale(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteSale(id);
      await loadSales();
      
      if (_selectedSale?.id == id) {
        _selectedSale = null;
      }
      
      return true;
    } catch (e) {
      _error = 'Failed to delete sale: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
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
  void addToCart(SaleItemModel item) {
    final existingIndex = _cartItems.indexWhere((i) => i.productId == item.productId);
    if (existingIndex >= 0) {
      // Update quantity if item exists
      final existing = _cartItems[existingIndex];
      _cartItems[existingIndex] = SaleItemModel(
        productId: existing.productId,
        productName: existing.productName,
        quantity: existing.quantity + item.quantity,
        rate: existing.rate,
        discount: existing.discount + item.discount,
        total: existing.total + item.total,
        purchasePrice: existing.purchasePrice,
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
      _cartItems[index] = SaleItemModel(
        productId: item.productId,
        productName: item.productName,
        quantity: quantity,
        rate: item.rate,
        discount: 0,
        total: newTotal,
        purchasePrice: item.purchasePrice,
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

  /// Select a sale
  void selectSale(SaleModel? sale) {
    _selectedSale = sale;
    notifyListeners();
  }

  /// Get sale by ID
  Future<SaleModel?> getSaleById(String id) async {
    return _repository.getSaleById(id);
  }

  /// Get sales by customer
  Future<List<SaleModel>> getSalesByCustomer(String customerId) async {
    return _repository.getSalesByCustomer(customerId);
  }

  /// Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Set payment method filter
  void setPaymentMethodFilter(String method) {
    _paymentMethodFilter = method;
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
    _paymentMethodFilter = 'All';
    _startDate = null;
    _endDate = null;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Refresh sales
  Future<void> refresh() async {
    await loadSales();
  }
}
