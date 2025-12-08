import '../../data/models/feed_product_model.dart';

/// Abstract repository interface for Feed Product operations
/// 
/// This defines the contract for feed product data operations.
/// Implementations can be swapped for testing or different data sources.
abstract class FeedProductRepository {
  /// Get all products
  Future<List<FeedProductModel>> getAllProducts();

  /// Get a product by ID
  Future<FeedProductModel?> getProductById(String id);

  /// Add a new product
  Future<void> addProduct(FeedProductModel product);

  /// Update an existing product
  Future<void> updateProduct(FeedProductModel product);

  /// Delete a product
  Future<void> deleteProduct(String id);

  /// Search products by query
  Future<List<FeedProductModel>> searchProducts(String query);

  /// Get products by category
  Future<List<FeedProductModel>> getProductsByCategory(String category);

  /// Get products with low stock
  Future<List<FeedProductModel>> getLowStockProducts();

  /// Get out of stock products
  Future<List<FeedProductModel>> getOutOfStockProducts();

  /// Update product stock
  Future<void> updateStock(String id, int quantity, {bool add = true});

  /// Deduct stock for order/sale
  Future<bool> deductStock(String id, int quantity);

  /// Get all categories
  List<String> getAllCategories();

  /// Get total number of products
  int get totalCount;

  /// Get total stock value
  double get totalStockValue;

  /// Get count of low stock products
  int get lowStockCount;
}
