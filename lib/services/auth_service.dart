// lib/services/auth_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/job_service_models.dart';

/// Mock credentials for development
/// TODO: Replace with actual API calls in production
class MockCredentials {
  static final Map<String, Map<String, dynamic>> credentials = {
    // Customer Accounts
    'user@example.com': {
      'id': 'cust001',
      'name': 'Customer User',
      'email': 'user@example.com',
      'isStaff': false,
      'password': 'password',
    },
    'john.doe@example.com': {
      'id': 'cust002',
      'name': 'John Doe',
      'email': 'john.doe@example.com',
      'isStaff': false,
      'password': 'password123',
    },
    // Staff Accounts
    'staff001': {
      'id': 'staff001',
      'name': 'Sarah Mitchell',
      'email': 'sarah.mitchell@ncl.com',
      'isStaff': true,
      'pin': '1234',
    },
    'staff002': {
      'id': 'staff002',
      'name': 'David Johnson',
      'email': 'david.johnson@ncl.com',
      'isStaff': true,
      'pin': '4321',
    },
  };
}

/// Result of an authentication attempt
class AuthResult {
  final User? user;
  final String? errorMessage;
  final bool success;

  const AuthResult({
    this.user,
    this.errorMessage,
    required this.success,
  });

  factory AuthResult.success(User user) {
    return AuthResult(user: user, success: true);
  }

  factory AuthResult.failure(String errorMessage) {
    return AuthResult(errorMessage: errorMessage, success: false);
  }
}

/// Handles authentication and session management
/// Manages persistent storage with SharedPreferences
class AuthService {
  static const String _userKey = 'ncl_current_user';
  static const String _sessionKey = 'ncl_session_token';

  User? _cachedUser;

  /// Get the currently logged in user
  /// Returns null if no user is logged in
  Future<User?> getCurrentUser() async {
    // Return cached user if available
    if (_cachedUser != null) return _cachedUser;

    // Try to load from persistent storage
    await _loadUserFromStorage();
    return _cachedUser;
  }

  /// Synchronous getter for cached user
  /// Use only when you know user is already loaded
  User? get currentUserSync => _cachedUser;

  /// Check if a user is currently logged in
  Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  /// Authenticate a user with identifier and secret
  /// 
  /// For staff: identifier is staff ID, secret is PIN
  /// For customers: identifier is email, secret is password
  Future<AuthResult> login({
    required String identifier,
    required String secret,
    required bool isStaffAttempt,
  }) async {
    // Validate inputs
    if (identifier.trim().isEmpty || secret.trim().isEmpty) {
      return AuthResult.failure('Please provide all credentials');
    }

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      // Get mock credentials (in production, this would be an API call)
      final creds = MockCredentials.credentials[identifier];

      if (creds == null) {
        return AuthResult.failure(
          isStaffAttempt 
            ? 'Invalid Staff ID' 
            : 'Email not found'
        );
      }

      User? user;

      // Validate based on account type
      if (isStaffAttempt) {
        if (creds['isStaff'] == true && creds['pin'] == secret) {
          user = User(
            id: creds['id'] as String,
            name: creds['name'] as String,
            isStaff: true,
            email: creds['email'] as String?,
          );
        } else {
          return AuthResult.failure('Invalid PIN');
        }
      } else {
        if (creds['isStaff'] == false && creds['password'] == secret) {
          user = User(
            id: creds['id'] as String,
            name: creds['name'] as String,
            isStaff: false,
            email: creds['email'] as String?,
          );
          // Note: The logic in login_screen.dart already validates the password length.
          // This service mock only checks against the stored password.
        } else {
          return AuthResult.failure('Invalid password');
        }
      }

      await _setCurrentUser(user);
      return AuthResult.success(user);
    
      return AuthResult.failure('Authentication failed');
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred');
    }
  }

  /// Log out the current user
  /// Clears session and cached data
  Future<void> logout() async {
    _cachedUser = null;
    await _clearUserFromStorage();
  }

  /// Refresh user data from storage
  /// Useful after app resume or data changes
  Future<void> refreshUser() async {
    await _loadUserFromStorage();
  }

  // --- Static Validation Methods (THE FIX) ---

  /// Validates an email address using a simple regex.
  static bool isValidEmail(String? email) {
    if (email == null || email.isEmpty) return false;
    // A simple regex for email validation
    // The validation in login_screen.dart ensures non-empty, but this is defensive.
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email.trim());
  }

  /// Validates a 4-digit PIN.
  static bool isValidPin(String? pin) {
    if (pin == null || pin.length != 4) return false;
    // Checks if the string consists only of 4 digits
    final digitRegex = RegExp(r'^\d{4}$');
    return digitRegex.hasMatch(pin);
  }

  // --- Private Methods ---

  /// Set the current user and save to storage
  Future<void> _setCurrentUser(User user) async {
    _cachedUser = user;
    await _saveUserToStorage(user);
  }

  /// Load user from SharedPreferences
  Future<void> _loadUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);

      if (userJson != null) {
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        _cachedUser = User.fromJson(userMap);
      } else {
        _cachedUser = null;
      }
    } catch (e) {
      // Log error in production
      print('Error loading user from storage: $e');
      _cachedUser = null;
    }
  }

  /// Save user to SharedPreferences
  Future<void> _saveUserToStorage(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = json.encode(user.toJson());
      await prefs.setString(_userKey, userJson);
    } catch (e) {
      print('Error saving user to storage: $e');
    }
  }

  /// Clear user from SharedPreferences
  Future<void> _clearUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.remove(_sessionKey);
    } catch (e) {
      print('Error clearing user from storage: $e');
    }
  }
}