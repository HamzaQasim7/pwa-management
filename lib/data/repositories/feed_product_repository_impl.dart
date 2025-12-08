import '../../domain/repositories/feed_product_repository.dart';
import '../datasources/feed_product_local_datasource.dart';
import '../models/feed_product_model.dart';

/// Implementation of FeedProductRepository using local datasource
/// 
/// This implementation follows the offline-first pattern:
/// - All operations work with local Hive database first
/// - Changes are queued for sync automatically by the datasource
class FeedProductRepositoryImpl implements FeedProductRepository {
  final FeedProductLocalDatasource _localDatasource;

  FeedProductRepositoryImpl(this._localDatasource);

  @override
  Future<List<FeedProductModel>> getAllProducts() async {
    return _localDatasource.getAllProducts();
  }

  @override
  Future<FeedProductModel?> getProductById(String id) async {
    return _localDatasource.getProductById(id);
  }

  @override
  Future<void> addProduct(FeedProductModel product) async {
    await _localDatasource.addProduct(product);
  }

  @override
  Future<void> updateProduct(FeedProductModel product) async {
    await _localDatasource.updateProduct(product);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _localDatasource.deleteProduct(id);
  }

  @override
  Future<List<FeedProductModel>> searchProducts(String query) async {
    return _localDatasource.searchProducts(query);
  }

  @override
  Future<List<FeedProductModel>> getProductsByCategory(String category) async {
    return _localDatasource.getProductsByCategory(category);
  }

  @override
  Future<List<FeedProductModel>> getLowStockProducts() async {
    return _localDatasource.getLowStockProducts();
  }

  @override
  Future<List<FeedProductModel>> getOutOfStockProducts() async {
    return _localDatasource.getOutOfStockProducts();
  }

  @override
  Future<void> updateStock(String id, int quantity, {bool add = true}) async {
    await _localDatasource.updateStock(id, quantity, add: add);
  }

  @override
  Future<bool> deductStock(String id, int quantity) async {
    return _localDatasource.deductStock(id, quantity);
  }

  @override
  List<String> getAllCategories() {
    return _localDatasource.getAllCategories();
  }

  @override
  int get totalCount => _localDatasource.totalCount;

  @override
  double get totalStockValue => _localDatasource.totalStockValue;

  @override
  int get lowStockCount => _localDatasource.lowStockCount;
}
