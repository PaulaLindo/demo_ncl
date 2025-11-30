// test/unit/auth_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_ncl/providers/auth_provider.dart';
import 'package:demo_ncl/services/mock_data_service.dart';
import 'package:demo_ncl/models/auth_model.dart';

void main() {
  group('AuthProvider Tests', () {
    late AuthProvider authProvider;
    late MockDataService mockDataService;

    setUp(() {
      mockDataService = MockDataService();
      authProvider = AuthProvider(mockDataService);
    });

    tearDown(() {
      authProvider.dispose();
    });

    test('should initialize in unauthenticated state', () {
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.currentUser, isNull);
      expect(authProvider.state, equals(AuthState.unauthenticated));
      expect(authProvider.errorMessage, isNull);
    });

    test('should login customer successfully', () async {
      final result = await authProvider.login(
        email: 'customer@example.com',
        password: 'customer123',
      );

      expect(result, isTrue);
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.currentUser?.email, equals('customer@example.com'));
      expect(authProvider.currentUser?.role, equals(UserRole.customer));
      expect(authProvider.currentUser?.password, isNull); // Password should be removed
      expect(authProvider.state, equals(AuthState.authenticated));
      expect(authProvider.errorMessage, isNull);
    });

    test('should login staff successfully', () async {
      final result = await authProvider.login(
        email: 'staff@example.com',
        password: 'staff123',
      );

      expect(result, isTrue);
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.currentUser?.email, equals('staff@example.com'));
      expect(authProvider.currentUser?.role, equals(UserRole.staff));
      expect(authProvider.currentUser?.password, isNull);
      expect(authProvider.state, equals(AuthState.authenticated));
      expect(authProvider.errorMessage, isNull);
    });

    test('should login admin successfully', () async {
      final result = await authProvider.login(
        email: 'admin@example.com',
        password: 'admin123',
      );

      expect(result, isTrue);
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.currentUser?.email, equals('admin@example.com'));
      expect(authProvider.currentUser?.role, equals(UserRole.admin));
      expect(authProvider.currentUser?.password, isNull);
      expect(authProvider.state, equals(AuthState.authenticated));
      expect(authProvider.errorMessage, isNull);
    });

    test('should fail login with invalid password', () async {
      final result = await authProvider.login(
        email: 'customer@example.com',
        password: 'wrongpassword',
      );

      expect(result, isFalse);
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.currentUser, isNull);
      expect(authProvider.state, equals(AuthState.unauthenticated));
      expect(authProvider.errorMessage, equals('Invalid credentials'));
    });

    test('should fail login with non-existent user', () async {
      final result = await authProvider.login(
        email: 'nonexistent@example.com',
        password: 'password123',
      );

      expect(result, isFalse);
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.currentUser, isNull);
      expect(authProvider.state, equals(AuthState.unauthenticated));
      expect(authProvider.errorMessage, equals('User not found'));
    });

    test('should logout successfully', () async {
      // First login
      await authProvider.login(
        email: 'customer@example.com',
        password: 'customer123',
      );
      
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.currentUser, isNotNull);

      // Then logout
      await authProvider.logout();

      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.currentUser, isNull);
      expect(authProvider.state, equals(AuthState.unauthenticated));
      expect(authProvider.errorMessage, isNull);
    });

    test('should handle multiple login attempts', () async {
      // First login attempt
      await authProvider.login(
        email: 'customer@example.com',
        password: 'customer123',
      );
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.currentUser?.email, equals('customer@example.com'));

      // Second login attempt (different user)
      await authProvider.login(
        email: 'admin@example.com',
        password: 'admin123',
      );
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.currentUser?.email, equals('admin@example.com'));
      expect(authProvider.currentUser?.role, equals(UserRole.admin));
    });

    test('should handle empty email', () async {
      final result = await authProvider.login(
        email: '',
        password: 'customer123',
      );

      expect(result, isFalse);
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.errorMessage, equals('User not found'));
    });

    test('should handle empty password', () async {
      final result = await authProvider.login(
        email: 'customer@example.com',
        password: '',
      );

      expect(result, isFalse);
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.errorMessage, equals('Invalid credentials'));
    });

    test('should handle null email', () async {
      final result = await authProvider.login(
        email: '',
        password: 'customer123',
      );

      expect(result, isFalse);
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.errorMessage, equals('User not found'));
    });

    test('should handle null password', () async {
      final result = await authProvider.login(
        email: 'customer@example.com',
        password: '',
      );

      expect(result, isFalse);
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.errorMessage, equals('Invalid credentials'));
    });
  });
}
