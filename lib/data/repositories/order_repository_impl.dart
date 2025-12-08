import '../../domain/repositories/order_repository.dart';
import '../datasources/order_local_datasource.dart';
import '../models/order_model.dart';

/// Implementation of OrderRepository using local datasource
/// 
/// This implementation follows the offline-first pattern:
/// - All operations work with local Hive database first
/// - Changes are queued for sync automatically by the datasource
class OrderRepositoryImpl implements OrderRepository {
  final OrderLocalDatasource _localDatasource;

  OrderRepositoryImpl(this._localDatasource);

  @override
  Future<List<OrderModel>> getAllOrders() async {
    return _localDatasource.getAllOrders();
  }

  @override
  Future<OrderModel?> getOrderById(String id) async {
    return _localDatasource.getOrderById(id);
  }

  @override
  Future<OrderModel?> getOrderByNumber(String orderNumber) async {
    return _localDatasource.getOrderByNumber(orderNumber);
  }

  @override
  Future<void> addOrder(OrderModel order) async {
    await _localDatasource.addOrder(order);
  }

  @override
  Future<void> updateOrder(OrderModel order) async {
    await _localDatasource.updateOrder(order);
  }

  @override
  Future<void> deleteOrder(String id) async {
    await _localDatasource.deleteOrder(id);
  }

  @override
  Future<List<OrderModel>> getOrdersByCustomer(String customerId) async {
    return _localDatasource.getOrdersByCustomer(customerId);
  }

  @override
  Future<List<OrderModel>> getOrdersByType(String orderType) async {
    return _localDatasource.getOrdersByType(orderType);
  }

  @override
  Future<List<OrderModel>> getOrdersByPaymentStatus(String status) async {
    return _localDatasource.getOrdersByPaymentStatus(status);
  }

  @override
  Future<List<OrderModel>> getOrdersByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    return _localDatasource.getOrdersByDateRange(start, end);
  }

  @override
  Future<List<OrderModel>> getTodaysOrders() async {
    return _localDatasource.getTodaysOrders();
  }

  @override
  Future<List<OrderModel>> getPendingOrders() async {
    return _localDatasource.getPendingOrders();
  }

  @override
  Future<void> updatePaymentStatus(
    String id,
    String status, {
    double? paidAmount,
  }) async {
    await _localDatasource.updatePaymentStatus(id, status, paidAmount: paidAmount);
  }

  @override
  Future<void> recordPayment(String id, double amount) async {
    await _localDatasource.recordPayment(id, amount);
  }

  @override
  Future<List<OrderModel>> searchOrders(String query) async {
    return _localDatasource.searchOrders(query);
  }

  @override
  String generateOrderNumber(String type) {
    return _localDatasource.generateOrderNumber(type);
  }

  @override
  int get totalCount => _localDatasource.totalCount;

  @override
  double get totalRevenue => _localDatasource.totalRevenue;

  @override
  double get totalPending => _localDatasource.totalPending;

  @override
  double get todaysRevenue => _localDatasource.todaysRevenue;
}
