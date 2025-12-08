import 'package:flutter/foundation.dart';

import '../../core/utils/uuid_generator.dart';
import '../../data/models/customer_model.dart';
import '../../domain/repositories/customer_repository.dart';

/// Provider for managing customer state
/// 
/// Handles all customer-related operations and state management.
/// Uses the repository pattern for data access.
class CustomerProvider with ChangeNotifier {
  final CustomerRepository _repository;

  List<CustomerModel> _customers = [];
  CustomerModel? _selectedCustomer;
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _filterType = 'All'; // All, Retail, Wholesale, VIP, Credit, Debt

  CustomerProvider(this._repository) {
    loadCustomers();
  }

  // Getters
  List<CustomerModel> get customers {
    var filtered = _customers;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final lowerQuery = _searchQuery.toLowerCase();
      filtered = filtered.where((c) {
        return c.name.toLowerCase().contains(lowerQuery) ||
            c.phone.contains(_searchQuery) ||
            (c.shopName?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();
    }

    // Apply type filter
    switch (_filterType) {
      case 'Retail':
      case 'Wholesale':
      case 'VIP':
        filtered = filtered.where((c) => c.customerType == _filterType).toList();
        break;
      case 'Credit':
        filtered = filtered.where((c) => c.balance > 0).toList();
        break;
      case 'Debt':
        filtered = filtered.where((c) => c.balance < 0).toList();
        break;
    }

    return filtered;
  }

  List<CustomerModel> get allCustomers => _customers;
  CustomerModel? get selectedCustomer => _selectedCustomer;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get filterType => _filterType;

  int get totalCount => _repository.totalCount;
  double get totalCredit => _repository.totalCredit;
  double get totalDebt => _repository.totalDebt;

  /// Load all customers from repository
  Future<void> loadCustomers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _customers = await _repository.getAllCustomers();
      _error = null;
    } catch (e) {
      _error = 'Failed to load customers: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new customer
  Future<bool> addCustomer({
    required String name,
    required String phone,
    String? email,
    String? shopName,
    String? address,
    double balance = 0,
    String customerType = 'Retail',
    String? notes,
    String? city,
    String? area,
    double? creditLimit,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final customer = CustomerModel(
        id: UuidGenerator.generate(),
        name: name,
        phone: phone,
        email: email,
        shopName: shopName,
        address: address,
        balance: balance,
        customerType: customerType,
        notes: notes,
        city: city,
        area: area,
        creditLimit: creditLimit,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isSynced: false,
      );

      await _repository.addCustomer(customer);
      await loadCustomers();
      return true;
    } catch (e) {
      _error = 'Failed to add customer: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update an existing customer
  Future<bool> updateCustomer(CustomerModel customer) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateCustomer(customer);
      await loadCustomers();
      
      // Update selected customer if it was the one modified
      if (_selectedCustomer?.id == customer.id) {
        _selectedCustomer = customer;
      }
      
      return true;
    } catch (e) {
      _error = 'Failed to update customer: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete a customer
  Future<bool> deleteCustomer(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteCustomer(id);
      await loadCustomers();
      
      // Clear selected customer if it was deleted
      if (_selectedCustomer?.id == id) {
        _selectedCustomer = null;
      }
      
      return true;
    } catch (e) {
      _error = 'Failed to delete customer: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update customer balance
  Future<bool> updateBalance(String id, double amount) async {
    try {
      await _repository.updateBalance(id, amount);
      await loadCustomers();
      return true;
    } catch (e) {
      _error = 'Failed to update balance: ${e.toString()}';
      return false;
    }
  }

  /// Select a customer
  void selectCustomer(CustomerModel? customer) {
    _selectedCustomer = customer;
    notifyListeners();
  }

  /// Get customer by ID
  Future<CustomerModel?> getCustomerById(String id) async {
    return _repository.getCustomerById(id);
  }

  /// Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Set filter type
  void setFilterType(String type) {
    _filterType = type;
    notifyListeners();
  }

  /// Clear filters
  void clearFilters() {
    _searchQuery = '';
    _filterType = 'All';
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Refresh customers
  Future<void> refresh() async {
    await loadCustomers();
  }
}
