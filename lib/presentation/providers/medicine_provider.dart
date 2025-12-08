import 'package:flutter/foundation.dart';

import '../../core/utils/uuid_generator.dart';
import '../../data/models/medicine_model.dart';
import '../../domain/repositories/medicine_repository.dart';

/// Provider for managing medicine state
/// 
/// Handles all medicine-related operations and state management.
/// Uses the repository pattern for data access.
class MedicineProvider with ChangeNotifier {
  final MedicineRepository _repository;

  List<MedicineModel> _medicines = [];
  MedicineModel? _selectedMedicine;
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  Set<String> _selectedCategories = {};
  String _stockFilter = 'All'; // All, LowStock, OutOfStock, InStock
  String _expiryFilter = 'All'; // All, Expired, ExpiringSoon, Valid
  String _sortBy = 'name'; // name, quantity, expiry, price

  MedicineProvider(this._repository) {
    loadMedicines();
  }

  // Getters
  List<MedicineModel> get medicines {
    var filtered = _medicines;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final lowerQuery = _searchQuery.toLowerCase();
      filtered = filtered.where((m) {
        return m.name.toLowerCase().contains(lowerQuery) ||
            m.genericName.toLowerCase().contains(lowerQuery) ||
            m.manufacturer.toLowerCase().contains(lowerQuery) ||
            m.batchNo.toLowerCase().contains(lowerQuery);
      }).toList();
    }

    // Apply category filter
    if (_selectedCategories.isNotEmpty) {
      filtered = filtered
          .where((m) => _selectedCategories.contains(m.category))
          .toList();
    }

    // Apply stock filter
    switch (_stockFilter) {
      case 'LowStock':
        filtered = filtered.where((m) => m.isLowStock && m.quantity > 0).toList();
        break;
      case 'OutOfStock':
        filtered = filtered.where((m) => m.quantity <= 0).toList();
        break;
      case 'InStock':
        filtered = filtered.where((m) => m.quantity > m.minStockLevel).toList();
        break;
    }

    // Apply expiry filter
    switch (_expiryFilter) {
      case 'Expired':
        filtered = filtered.where((m) => m.isExpired).toList();
        break;
      case 'ExpiringSoon':
        filtered = filtered.where((m) => m.isExpiringSoon).toList();
        break;
      case 'Valid':
        filtered = filtered.where((m) => !m.isExpired && !m.isExpiringSoon).toList();
        break;
    }

    return filtered;
  }

  List<MedicineModel> get allMedicines => _medicines;
  MedicineModel? get selectedMedicine => _selectedMedicine;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  Set<String> get selectedCategories => _selectedCategories;
  String get stockFilter => _stockFilter;
  String get expiryFilter => _expiryFilter;
  String get sortBy => _sortBy;

  int get totalCount => _repository.totalCount;
  double get totalStockValueAtCost => _repository.totalStockValueAtCost;
  double get totalStockValueAtSale => _repository.totalStockValueAtSale;
  double get potentialProfit => _repository.potentialProfit;
  int get lowStockCount => _repository.lowStockCount;
  int get expiredCount => _repository.expiredCount;
  int get expiringSoonCount => _repository.expiringSoonCount;
  List<String> get allCategories => _repository.getAllCategories();
  List<String> get allManufacturers => _repository.getAllManufacturers();

  /// Get low stock medicines
  List<MedicineModel> get lowStockMedicines =>
      _medicines.where((m) => m.isLowStock).toList();

  /// Get expired medicines
  List<MedicineModel> get expiredMedicines =>
      _medicines.where((m) => m.isExpired).toList();

  /// Get expiring soon medicines
  List<MedicineModel> get expiringSoonMedicines =>
      _medicines.where((m) => m.isExpiringSoon).toList();

  /// Load all medicines from repository
  Future<void> loadMedicines() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _medicines = await _repository.getAllMedicines();
      _error = null;
    } catch (e) {
      _error = 'Failed to load medicines: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new medicine
  Future<bool> addMedicine({
    required String name,
    required String genericName,
    required String category,
    String? image,
    required String batchNo,
    required DateTime mfgDate,
    required DateTime expiryDate,
    required String manufacturer,
    required double purchasePrice,
    required double sellingPrice,
    double discount = 0,
    required int quantity,
    required int minStockLevel,
    required String unit,
    String? storage,
    String? description,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final medicine = MedicineModel(
        id: UuidGenerator.generate(),
        name: name,
        genericName: genericName,
        category: category,
        image: image,
        batchNo: batchNo,
        mfgDate: mfgDate,
        expiryDate: expiryDate,
        manufacturer: manufacturer,
        purchasePrice: purchasePrice,
        sellingPrice: sellingPrice,
        discount: discount,
        quantity: quantity,
        minStockLevel: minStockLevel,
        unit: unit,
        storage: storage,
        description: description,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isSynced: false,
      );

      await _repository.addMedicine(medicine);
      await loadMedicines();
      return true;
    } catch (e) {
      _error = 'Failed to add medicine: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update an existing medicine
  Future<bool> updateMedicine(MedicineModel medicine) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateMedicine(medicine);
      await loadMedicines();
      
      if (_selectedMedicine?.id == medicine.id) {
        _selectedMedicine = medicine;
      }
      
      return true;
    } catch (e) {
      _error = 'Failed to update medicine: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete a medicine
  Future<bool> deleteMedicine(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteMedicine(id);
      await loadMedicines();
      
      if (_selectedMedicine?.id == id) {
        _selectedMedicine = null;
      }
      
      return true;
    } catch (e) {
      _error = 'Failed to delete medicine: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update medicine stock
  Future<bool> updateStock(String id, int quantity, {bool add = true}) async {
    try {
      await _repository.updateStock(id, quantity, add: add);
      await loadMedicines();
      return true;
    } catch (e) {
      _error = 'Failed to update stock: ${e.toString()}';
      return false;
    }
  }

  /// Deduct stock (for sales)
  Future<bool> deductStock(String id, int quantity) async {
    try {
      final success = await _repository.deductStock(id, quantity);
      if (success) {
        await loadMedicines();
      } else {
        _error = 'Insufficient stock';
      }
      return success;
    } catch (e) {
      _error = 'Failed to deduct stock: ${e.toString()}';
      return false;
    }
  }

  /// Select a medicine
  void selectMedicine(MedicineModel? medicine) {
    _selectedMedicine = medicine;
    notifyListeners();
  }

  /// Get medicine by ID
  Future<MedicineModel?> getMedicineById(String id) async {
    return _repository.getMedicineById(id);
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

  /// Set stock filter
  void setStockFilter(String filter) {
    _stockFilter = filter;
    notifyListeners();
  }

  /// Set expiry filter
  void setExpiryFilter(String filter) {
    _expiryFilter = filter;
    notifyListeners();
  }

  /// Set sort by
  void setSortBy(String sort) {
    _sortBy = sort;
    _sortMedicines();
    notifyListeners();
  }

  /// Sort medicines based on current sort setting
  void _sortMedicines() {
    switch (_sortBy) {
      case 'quantity':
        _medicines.sort((a, b) => a.quantity.compareTo(b.quantity));
        break;
      case 'expiry':
        _medicines.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
        break;
      case 'price':
        _medicines.sort((a, b) => a.sellingPrice.compareTo(b.sellingPrice));
        break;
      case 'name':
      default:
        _medicines.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
  }

  /// Clear filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCategories.clear();
    _stockFilter = 'All';
    _expiryFilter = 'All';
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Refresh medicines
  Future<void> refresh() async {
    await loadMedicines();
  }
}
