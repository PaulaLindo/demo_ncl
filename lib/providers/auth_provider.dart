// lib/providers/auth_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../models/auth_model.dart';

import '../services/mock_data_service.dart';

/// Represents the authentication state of the application
enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// Manages authentication state and operations
class AuthProvider extends ChangeNotifier {
  final MockDataService _mockDataService;
  final Logger _logger = Logger('AuthProvider');

  AuthUser? _currentUser;
  AuthState _state = AuthState.unauthenticated;
  String? _errorMessage;
  StreamSubscription<AuthState>? _authStateSubscription;

  AuthProvider([MockDataService? mockDataService]) 
    : _mockDataService = mockDataService ?? MockDataService() {
    _initialize();
  }

  // Getters
  AuthUser? get currentUser => _currentUser;
  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isLoading => _state == AuthState.loading;

  /// Initializes the auth provider
  Future<void> _initialize() async {
    try {
      _state = AuthState.initial;
      // Check for existing session or token here if needed
      _state = AuthState.unauthenticated;
    } catch (error, stackTrace) {
      _handleError('Initialization failed', error, stackTrace);
    }
  }

  /// Handles user login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    if (_state == AuthState.loading) return false;

    try {
      print(' AuthProvider.login() called with email: $email');
      _updateState(AuthState.loading);
      print(' AuthProvider state set to loading');
      
      final result = await _mockDataService.authenticateUser(email, password);
      print(' AuthProvider authentication result received: ${result.isSuccess ? 'SUCCESS' : 'FAILURE'}');
      
      return result.fold(
        (failure) {
          print(' AuthProvider login failed: $failure');
          _handleAuthFailure(failure);
          return false;
        },
        (user) {
          print(' AuthProvider login successful for user: ${user.email}');
          _currentUser = user;
          _updateState(AuthState.authenticated);
          print(' AuthProvider state set to authenticated');
          print(' AuthProvider.isAuthenticated: ${isAuthenticated}');
          _logger.info('User logged in: ${user.email}');
          return true;
        },
      );
    } catch (error, stackTrace) {
      print(' AuthProvider login error: $error');
      _handleError('Login failed', error, stackTrace);
      return false;
    }
  }

  /// Handles user logout
  Future<void> logout() async {
    try {
      _updateState(AuthState.loading);
      
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 300));
      
      _currentUser = null;
      _errorMessage = null; // Clear any error messages
      _updateState(AuthState.unauthenticated);
      _logger.info('User logged out');
    } catch (error, stackTrace) {
      _handleError('Logout failed', error, stackTrace);
    }
  }

  /// Handles customer registration
  Future<void> registerCustomer({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    if (_state == AuthState.loading) return;

    try {
      _updateState(AuthState.loading);
      
      // Simulate registration process
      await Future.delayed(const Duration(seconds: 1));
      
      // Create new customer user
      final newUser = AuthUser(
        id: 'customer_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        role: UserRole.customer,
        firstName: fullName.split(' ').first,
        lastName: fullName.split(' ').length > 1 ? fullName.split(' ').last : '',
        phone: phone,
        createdAt: DateTime.now(),
      );

      // Simulate successful registration
      _currentUser = newUser;
      _updateState(AuthState.authenticated);
      _logger.info('Customer registered: ${newUser.email}');
    } catch (error, stackTrace) {
      _handleError('Registration failed', error, stackTrace);
      rethrow; // Re-throw to allow UI to handle the error
    }
  }

  /// Updates the authentication state
  void _updateState(AuthState newState, {String? errorMessage}) {
    if (_state != newState) {
      _state = newState;
      _errorMessage = errorMessage;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Handles authentication errors
  void _handleError(String message, [Object? error, StackTrace? stackTrace]) {
    _errorMessage = message;
    _updateState(AuthState.error, errorMessage: message);
    _logger.severe(message, error, stackTrace);
  }

  /// Handles authentication failures (invalid credentials, user not found)
  void _handleAuthFailure(String message) {
    _errorMessage = message;
    _currentUser = null; // Clear current user on auth failure
    _updateState(AuthState.unauthenticated, errorMessage: message);
    _logger.info('Authentication failed: $message');
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  // Methods for tests compatibility
  bool get hasError => _errorMessage != null;
  bool get isLoggedIn => isAuthenticated;
  
  void setUser(AuthUser user) {
    _currentUser = user;
    _updateState(AuthState.authenticated);
  }
  
  void setLoading(bool loading) {
    _updateState(loading ? AuthState.loading : AuthState.unauthenticated);
  }
  
  void setError(String error) {
    _handleError(error);
  }
}