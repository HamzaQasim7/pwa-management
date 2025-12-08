import '../../data/models/medicine_model.dart';

/// Abstract repository interface for Medicine operations
/// 
/// This defines the contract for medicine data operations.
/// Implementations can be swapped for testing or different data sources.
abstract class MedicineRepository {
  /// Get all medicines
  Future<List<MedicineModel>> getAllMedicines();

  /// Get a medicine by ID
  Future<MedicineModel?> getMedicineById(String id);

  /// Add a new medicine
  Future<void> addMedicine(MedicineModel medicine);

  /// Update an existing medicine
  Future<void> updateMedicine(MedicineModel medicine);

  /// Delete a medicine
  Future<void> deleteMedicine(String id);

  /// Search medicines by query
  Future<List<MedicineModel>> searchMedicines(String query);

  /// Get medicines by category
  Future<List<MedicineModel>> getMedicinesByCategory(String category);

  /// Get medicines with low stock
  Future<List<MedicineModel>> getLowStockMedicines();

  /// Get out of stock medicines
  Future<List<MedicineModel>> getOutOfStockMedicines();

  /// Get expired medicines
  Future<List<MedicineModel>> getExpiredMedicines();

  /// Get medicines expiring soon
  Future<List<MedicineModel>> getExpiringSoonMedicines({int days = 30});

  /// Update medicine stock
  Future<void> updateStock(String id, int quantity, {bool add = true});

  /// Deduct stock for sale
  Future<bool> deductStock(String id, int quantity);

  /// Get all categories
  List<String> getAllCategories();

  /// Get all manufacturers
  List<String> getAllManufacturers();

  /// Get total number of medicines
  int get totalCount;

  /// Get total stock value at cost
  double get totalStockValueAtCost;

  /// Get total stock value at sale price
  double get totalStockValueAtSale;

  /// Get potential profit
  double get potentialProfit;

  /// Get count of low stock medicines
  int get lowStockCount;

  /// Get count of expired medicines
  int get expiredCount;

  /// Get count of medicines expiring soon
  int get expiringSoonCount;
}
