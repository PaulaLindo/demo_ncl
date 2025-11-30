// lib/providers/base_provider.dart
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import 'timekeeping_provider.dart';

abstract class BaseProvider with ChangeNotifier {
  final Logger _logger;
  final _retryDelays = [const Duration(seconds: 1), const Duration(seconds: 3), const Duration(seconds: 5)];
  final Map<String, dynamic> _cache = {};
  final Connectivity _connectivity = Connectivity();
  final List<StreamSubscription> _subscriptions = [];

  BaseProvider(Logger? logger) : _logger = logger ?? Logger('BaseProvider');
  
  /// Logger for subclasses to use
  Logger get logger => _logger;
  
  Timer? _debounceTimer;

  bool _isDisposed = false;
  bool _isConnected = true;
  bool _isLoading = false;

  String? _error;

  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  // Getters
  bool get isDisposed => _isDisposed;
  bool get isConnected => _isConnected;
  bool get isLoading => _isLoading;
  bool get hasError => _error != null;
  
  String? get error => _error;

  @protected
  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      _safeNotifyListeners();
    }
  }

  @protected
  void setError(String? error, {bool notify = true}) {
    _error = error;
    if (error != null) {
      _logger.severe(error);
    }
    if (notify) {
      _safeNotifyListeners();
    }
  }

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @protected
  Future<T> withRetry<T>(Future<T> Function() operation, {String? cacheKey, Duration? cacheDuration}) async {
    if (cacheKey != null && _cache.containsKey(cacheKey)) {
      return _cache[cacheKey] as T;
    }

    for (var i = 0; i < _retryDelays.length; i++) {
      try {
        final result = await operation();
        if (cacheKey != null) {
          _cache[cacheKey] = result;
          if (cacheDuration != null) {
            Future.delayed(cacheDuration, () => _cache.remove(cacheKey));
          }
        }
        return result;
      } catch (e) {
        if (i == _retryDelays.length - 1) rethrow;
        await Future.delayed(_retryDelays[i]);
      }
    }
    throw StateError('Unexpected error in withRetry');
  }

  @protected
  void debounce(Duration duration, VoidCallback callback) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(duration, () {
      if (!_isDisposed) callback();
    });
  }

  @protected
  Future<void> handleError(
    dynamic error, {
    StackTrace? stackTrace,
    bool notify = true,
  }) async {
    final errorMessage = error is Exception ? error.toString() : 'An unexpected error occurred';
    _logger.severe(errorMessage, error, stackTrace);
    setError(errorMessage, notify: notify);
  }

  @mustCallSuper
  @override
  void dispose() {
    _logger.fine('Disposing $runtimeType');
    _isDisposed = true;
    _debounceTimer?.cancel();
    // Only cancel if the subscription was initialized
    if (_connectivitySubscription != null) {
      _connectivitySubscription.cancel();
    }
    _cache.clear();
    super.dispose();
  }

  @protected
  void setupConnectivityListener() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((result) {
      final wasConnected = _isConnected;
      _isConnected = result != ConnectivityResult.none;
      
      if (!wasConnected && _isConnected) {
        // Reconnect and refresh data when connection is restored
        if (this is TimekeepingProvider) {
          (this as TimekeepingProvider).loadInitialData();
        }
        // AdminProvider refreshData() should be called in its own implementation
      }
    });
  }
}