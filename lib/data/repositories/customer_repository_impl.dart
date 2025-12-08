import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_local_datasource.dart';
import '../models/customer_model.dart';

/// Implementation of CustomerRepository using local datasource
/// 
/// This implementation follows the offline-first pattern:
/// - All operations work with local Hive database first
/// - Changes are queued for sync automatically by the datasource
class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerLocalDatasource _localDatasource;

  CustomerRepositoryImpl(this._localDatasource);

  @override
  Future<List<CustomerModel>> getAllCustomers() async {
    return _localDatasource.getAllCustomers();
  }

  @override
  Future<CustomerModel?> getCustomerById(String id) async {
    return _localDatasource.getCustomerById(id);
  }

  @override
  Future<void> addCustomer(CustomerModel customer) async {
    await _localDatasource.addCustomer(customer);
  }

  @override
  Future<void> updateCustomer(CustomerModel customer) async {
    await _localDatasource.updateCustomer(customer);
  }

  @override
  Future<void> deleteCustomer(String id) async {
    await _localDatasource.deleteCustomer(id);
  }

  @override
  Future<List<CustomerModel>> searchCustomers(String query) async {
    return _localDatasource.searchCustomers(query);
  }

  @override
  Future<List<CustomerModel>> getCustomersByType(String type) async {
    return _localDatasource.getCustomersByType(type);
  }

  @override
  Future<List<CustomerModel>> getCustomersWithCredit() async {
    return _localDatasource.getCustomersWithCredit();
  }

  @override
  Future<List<CustomerModel>> getCustomersWithDebt() async {
    return _localDatasource.getCustomersWithDebt();
  }

  @override
  Future<void> updateBalance(String id, double amount) async {
    await _localDatasource.updateBalance(id, amount);
  }

  @override
  int get totalCount => _localDatasource.totalCount;

  @override
  double get totalCredit => _localDatasource.totalCredit;

  @override
  double get totalDebt => _localDatasource.totalDebt;
}
