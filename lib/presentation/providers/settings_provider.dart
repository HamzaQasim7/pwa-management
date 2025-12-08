import 'package:flutter/foundation.dart';

import '../../core/database/hive_service.dart';
import '../../core/database/hive_boxes.dart';

/// Provider for managing app settings
/// 
/// Handles app preferences and settings stored locally.
class SettingsProvider with ChangeNotifier {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _autoSyncEnabled = true;
  String _language = 'en';
  String _currency = 'INR';
  bool _isFirstLaunch = true;

  SettingsProvider() {
    _loadSettings();
  }

  // Getters
  bool get isDarkMode => _isDarkMode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get autoSyncEnabled => _autoSyncEnabled;
  String get language => _language;
  String get currency => _currency;
  bool get isFirstLaunch => _isFirstLaunch;

  /// Load settings from local storage
  Future<void> _loadSettings() async {
    try {
      final box = HiveService.settingsBox;
      
      _isDarkMode = box.get(SettingsKeys.isDarkMode, defaultValue: false);
      _notificationsEnabled = box.get(SettingsKeys.notificationsEnabled, defaultValue: true);
      _autoSyncEnabled = box.get(SettingsKeys.autoSyncEnabled, defaultValue: true);
      _language = box.get(SettingsKeys.language, defaultValue: 'en');
      _currency = box.get(SettingsKeys.currency, defaultValue: 'INR');
      _isFirstLaunch = box.get(SettingsKeys.isFirstLaunch, defaultValue: true);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  /// Set dark mode
  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    await HiveService.settingsBox.put(SettingsKeys.isDarkMode, value);
    notifyListeners();
  }

  /// Toggle dark mode
  Future<void> toggleDarkMode() async {
    await setDarkMode(!_isDarkMode);
  }

  /// Set notifications enabled
  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    await HiveService.settingsBox.put(SettingsKeys.notificationsEnabled, value);
    notifyListeners();
  }

  /// Set auto sync enabled
  Future<void> setAutoSyncEnabled(bool value) async {
    _autoSyncEnabled = value;
    await HiveService.settingsBox.put(SettingsKeys.autoSyncEnabled, value);
    notifyListeners();
  }

  /// Set language
  Future<void> setLanguage(String value) async {
    _language = value;
    await HiveService.settingsBox.put(SettingsKeys.language, value);
    notifyListeners();
  }

  /// Set currency
  Future<void> setCurrency(String value) async {
    _currency = value;
    await HiveService.settingsBox.put(SettingsKeys.currency, value);
    notifyListeners();
  }

  /// Mark first launch as complete
  Future<void> completeFirstLaunch() async {
    _isFirstLaunch = false;
    await HiveService.settingsBox.put(SettingsKeys.isFirstLaunch, false);
    notifyListeners();
  }

  /// Reset all settings to defaults
  Future<void> resetSettings() async {
    _isDarkMode = false;
    _notificationsEnabled = true;
    _autoSyncEnabled = true;
    _language = 'en';
    _currency = 'INR';
    
    final box = HiveService.settingsBox;
    await box.put(SettingsKeys.isDarkMode, false);
    await box.put(SettingsKeys.notificationsEnabled, true);
    await box.put(SettingsKeys.autoSyncEnabled, true);
    await box.put(SettingsKeys.language, 'en');
    await box.put(SettingsKeys.currency, 'INR');
    
    notifyListeners();
  }

  /// Get currency symbol
  String get currencySymbol {
    switch (_currency) {
      case 'INR':
        return '₹';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      default:
        return '₹';
    }
  }

  /// Format currency amount
  String formatCurrency(double amount) {
    return '$currencySymbol ${amount.toStringAsFixed(2)}';
  }
}
