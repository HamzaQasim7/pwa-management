import 'package:uuid/uuid.dart';

/// Utility class for generating UUIDs
/// 
/// This class provides methods for generating various types of unique identifiers
/// used throughout the application.
class UuidGenerator {
  static const Uuid _uuid = Uuid();

  UuidGenerator._();

  /// Generate a new UUID v4 (random)
  static String generate() => _uuid.v4();

  /// Generate a short ID (first 8 characters of UUID)
  static String generateShort() => _uuid.v4().substring(0, 8);

  /// Generate an order number with prefix
  static String generateOrderNumber(String prefix) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return '$prefix-${timestamp.substring(timestamp.length - 6)}';
  }

  /// Generate a bill number with prefix
  static String generateBillNumber(String prefix) {
    final now = DateTime.now();
    final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final random = generateShort().substring(0, 4).toUpperCase();
    return '$prefix-$dateStr-$random';
  }

  /// Generate a batch number
  static String generateBatchNumber(String productCode) {
    final now = DateTime.now();
    final yearMonth = '${now.year}${now.month.toString().padLeft(2, '0')}';
    final random = generateShort().substring(0, 3).toUpperCase();
    return '$productCode$yearMonth$random';
  }
}
