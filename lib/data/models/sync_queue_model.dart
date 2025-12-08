import 'package:hive/hive.dart';

part 'sync_queue_model.g.dart';

/// Sync action types
enum SyncAction {
  create,
  update,
  delete,
}

/// Entity types for sync queue
enum SyncEntityType {
  customer,
  feedProduct,
  medicine,
  order,
  sale,
}

/// Sync Queue model for tracking offline changes
/// 
/// This model tracks changes made offline that need to be synced
/// to Firebase when the device is back online.
@HiveType(typeId: 5)
class SyncQueueModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String entityId;

  @HiveField(2)
  String entityType; // customer, feedProduct, medicine, order, sale

  @HiveField(3)
  String action; // create, update, delete

  @HiveField(4)
  DateTime timestamp;

  @HiveField(5)
  int retryCount;

  @HiveField(6)
  String? lastError;

  @HiveField(7)
  Map<String, dynamic>? data;

  SyncQueueModel({
    required this.id,
    required this.entityId,
    required this.entityType,
    required this.action,
    required this.timestamp,
    this.retryCount = 0,
    this.lastError,
    this.data,
  });

  /// Whether max retries have been exceeded
  bool get hasExceededRetries => retryCount >= 5;

  /// Get the sync action enum
  SyncAction get syncAction {
    switch (action) {
      case 'create':
        return SyncAction.create;
      case 'update':
        return SyncAction.update;
      case 'delete':
        return SyncAction.delete;
      default:
        return SyncAction.update;
    }
  }

  /// Get the entity type enum
  SyncEntityType get syncEntityType {
    switch (entityType) {
      case 'customer':
        return SyncEntityType.customer;
      case 'feedProduct':
        return SyncEntityType.feedProduct;
      case 'medicine':
        return SyncEntityType.medicine;
      case 'order':
        return SyncEntityType.order;
      case 'sale':
        return SyncEntityType.sale;
      default:
        return SyncEntityType.customer;
    }
  }

  /// Create a copy with incremented retry count
  SyncQueueModel withRetry(String? error) {
    return SyncQueueModel(
      id: id,
      entityId: entityId,
      entityType: entityType,
      action: action,
      timestamp: timestamp,
      retryCount: retryCount + 1,
      lastError: error,
      data: data,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'entityId': entityId,
        'entityType': entityType,
        'action': action,
        'timestamp': timestamp.toIso8601String(),
        'retryCount': retryCount,
        'lastError': lastError,
        'data': data,
      };

  /// Create model from JSON
  factory SyncQueueModel.fromJson(Map<String, dynamic> json) => SyncQueueModel(
        id: json['id'] ?? '',
        entityId: json['entityId'] ?? '',
        entityType: json['entityType'] ?? '',
        action: json['action'] ?? 'update',
        timestamp: json['timestamp'] != null
            ? DateTime.parse(json['timestamp'])
            : DateTime.now(),
        retryCount: json['retryCount'] ?? 0,
        lastError: json['lastError'],
        data: json['data'] as Map<String, dynamic>?,
      );

  @override
  String toString() =>
      'SyncQueueModel(entityType: $entityType, entityId: $entityId, action: $action)';
}
