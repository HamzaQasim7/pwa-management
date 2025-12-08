/// Box names for Hive database
/// 
/// These constants define the names of all Hive boxes used in the application.
/// Using constants prevents typos and makes refactoring easier.
class HiveBoxes {
  HiveBoxes._();

  /// Customer data box
  static const String customers = 'customers';

  /// Feed products data box
  static const String feedProducts = 'feed_products';

  /// Medicines data box
  static const String medicines = 'medicines';

  /// Orders data box
  static const String orders = 'orders';

  /// Sales data box
  static const String sales = 'sales';

  /// Sync queue box for offline changes
  static const String syncQueue = 'sync_queue';

  /// Settings box for app configuration
  static const String settings = 'settings';

  /// User preferences box
  static const String preferences = 'preferences';

  /// Cache box for temporary data
  static const String cache = 'cache';

  /// List of all box names for easy iteration
  static const List<String> allBoxes = [
    customers,
    feedProducts,
    medicines,
    orders,
    sales,
    syncQueue,
    settings,
    preferences,
    cache,
  ];
}

/// Settings keys for the settings box
class SettingsKeys {
  SettingsKeys._();

  static const String isDarkMode = 'is_dark_mode';
  static const String lastSyncTime = 'last_sync_time';
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
  static const String userName = 'user_name';
  static const String isFirstLaunch = 'is_first_launch';
  static const String autoSyncEnabled = 'auto_sync_enabled';
  static const String syncInterval = 'sync_interval';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String language = 'language';
  static const String currency = 'currency';
}
