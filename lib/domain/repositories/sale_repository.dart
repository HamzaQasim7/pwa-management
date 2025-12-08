import '../../data/models/sale_model.dart';

/// Abstract repository interface for Sale operations
/// 
/// This defines the contract for medicine sale data operations.
/// Implementations can be swapped for testing or different data sources.
abstract class SaleRepository {
  /// Get all sales
  Future<List<SaleModel>> getAllSales();

  /// Get a sale by ID
  Future<SaleModel?> getSaleById(String id);

  /// Get sale by bill number
  Future<SaleModel?> getSaleByBillNumber(String billNumber);

  /// Add a new sale
  Future<void> addSale(SaleModel sale);

  /// Update an existing sale
  Future<void> updateSale(SaleModel sale);

  /// Delete a sale
  Future<void> deleteSale(String id);

  /// Get sales by customer
  Future<List<SaleModel>> getSalesByCustomer(String customerId);

  /// Get sales by date range
  Future<List<SaleModel>> getSalesByDateRange(DateTime start, DateTime end);

  /// Get today's sales
  Future<List<SaleModel>> getTodaysSales();

  /// Get sales by payment method
  Future<List<SaleModel>> getSalesByPaymentMethod(String method);

  /// Search sales
  Future<List<SaleModel>> searchSales(String query);

  /// Generate next bill number
  String generateBillNumber();

  /// Get total number of sales
  int get totalCount;

  /// Get total revenue
  double get totalRevenue;

  /// Get total profit
  double get totalProfit;

  /// Get total discount given
  double get totalDiscount;

  /// Get today's revenue
  double get todaysRevenue;

  /// Get today's profit
  double get todaysProfit;

  /// Get today's sales count
  int get todaysSalesCount;

  /// Get average profit margin
  double get averageProfitMargin;
}
