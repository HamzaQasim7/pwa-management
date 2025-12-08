import 'package:hive/hive.dart';

part 'sale_model.g.dart';

/// Sale Item model for storing individual items in a sale
@HiveType(typeId: 7)
class SaleItemModel {
  @HiveField(0)
  String productId;

  @HiveField(1)
  String productName;

  @HiveField(2)
  int quantity;

  @HiveField(3)
  double rate;

  @HiveField(4)
  double discount;

  @HiveField(5)
  double total;

  @HiveField(6)
  double? purchasePrice;

  SaleItemModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.rate,
    this.discount = 0,
    required this.total,
    this.purchasePrice,
  });

  /// Calculate profit for this item
  double get profit => purchasePrice != null
      ? total - (purchasePrice! * quantity)
      : 0;

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productName': productName,
        'quantity': quantity,
        'rate': rate,
        'discount': discount,
        'total': total,
        'purchasePrice': purchasePrice,
      };

  factory SaleItemModel.fromJson(Map<String, dynamic> json) => SaleItemModel(
        productId: json['productId'] ?? '',
        productName: json['productName'] ?? '',
        quantity: json['quantity'] ?? 0,
        rate: (json['rate'] ?? 0).toDouble(),
        discount: (json['discount'] ?? 0).toDouble(),
        total: (json['total'] ?? 0).toDouble(),
        purchasePrice: json['purchasePrice']?.toDouble(),
      );
}

/// Sale model for local Hive database storage
/// 
/// This model represents a medicine sale in the VetCare application.
/// It includes sync fields for offline-first architecture.
@HiveType(typeId: 4)
class SaleModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String billNumber;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  double subtotal;

  @HiveField(4)
  double discount;

  @HiveField(5)
  double total;

  @HiveField(6)
  double profit;

  @HiveField(7)
  String? customerId;

  @HiveField(8)
  String? customerName;

  @HiveField(9)
  List<SaleItemModel> items;

  @HiveField(10)
  String paymentMethod;

  @HiveField(11)
  String? notes;

  @HiveField(12)
  DateTime createdAt;

  @HiveField(13)
  DateTime updatedAt;

  @HiveField(14)
  bool isSynced;

  @HiveField(15)
  String? firebaseId;

  SaleModel({
    required this.id,
    required this.billNumber,
    required this.date,
    required this.subtotal,
    this.discount = 0,
    required this.total,
    this.profit = 0,
    this.customerId,
    this.customerName,
    this.items = const [],
    this.paymentMethod = 'Cash',
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.firebaseId,
  });

  /// Calculate profit margin percentage
  double get profitMargin => total > 0 ? (profit / total) * 100 : 0;

  /// Create a copy of this model with updated fields
  SaleModel copyWith({
    String? id,
    String? billNumber,
    DateTime? date,
    double? subtotal,
    double? discount,
    double? total,
    double? profit,
    String? customerId,
    String? customerName,
    List<SaleItemModel>? items,
    String? paymentMethod,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    String? firebaseId,
  }) {
    return SaleModel(
      id: id ?? this.id,
      billNumber: billNumber ?? this.billNumber,
      date: date ?? this.date,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      profit: profit ?? this.profit,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      items: items ?? this.items,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      firebaseId: firebaseId ?? this.firebaseId,
    );
  }

  /// Convert model to JSON for Firebase sync
  Map<String, dynamic> toJson() => {
        'id': id,
        'billNumber': billNumber,
        'date': date.toIso8601String(),
        'subtotal': subtotal,
        'discount': discount,
        'total': total,
        'profit': profit,
        'customerId': customerId,
        'customerName': customerName,
        'items': items.map((item) => item.toJson()).toList(),
        'paymentMethod': paymentMethod,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'firebaseId': firebaseId,
        'isSynced': isSynced,
      };

  /// Create model from JSON (Firebase data)
  factory SaleModel.fromJson(Map<String, dynamic> json) => SaleModel(
        id: json['id'] ?? '',
        billNumber: json['billNumber'] ?? '',
        date: json['date'] != null
            ? DateTime.parse(json['date'])
            : DateTime.now(),
        subtotal: (json['subtotal'] ?? 0).toDouble(),
        discount: (json['discount'] ?? 0).toDouble(),
        total: (json['total'] ?? 0).toDouble(),
        profit: (json['profit'] ?? 0).toDouble(),
        customerId: json['customerId'],
        customerName: json['customerName'],
        items: (json['items'] as List<dynamic>?)
                ?.map((item) =>
                    SaleItemModel.fromJson(item as Map<String, dynamic>))
                .toList() ??
            [],
        paymentMethod: json['paymentMethod'] ?? 'Cash',
        notes: json['notes'],
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
      'SaleModel(id: $id, billNumber: $billNumber, total: $total)';
}
