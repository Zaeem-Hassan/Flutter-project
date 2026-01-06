import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  bool _isOnline = true;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool get isOnline => _isOnline;

  ConnectivityService() {
    _init();
  }

  void _init() async {
    // Check initial connectivity
    final results = await _connectivity.checkConnectivity();
    _updateConnectionStatus(results);

    // Listen for changes
    _subscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final wasOnline = _isOnline;
    _isOnline = results.isNotEmpty && 
                !results.contains(ConnectivityResult.none);
    
    if (wasOnline != _isOnline) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
