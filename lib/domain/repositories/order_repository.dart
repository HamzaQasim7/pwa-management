import '../../data/models/order_model.dart';

/// Abstract repository interface for Order operations
/// 
/// This defines the contract for order data operations.
/// Implementations can be swapped for testing or different data sources.
abstract class OrderRepository {
  /// Get all orders
  Future<List<OrderModel>> getAllOrders();

  /// Get an order by ID
  Future<OrderModel?> getOrderById(String id);

  /// Get order by order number
  Future<OrderModel?> getOrderByNumber(String orderNumber);

  /// Add a new order
  Future<void> addOrder(OrderModel order);

  /// Update an existing order
  Future<void> updateOrder(OrderModel order);

  /// Delete an order
  Future<void> deleteOrder(String id);

  /// Get orders by customer
  Future<List<OrderModel>> getOrdersByCustomer(String customerId);

  /// Get orders by type (feed or medicine)
  Future<List<OrderModel>> getOrdersByType(String orderType);

  /// Get orders by payment status
  Future<List<OrderModel>> getOrdersByPaymentStatus(String status);

  /// Get orders by date range
  Future<List<OrderModel>> getOrdersByDateRange(DateTime start, DateTime end);

  /// Get today's orders
  Future<List<OrderModel>> getTodaysOrders();

  /// Get pending orders
  Future<List<OrderModel>> getPendingOrders();

  /// Update payment status
  Future<void> updatePaymentStatus(String id, String status, {double? paidAmount});

  /// Record payment
  Future<void> recordPayment(String id, double amount);

  /// Search orders
  Future<List<OrderModel>> searchOrders(String query);

  /// Generate next order number
  String generateOrderNumber(String type);

  /// Get total number of orders
  int get totalCount;

  /// Get total revenue
  double get totalRevenue;

  /// Get total pending amount
  double get totalPending;

  /// Get today's revenue
  double get todaysRevenue;
}
