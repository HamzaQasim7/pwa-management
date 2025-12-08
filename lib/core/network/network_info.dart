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
    return _isConnectedFromResult(result);
  }

  /// Stream of connectivity changes
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(_isConnectedFromResult);
  }

  /// Get current connectivity type
  Future<ConnectivityResult> get connectivityType async {
    return await _connectivity.checkConnectivity();
  }

  /// Check if connected from connectivity result
  bool _isConnectedFromResult(ConnectivityResult result) {
    return result != ConnectivityResult.none &&
        result != ConnectivityResult.bluetooth &&
        result != ConnectivityResult.other;
  }

  /// Check if connected via WiFi
  Future<bool> get isConnectedViaWifi async {
    final result = await _connectivity.checkConnectivity();
    return result == ConnectivityResult.wifi;
  }

  /// Check if connected via mobile data
  Future<bool> get isConnectedViaMobile async {
    final result = await _connectivity.checkConnectivity();
    return result == ConnectivityResult.mobile;
  }
}

/// Singleton instance of NetworkInfo for easy access
final networkInfo = NetworkInfo();
