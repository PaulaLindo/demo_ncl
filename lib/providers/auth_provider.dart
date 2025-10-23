// lib/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../models/job_service_models.dart';

/// Authentication state
enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// Manages authentication state across the app
/// Single source of truth for current user and auth status
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  User? _currentUser;
  AuthState _state = AuthState.initial;
  String? _errorMessage;
  bool _isInitialized = false;

  AuthProvider(this._authService);

  // --- Getters ---

  User? get currentUser => _currentUser;
  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;

  bool get isAuthenticated => 
      _state == AuthState.authenticated && _currentUser != null;
  
  bool get isLoading => _state == AuthState.loading;
  
  bool get isStaff => _currentUser?.isStaff ?? false;
  
  bool get isCustomer => 
      _currentUser != null && !_currentUser!.isStaff;

  // --- Public Methods ---

  /// Initialize authentication state from storage
  /// Should be called once when app starts
  Future<void> initialize() async {
    if (_isInitialized) return;

    _setState(AuthState.loading);

    try {
      _currentUser = await _authService.getCurrentUser();
      
      if (_currentUser != null) {
        _setState(AuthState.authenticated);
      } else {
        _setState(AuthState.unauthenticated);
      }
    } catch (e) {
      _setError('Failed to initialize authentication');
      _setState(AuthState.error);
    } finally {
      _isInitialized = true;
    }
  }

  /// Login with credentials
  /// Returns true if successful, false otherwise
  Future<bool> login({
    required String identifier,
    required String secret,
    required bool isStaffAttempt,
  }) async {
    // Clear previous errors
    _clearError();
    _setState(AuthState.loading);

    try {
      final result = await _authService.login(
        identifier: identifier.trim(),
        secret: secret.trim(),
        isStaffAttempt: isStaffAttempt,
      );

      if (result.success && result.user != null) {
        _currentUser = result.user;
        _setState(AuthState.authenticated);
        return true;
      } else {
        _setError(result.errorMessage ?? 'Login failed');
        _setState(AuthState.unauthenticated);
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred');
      _setState(AuthState.error);
      return false;
    }
  }

  /// Logout current user
  Future<void> logout() async {
    _setState(AuthState.loading);

    try {
      await _authService.logout();
      _currentUser = null;
      _clearError();
      _setState(AuthState.unauthenticated);
    } catch (e) {
      _setError('Failed to logout');
      _setState(AuthState.error);
    }
  }

  /// Refresh user data from storage
  Future<void> refreshUser() async {
    try {
      await _authService.refreshUser();
      _currentUser = await _authService.getCurrentUser();
      
      if (_currentUser != null) {
        _setState(AuthState.authenticated);
      } else {
        _setState(AuthState.unauthenticated);
      }
    } catch (e) {
      _setError('Failed to refresh user data');
    }
  }

  /// Clear error message
  void clearError() {
    _clearError();
  }

  /// Update user profile (for future use)
  Future<void> updateUser(User updatedUser) async {
    _currentUser = updatedUser;
    notifyListeners();
    // In production, save to backend and storage
  }

  // --- Private Methods ---

  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}