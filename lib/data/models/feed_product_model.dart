import 'package:hive/hive.dart';

part 'feed_product_model.g.dart';

/// Feed Product model for local Hive database storage
/// 
/// This model represents a feed product in the VetCare application.
/// It includes sync fields for offline-first architecture.
@HiveType(typeId: 1)
class FeedProductModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String category;

  @HiveField(3)
  String? image;

  @HiveField(4)
  String unit;

  @HiveField(5)
  int stock;

  @HiveField(6)
  int lowStockThreshold;

  @HiveField(7)
  double rate;

  @HiveField(8)
  String? supplier;

  @HiveField(9)
  String? description;

  @HiveField(10)
  DateTime createdAt;

  @HiveField(11)
  DateTime updatedAt;

  @HiveField(12)
  bool isSynced;

  @HiveField(13)
  String? firebaseId;

  @HiveField(14)
  double? purchasePrice;

  FeedProductModel({
    required this.id,
    required this.name,
    required this.category,
    this.image,
    required this.unit,
    required this.stock,
    required this.lowStockThreshold,
    required this.rate,
    this.supplier,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.firebaseId,
    this.purchasePrice,
  });

  /// Whether the product is low on stock
  bool get isLowStock => stock <= lowStockThreshold;

  /// Stock level as a percentage
  double get stockLevel =>
      stock / (lowStockThreshold * 2).clamp(1, 999).toDouble();

  /// Calculate profit margin if purchase price is available
  double? get margin => purchasePrice != null && purchasePrice! > 0
      ? ((rate - purchasePrice!) / purchasePrice!) * 100
      : null;

  /// Create a copy of this model with updated fields
  FeedProductModel copyWith({
    String? id,
    String? name,
    String? category,
    String? image,
    String? unit,
    int? stock,
    int? lowStockThreshold,
    double? rate,
    String? supplier,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    String? firebaseId,
    double? purchasePrice,
  }) {
    return FeedProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      image: image ?? this.image,
      unit: unit ?? this.unit,
      stock: stock ?? this.stock,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      rate: rate ?? this.rate,
      supplier: supplier ?? this.supplier,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      firebaseId: firebaseId ?? this.firebaseId,
      purchasePrice: purchasePrice ?? this.purchasePrice,
    );
  }

  /// Convert model to JSON for Firebase sync
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'image': image,
        'unit': unit,
        'stock': stock,
        'lowStockThreshold': lowStockThreshold,
        'rate': rate,
        'supplier': supplier,
        'description': description,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'firebaseId': firebaseId,
        'isSynced': isSynced,
        'purchasePrice': purchasePrice,
      };

  /// Create model from JSON (Firebase data)
  factory FeedProductModel.fromJson(Map<String, dynamic> json) =>
      FeedProductModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        category: json['category'] ?? '',
        image: json['image'],
        unit: json['unit'] ?? 'kg',
        stock: json['stock'] ?? 0,
        lowStockThreshold: json['lowStockThreshold'] ?? 10,
        rate: (json['rate'] ?? 0).toDouble(),
        supplier: json['supplier'],
        description: json['description'],
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'])
            : DateTime.now(),
        firebaseId: json['firebaseId'],
        isSynced: json['isSynced'] ?? false,
        purchasePrice: json['purchasePrice']?.toDouble(),
      );

  @override
  String toString() =>
      'FeedProductModel(id: $id, name: $name, stock: $stock)';
}
