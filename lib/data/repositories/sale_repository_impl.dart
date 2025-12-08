import '../../domain/repositories/sale_repository.dart';
import '../datasources/sale_local_datasource.dart';
import '../models/sale_model.dart';

/// Implementation of SaleRepository using local datasource
/// 
/// This implementation follows the offline-first pattern:
/// - All operations work with local Hive database first
/// - Changes are queued for sync automatically by the datasource
class SaleRepositoryImpl implements SaleRepository {
  final SaleLocalDatasource _localDatasource;

  SaleRepositoryImpl(this._localDatasource);

  @override
  Future<List<SaleModel>> getAllSales() async {
    return _localDatasource.getAllSales();
  }

  @override
  Future<SaleModel?> getSaleById(String id) async {
    return _localDatasource.getSaleById(id);
  }

  @override
  Future<SaleModel?> getSaleByBillNumber(String billNumber) async {
    return _localDatasource.getSaleByBillNumber(billNumber);
  }

  @override
  Future<void> addSale(SaleModel sale) async {
    await _localDatasource.addSale(sale);
  }

  @override
  Future<void> updateSale(SaleModel sale) async {
    await _localDatasource.updateSale(sale);
  }

  @override
  Future<void> deleteSale(String id) async {
    await _localDatasource.deleteSale(id);
  }

  @override
  Future<List<SaleModel>> getSalesByCustomer(String customerId) async {
    return _localDatasource.getSalesByCustomer(customerId);
  }

  @override
  Future<List<SaleModel>> getSalesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    return _localDatasource.getSalesByDateRange(start, end);
  }

  @override
  Future<List<SaleModel>> getTodaysSales() async {
    return _localDatasource.getTodaysSales();
  }

  @override
  Future<List<SaleModel>> getSalesByPaymentMethod(String method) async {
    return _localDatasource.getSalesByPaymentMethod(method);
  }

  @override
  Future<List<SaleModel>> searchSales(String query) async {
    return _localDatasource.searchSales(query);
  }

  @override
  String generateBillNumber() {
    return _localDatasource.generateBillNumber();
  }

  @override
  int get totalCount => _localDatasource.totalCount;

  @override
  double get totalRevenue => _localDatasource.totalRevenue;

  @override
  double get totalProfit => _localDatasource.totalProfit;

  @override
  double get totalDiscount => _localDatasource.totalDiscount;

  @override
  double get todaysRevenue => _localDatasource.todaysRevenue;

  @override
  double get todaysProfit => _localDatasource.todaysProfit;

  @override
  int get todaysSalesCount => _localDatasource.todaysSalesCount;

  @override
  double get averageProfitMargin => _localDatasource.averageProfitMargin;
}
