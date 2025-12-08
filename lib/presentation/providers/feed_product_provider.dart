import 'package:flutter/foundation.dart';

import '../../core/utils/uuid_generator.dart';
import '../../data/models/feed_product_model.dart';
import '../../domain/repositories/feed_product_repository.dart';

/// Provider for managing feed product state
/// 
/// Handles all feed product-related operations and state management.
/// Uses the repository pattern for data access.
class FeedProductProvider with ChangeNotifier {
  final FeedProductRepository _repository;

  List<FeedProductModel> _products = [];
  FeedProductModel? _selectedProduct;
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  Set<String> _selectedCategories = {};

  FeedProductProvider(this._repository) {
    loadProducts();
  }

  // Getters
  List<FeedProductModel> get products {
    var filtered = _products;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final lowerQuery = _searchQuery.toLowerCase();
      filtered = filtered.where((p) {
        return p.name.toLowerCase().contains(lowerQuery) ||
            p.category.toLowerCase().contains(lowerQuery);
      }).toList();
    }

    // Apply category filter
    if (_selectedCategories.isNotEmpty) {
      filtered = filtered
          .where((p) => _selectedCategories.contains(p.category))
          .toList();
    }

    return filtered;
  }

  List<FeedProductModel> get allProducts => _products;
  FeedProductModel? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  Set<String> get selectedCategories => _selectedCategories;

  int get totalCount => _repository.totalCount;
  double get totalStockValue => _repository.totalStockValue;
  int get lowStockCount => _repository.lowStockCount;
  List<String> get allCategories => _repository.getAllCategories();

  /// Get low stock products
  List<FeedProductModel> get lowStockProducts =>
      _products.where((p) => p.isLowStock).toList();

  /// Get out of stock products
  List<FeedProductModel> get outOfStockProducts =>
      _products.where((p) => p.stock <= 0).toList();

  /// Load all products from repository
  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _repository.getAllProducts();
      _error = null;
    } catch (e) {
      _error = 'Failed to load products: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new product
  Future<bool> addProduct({
    required String name,
    required String category,
    String? image,
    required String unit,
    required int stock,
    required int lowStockThreshold,
    required double rate,
    String? supplier,
    String? description,
    double? purchasePrice,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final product = FeedProductModel(
        id: UuidGenerator.generate(),
        name: name,
        category: category,
        image: image,
        unit: unit,
        stock: stock,
        lowStockThreshold: lowStockThreshold,
        rate: rate,
        supplier: supplier,
        description: description,
        purchasePrice: purchasePrice,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isSynced: false,
      );

      await _repository.addProduct(product);
      await loadProducts();
      return true;
    } catch (e) {
      _error = 'Failed to add product: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update an existing product
  Future<bool> updateProduct(FeedProductModel product) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateProduct(product);
      await loadProducts();
      
      if (_selectedProduct?.id == product.id) {
        _selectedProduct = product;
      }
      
      return true;
    } catch (e) {
      _error = 'Failed to update product: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete a product
  Future<bool> deleteProduct(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteProduct(id);
      await loadProducts();
      
      if (_selectedProduct?.id == id) {
        _selectedProduct = null;
      }
      
      return true;
    } catch (e) {
      _error = 'Failed to delete product: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update product stock
  Future<bool> updateStock(String id, int quantity, {bool add = true}) async {
    try {
      await _repository.updateStock(id, quantity, add: add);
      await loadProducts();
      return true;
    } catch (e) {
      _error = 'Failed to update stock: ${e.toString()}';
      return false;
    }
  }

  /// Deduct stock (for orders)
  Future<bool> deductStock(String id, int quantity) async {
    try {
      final success = await _repository.deductStock(id, quantity);
      if (success) {
        await loadProducts();
      } else {
        _error = 'Insufficient stock';
      }
      return success;
    } catch (e) {
      _error = 'Failed to deduct stock: ${e.toString()}';
      return false;
    }
  }

  /// Select a product
  void selectProduct(FeedProductModel? product) {
    _selectedProduct = product;
    notifyListeners();
  }

  /// Get product by ID
  Future<FeedProductModel?> getProductById(String id) async {
    return _repository.getProductById(id);
  }

  /// Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Toggle category filter
  void toggleCategory(String category) {
    if (_selectedCategories.contains(category)) {
      _selectedCategories.remove(category);
    } else {
      _selectedCategories.add(category);
    }
    notifyListeners();
  }

  /// Set selected categories
  void setSelectedCategories(Set<String> categories) {
    _selectedCategories = categories;
    notifyListeners();
  }

  /// Clear filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCategories.clear();
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Refresh products
  Future<void> refresh() async {
    await loadProducts();
  }
}
