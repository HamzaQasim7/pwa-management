import '../../data/models/customer_model.dart';

/// Abstract repository interface for Customer operations
/// 
/// This defines the contract for customer data operations.
/// Implementations can be swapped for testing or different data sources.
abstract class CustomerRepository {
  /// Get all customers
  Future<List<CustomerModel>> getAllCustomers();

  /// Get a customer by ID
  Future<CustomerModel?> getCustomerById(String id);

  /// Add a new customer
  Future<void> addCustomer(CustomerModel customer);

  /// Update an existing customer
  Future<void> updateCustomer(CustomerModel customer);

  /// Delete a customer
  Future<void> deleteCustomer(String id);

  /// Search customers by query
  Future<List<CustomerModel>> searchCustomers(String query);

  /// Get customers by type
  Future<List<CustomerModel>> getCustomersByType(String type);

  /// Get customers with positive balance
  Future<List<CustomerModel>> getCustomersWithCredit();

  /// Get customers with negative balance
  Future<List<CustomerModel>> getCustomersWithDebt();

  /// Update customer balance
  Future<void> updateBalance(String id, double amount);

  /// Get total number of customers
  int get totalCount;

  /// Get total credit amount
  double get totalCredit;

  /// Get total debt amount
  double get totalDebt;
}
