import 'package:hive/hive.dart';

part 'order_model.g.dart';

/// Order Item model for storing individual items in an order
@HiveType(typeId: 6)
class OrderItemModel {
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

  OrderItemModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.rate,
    this.discount = 0,
    required this.total,
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productName': productName,
        'quantity': quantity,
        'rate': rate,
        'discount': discount,
        'total': total,
      };

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
        productId: json['productId'] ?? '',
        productName: json['productName'] ?? '',
        quantity: json['quantity'] ?? 0,
        rate: (json['rate'] ?? 0).toDouble(),
        discount: (json['discount'] ?? 0).toDouble(),
        total: (json['total'] ?? 0).toDouble(),
      );
}

/// Order model for local Hive database storage
/// 
/// This model represents an order in the VetCare application.
/// It includes sync fields for offline-first architecture.
@HiveType(typeId: 3)
class OrderModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String customerId;

  @HiveField(2)
  String? customerName;

  @HiveField(3)
  String orderNumber;

  @HiveField(4)
  DateTime date;

  @HiveField(5)
  double subtotal;

  @HiveField(6)
  double discount;

  @HiveField(7)
  double total;

  @HiveField(8)
  String paymentStatus;

  @HiveField(9)
  String orderType; // 'feed' or 'medicine'

  @HiveField(10)
  List<OrderItemModel> items;

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

  @HiveField(16)
  double? paidAmount;

  OrderModel({
    required this.id,
    required this.customerId,
    this.customerName,
    required this.orderNumber,
    required this.date,
    required this.subtotal,
    this.discount = 0,
    required this.total,
    this.paymentStatus = 'Pending',
    required this.orderType,
    this.items = const [],
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.firebaseId,
    this.paidAmount,
  });

  /// Whether the order is fully paid
  bool get isPaid => paymentStatus == 'Paid';

  /// Whether the order is partially paid
  bool get isPartiallyPaid => paymentStatus == 'Partially Paid';

  /// Whether the order is pending payment
  bool get isPending => paymentStatus == 'Pending';

  /// Calculate remaining amount
  double get remainingAmount => total - (paidAmount ?? 0);

  /// Create a copy of this model with updated fields
  OrderModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? orderNumber,
    DateTime? date,
    double? subtotal,
    double? discount,
    double? total,
    String? paymentStatus,
    String? orderType,
    List<OrderItemModel>? items,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    String? firebaseId,
    double? paidAmount,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      orderNumber: orderNumber ?? this.orderNumber,
      date: date ?? this.date,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      orderType: orderType ?? this.orderType,
      items: items ?? this.items,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      firebaseId: firebaseId ?? this.firebaseId,
      paidAmount: paidAmount ?? this.paidAmount,
    );
  }

  /// Convert model to JSON for Firebase sync
  Map<String, dynamic> toJson() => {
        'id': id,
        'customerId': customerId,
        'customerName': customerName,
        'orderNumber': orderNumber,
        'date': date.toIso8601String(),
        'subtotal': subtotal,
        'discount': discount,
        'total': total,
        'paymentStatus': paymentStatus,
        'orderType': orderType,
        'items': items.map((item) => item.toJson()).toList(),
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'firebaseId': firebaseId,
        'isSynced': isSynced,
        'paidAmount': paidAmount,
      };

  /// Create model from JSON (Firebase data)
  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json['id'] ?? '',
        customerId: json['customerId'] ?? '',
        customerName: json['customerName'],
        orderNumber: json['orderNumber'] ?? '',
        date: json['date'] != null
            ? DateTime.parse(json['date'])
            : DateTime.now(),
        subtotal: (json['subtotal'] ?? 0).toDouble(),
        discount: (json['discount'] ?? 0).toDouble(),
        total: (json['total'] ?? 0).toDouble(),
        paymentStatus: json['paymentStatus'] ?? 'Pending',
        orderType: json['orderType'] ?? 'feed',
        items: (json['items'] as List<dynamic>?)
                ?.map((item) =>
                    OrderItemModel.fromJson(item as Map<String, dynamic>))
                .toList() ??
            [],
        notes: json['notes'],
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'])
            : DateTime.now(),
        firebaseId: json['firebaseId'],
        isSynced: json['isSynced'] ?? false,
        paidAmount: json['paidAmount']?.toDouble(),
      );

  @override
  String toString() =>
      'OrderModel(id: $id, orderNumber: $orderNumber, total: $total)';
}
