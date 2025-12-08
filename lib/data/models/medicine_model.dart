import 'package:hive/hive.dart';

part 'medicine_model.g.dart';

/// Medicine model for local Hive database storage
/// 
/// This model represents a medicine product in the VetCare application.
/// It includes sync fields for offline-first architecture.
@HiveType(typeId: 2)
class MedicineModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String genericName;

  @HiveField(3)
  String category;

  @HiveField(4)
  String? image;

  @HiveField(5)
  String batchNo;

  @HiveField(6)
  DateTime mfgDate;

  @HiveField(7)
  DateTime expiryDate;

  @HiveField(8)
  String manufacturer;

  @HiveField(9)
  double purchasePrice;

  @HiveField(10)
  double sellingPrice;

  @HiveField(11)
  double discount;

  @HiveField(12)
  int quantity;

  @HiveField(13)
  int minStockLevel;

  @HiveField(14)
  String unit;

  @HiveField(15)
  String? storage;

  @HiveField(16)
  String? description;

  @HiveField(17)
  DateTime createdAt;

  @HiveField(18)
  DateTime updatedAt;

  @HiveField(19)
  bool isSynced;

  @HiveField(20)
  String? firebaseId;

  MedicineModel({
    required this.id,
    required this.name,
    required this.genericName,
    required this.category,
    this.image,
    required this.batchNo,
    required this.mfgDate,
    required this.expiryDate,
    required this.manufacturer,
    required this.purchasePrice,
    required this.sellingPrice,
    this.discount = 0,
    required this.quantity,
    required this.minStockLevel,
    required this.unit,
    this.storage,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.firebaseId,
  });

  /// Calculate profit margin percentage
  double get margin =>
      purchasePrice > 0 ? ((sellingPrice - purchasePrice) / purchasePrice) * 100 : 0;

  /// Whether the medicine is low on stock
  bool get isLowStock => quantity <= minStockLevel;

  /// Whether the medicine is expired
  bool get isExpired => expiryDate.isBefore(DateTime.now());

  /// Whether the medicine is expiring soon (within 30 days)
  bool get isExpiringSoon {
    final daysUntilExpiry = expiryDate.difference(DateTime.now()).inDays;
    return daysUntilExpiry > 0 && daysUntilExpiry <= 30;
  }

  /// Days until expiry
  int get daysUntilExpiry => expiryDate.difference(DateTime.now()).inDays;

  /// Create a copy of this model with updated fields
  MedicineModel copyWith({
    String? id,
    String? name,
    String? genericName,
    String? category,
    String? image,
    String? batchNo,
    DateTime? mfgDate,
    DateTime? expiryDate,
    String? manufacturer,
    double? purchasePrice,
    double? sellingPrice,
    double? discount,
    int? quantity,
    int? minStockLevel,
    String? unit,
    String? storage,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    String? firebaseId,
  }) {
    return MedicineModel(
      id: id ?? this.id,
      name: name ?? this.name,
      genericName: genericName ?? this.genericName,
      category: category ?? this.category,
      image: image ?? this.image,
      batchNo: batchNo ?? this.batchNo,
      mfgDate: mfgDate ?? this.mfgDate,
      expiryDate: expiryDate ?? this.expiryDate,
      manufacturer: manufacturer ?? this.manufacturer,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      discount: discount ?? this.discount,
      quantity: quantity ?? this.quantity,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      unit: unit ?? this.unit,
      storage: storage ?? this.storage,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      firebaseId: firebaseId ?? this.firebaseId,
    );
  }

  /// Convert model to JSON for Firebase sync
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'genericName': genericName,
        'category': category,
        'image': image,
        'batchNo': batchNo,
        'mfgDate': mfgDate.toIso8601String(),
        'expiryDate': expiryDate.toIso8601String(),
        'manufacturer': manufacturer,
        'purchasePrice': purchasePrice,
        'sellingPrice': sellingPrice,
        'discount': discount,
        'quantity': quantity,
        'minStockLevel': minStockLevel,
        'unit': unit,
        'storage': storage,
        'description': description,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'firebaseId': firebaseId,
        'isSynced': isSynced,
      };

  /// Create model from JSON (Firebase data)
  factory MedicineModel.fromJson(Map<String, dynamic> json) => MedicineModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        genericName: json['genericName'] ?? '',
        category: json['category'] ?? '',
        image: json['image'],
        batchNo: json['batchNo'] ?? '',
        mfgDate: json['mfgDate'] != null
            ? DateTime.parse(json['mfgDate'])
            : DateTime.now(),
        expiryDate: json['expiryDate'] != null
            ? DateTime.parse(json['expiryDate'])
            : DateTime.now().add(const Duration(days: 365)),
        manufacturer: json['manufacturer'] ?? '',
        purchasePrice: (json['purchasePrice'] ?? 0).toDouble(),
        sellingPrice: (json['sellingPrice'] ?? 0).toDouble(),
        discount: (json['discount'] ?? 0).toDouble(),
        quantity: json['quantity'] ?? 0,
        minStockLevel: json['minStockLevel'] ?? 10,
        unit: json['unit'] ?? 'units',
        storage: json['storage'],
        description: json['description'],
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'])
            : DateTime.now(),
        firebaseId: json['firebaseId'],
        isSynced: json['isSynced'] ?? false,
      );

  @override
  String toString() =>
      'MedicineModel(id: $id, name: $name, quantity: $quantity)';
}
