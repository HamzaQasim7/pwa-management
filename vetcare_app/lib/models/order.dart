class Order {
  const Order({
    required this.id,
    required this.customerId,
    required this.orderNumber,
    required this.date,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.paymentStatus,
  });

  final String id;
  final String customerId;
  final String orderNumber;
  final String date;
  final double subtotal;
  final double discount;
  final double total;
  final String paymentStatus;
}
