import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service to monitor network connectivity
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  
  StreamController<bool> _connectionStatusController = StreamController<bool>.broadcast();
  
  Stream<bool> get connectionStatus => _connectionStatusController.stream;
  
  bool _isConnected = false;
  bool get isConnected => _isConnected;
  
  ConnectivityService() {
    _initConnectivity();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }
  
  Future<void> _initConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
    } catch (e) {
      _isConnected = false;
      _connectionStatusController.add(false);
    }
  }
  
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final wasConnected = _isConnected;
    _isConnected = results.any((result) => 
      result == ConnectivityResult.mobile || 
      result == ConnectivityResult.wifi ||
      result == ConnectivityResult.ethernet
    );
    
    if (wasConnected != _isConnected) {
      _connectionStatusController.add(_isConnected);
    }
  }
  
  Future<bool> checkConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.any((result) => 
        result == ConnectivityResult.mobile || 
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet
      );
    } catch (e) {
      return false;
    }
  }
  
  void dispose() {
    _connectionStatusController.close();
  }
}
