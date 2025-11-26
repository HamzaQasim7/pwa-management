class Sale {
  const Sale({
    required this.id,
    required this.billNumber,
    required this.date,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.profit,
  });

  final String id;
  final String billNumber;
  final String date;
  final double subtotal;
  final double discount;
  final double total;
  final double profit;
}
