import 'package:hive/hive.dart';

part 'customer_model.g.dart';

/// Customer model for local Hive database storage
/// 
/// This model represents a customer in the VetCare application.
/// It includes sync fields for offline-first architecture.
@HiveType(typeId: 0)
class CustomerModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String phone;

  @HiveField(3)
  String? email;

  @HiveField(4)
  String? shopName;

  @HiveField(5)
  String? address;

  @HiveField(6)
  double balance;

  @HiveField(7)
  String customerType;

  @HiveField(8)
  DateTime createdAt;

  @HiveField(9)
  DateTime updatedAt;

  @HiveField(10)
  bool isSynced;

  @HiveField(11)
  String? firebaseId;

  @HiveField(12)
  String? notes;

  @HiveField(13)
  String? city;

  @HiveField(14)
  String? area;

  @HiveField(15)
  double? creditLimit;

  CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.shopName,
    this.address,
    this.balance = 0.0,
    this.customerType = 'Retail',
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.firebaseId,
    this.notes,
    this.city,
    this.area,
    this.creditLimit,
  });

  /// Whether the customer has a positive balance (credit)
  bool get isCredit => balance > 0;

  /// Whether the customer has a negative balance (debt)
  bool get isDebt => balance < 0;

  /// Create a copy of this model with updated fields
  CustomerModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? shopName,
    String? address,
    double? balance,
    String? customerType,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    String? firebaseId,
    String? notes,
    String? city,
    String? area,
    double? creditLimit,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      shopName: shopName ?? this.shopName,
      address: address ?? this.address,
      balance: balance ?? this.balance,
      customerType: customerType ?? this.customerType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      firebaseId: firebaseId ?? this.firebaseId,
      notes: notes ?? this.notes,
      city: city ?? this.city,
      area: area ?? this.area,
      creditLimit: creditLimit ?? this.creditLimit,
    );
  }

  /// Convert model to JSON for Firebase sync
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'shopName': shopName,
        'address': address,
        'balance': balance,
        'customerType': customerType,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'firebaseId': firebaseId,
        'isSynced': isSynced,
        'notes': notes,
        'city': city,
        'area': area,
        'creditLimit': creditLimit,
      };

  /// Create model from JSON (Firebase data)
  factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        phone: json['phone'] ?? '',
        email: json['email'],
        shopName: json['shopName'],
        address: json['address'],
        balance: (json['balance'] ?? 0).toDouble(),
        customerType: json['customerType'] ?? 'Retail',
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'])
            : DateTime.now(),
        firebaseId: json['firebaseId'],
        isSynced: json['isSynced'] ?? false,
        notes: json['notes'],
        city: json['city'],
        area: json['area'],
        creditLimit: json['creditLimit']?.toDouble(),
      );

  @override
  String toString() => 'CustomerModel(id: $id, name: $name, phone: $phone)';
}
