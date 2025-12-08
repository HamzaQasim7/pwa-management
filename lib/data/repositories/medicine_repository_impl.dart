import '../../domain/repositories/medicine_repository.dart';
import '../datasources/medicine_local_datasource.dart';
import '../models/medicine_model.dart';

/// Implementation of MedicineRepository using local datasource
/// 
/// This implementation follows the offline-first pattern:
/// - All operations work with local Hive database first
/// - Changes are queued for sync automatically by the datasource
class MedicineRepositoryImpl implements MedicineRepository {
  final MedicineLocalDatasource _localDatasource;

  MedicineRepositoryImpl(this._localDatasource);

  @override
  Future<List<MedicineModel>> getAllMedicines() async {
    return _localDatasource.getAllMedicines();
  }

  @override
  Future<MedicineModel?> getMedicineById(String id) async {
    return _localDatasource.getMedicineById(id);
  }

  @override
  Future<void> addMedicine(MedicineModel medicine) async {
    await _localDatasource.addMedicine(medicine);
  }

  @override
  Future<void> updateMedicine(MedicineModel medicine) async {
    await _localDatasource.updateMedicine(medicine);
  }

  @override
  Future<void> deleteMedicine(String id) async {
    await _localDatasource.deleteMedicine(id);
  }

  @override
  Future<List<MedicineModel>> searchMedicines(String query) async {
    return _localDatasource.searchMedicines(query);
  }

  @override
  Future<List<MedicineModel>> getMedicinesByCategory(String category) async {
    return _localDatasource.getMedicinesByCategory(category);
  }

  @override
  Future<List<MedicineModel>> getLowStockMedicines() async {
    return _localDatasource.getLowStockMedicines();
  }

  @override
  Future<List<MedicineModel>> getOutOfStockMedicines() async {
    return _localDatasource.getOutOfStockMedicines();
  }

  @override
  Future<List<MedicineModel>> getExpiredMedicines() async {
    return _localDatasource.getExpiredMedicines();
  }

  @override
  Future<List<MedicineModel>> getExpiringSoonMedicines({int days = 30}) async {
    return _localDatasource.getExpiringSoonMedicines(days: days);
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
  List<String> getAllManufacturers() {
    return _localDatasource.getAllManufacturers();
  }

  @override
  int get totalCount => _localDatasource.totalCount;

  @override
  double get totalStockValueAtCost => _localDatasource.totalStockValueAtCost;

  @override
  double get totalStockValueAtSale => _localDatasource.totalStockValueAtSale;

  @override
  double get potentialProfit => _localDatasource.potentialProfit;

  @override
  int get lowStockCount => _localDatasource.lowStockCount;

  @override
  int get expiredCount => _localDatasource.expiredCount;

  @override
  int get expiringSoonCount => _localDatasource.expiringSoonCount;
}
