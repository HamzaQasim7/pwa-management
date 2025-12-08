import '../../data/models/medicine_model.dart';
import '../../models/medicine.dart';

/// Utility class for converting between new data models and legacy UI models
class ModelConverters {
  ModelConverters._();

  /// Convert MedicineModel (Hive) to Medicine (legacy UI)
  static Medicine medicineFromModel(MedicineModel model) {
    return Medicine(
      id: model.id,
      name: model.name,
      genericName: model.genericName,
      category: model.category,
      image: model.image ?? 'https://via.placeholder.com/150',
      batchNo: model.batchNo,
      mfgDate: _formatDate(model.mfgDate),
      expiryDate: _formatDate(model.expiryDate),
      manufacturer: model.manufacturer,
      purchasePrice: model.purchasePrice,
      sellingPrice: model.sellingPrice,
      discount: model.discount,
      quantity: model.quantity,
      minStockLevel: model.minStockLevel,
      unit: model.unit,
      storage: model.storage ?? '',
      description: model.description ?? '',
    );
  }

  /// Format DateTime to String for legacy models
  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Convert a list of MedicineModel to list of Medicine
  static List<Medicine> medicinesFromModels(List<MedicineModel> models) {
    return models.map(medicineFromModel).toList();
  }
}
