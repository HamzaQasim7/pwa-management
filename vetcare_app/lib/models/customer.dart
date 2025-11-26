class Customer {
  const Customer({
    required this.id,
    required this.name,
    required this.shopName,
    required this.phone,
    required this.address,
    required this.balance,
  });

  final String id;
  final String name;
  final String shopName;
  final String phone;
  final String address;
  final double balance;

  bool get isCredit => balance > 0;
}
