class Medicine {
  const Medicine({
    required this.id,
    required this.name,
    required this.genericName,
    required this.category,
    required this.image,
    required this.batchNo,
    required this.mfgDate,
    required this.expiryDate,
    required this.manufacturer,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.discount,
    required this.quantity,
    required this.minStockLevel,
    required this.unit,
    required this.storage,
    required this.description,
  });

  final String id;
  final String name;
  final String genericName;
  final String category;
  final String image;
  final String batchNo;
  final String mfgDate;
  final String expiryDate;
  final String manufacturer;
  final double purchasePrice;
  final double sellingPrice;
  final double discount;
  final int quantity;
  final int minStockLevel;
  final String unit;
  final String storage;
  final String description;

  double get margin => ((sellingPrice - purchasePrice) / purchasePrice) * 100;
  bool get isLowStock => quantity <= minStockLevel;
}
