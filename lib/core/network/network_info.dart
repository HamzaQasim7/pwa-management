import 'package:connectivity_plus/connectivity_plus.dart';

/// Service for checking network connectivity
/// 
/// Provides methods to check if the device is connected to the internet
/// and to listen for connectivity changes.
class NetworkInfo {
  final Connectivity _connectivity;

  NetworkInfo({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  /// Check if device is connected to the internet
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return _isConnectedFromResults(result);
  }

  /// Stream of connectivity changes
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(_isConnectedFromResults);
  }

  /// Get current connectivity type
  Future<ConnectivityResult> get connectivityType async {
    final results = await _connectivity.checkConnectivity();
    return results.isNotEmpty ? results.first : ConnectivityResult.none;
  }

  /// Check if connected from connectivity results
  bool _isConnectedFromResults(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    return results.any((result) =>
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet);
  }

  /// Check if connected via WiFi
  Future<bool> get isConnectedViaWifi async {
    final results = await _connectivity.checkConnectivity();
    return results.contains(ConnectivityResult.wifi);
  }

  /// Check if connected via mobile data
  Future<bool> get isConnectedViaMobile async {
    final results = await _connectivity.checkConnectivity();
    return results.contains(ConnectivityResult.mobile);
  }
}

/// Singleton instance of NetworkInfo for easy access
final networkInfo = NetworkInfo();
