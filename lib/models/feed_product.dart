class FeedProduct {
  const FeedProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.image,
    required this.unit,
    required this.stock,
    required this.lowStockThreshold,
    required this.rate,
  });

  final String id;
  final String name;
  final String category;
  final String image;
  final String unit;
  final int stock;
  final int lowStockThreshold;
  final double rate;

  bool get isLowStock => stock <= lowStockThreshold;
  double get stockLevel =>
      stock / (lowStockThreshold * 2).clamp(1, 999).toDouble();
}
