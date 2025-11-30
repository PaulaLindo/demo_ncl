// test/unit/login_flow_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:demo_ncl/providers/auth_provider.dart';
import 'package:demo_ncl/services/mock_data_service.dart';
import 'package:demo_ncl/models/auth_model.dart';

void main() {
  group('Login Flow Tests', () {
    late AuthProvider authProvider;
    late MockDataService mockDataService;

    setUp(() {
      mockDataService = MockDataService();
      authProvider = AuthProvider(mockDataService);
    });

    tearDown(() {
      authProvider.dispose();
    });

    test('should authenticate customer with valid credentials', () async {
      // Act
      final result = await authProvider.login(
        email: 'customer@example.com',
        password: 'customer123',
      );

      // Assert
      expect(result, isTrue);
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.currentUser?.email, equals('customer@example.com'));
      expect(authProvider.currentUser?.role, equals(UserRole.customer));
      expect(authProvider.state, equals(AuthState.authenticated));
    });

    test('should authenticate staff with valid credentials', () async {
      // Act
      final result = await authProvider.login(
        email: 'staff@example.com',
        password: 'staff123',
      );

      // Assert
      expect(result, isTrue);
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.currentUser?.email, equals('staff@example.com'));
      expect(authProvider.currentUser?.role, equals(UserRole.staff));
      expect(authProvider.state, equals(AuthState.authenticated));
    });

    test('should authenticate admin with valid credentials', () async {
      // Act
      final result = await authProvider.login(
        email: 'admin@example.com',
        password: 'admin123',
      );

      // Assert
      expect(result, isTrue);
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.currentUser?.email, equals('admin@example.com'));
      expect(authProvider.currentUser?.role, equals(UserRole.admin));
      expect(authProvider.state, equals(AuthState.authenticated));
    });

    test('should reject invalid credentials', () async {
      // Act
      final result = await authProvider.login(
        email: 'customer@example.com',
        password: 'wrongpassword',
      );

      // Assert
      expect(result, isFalse);
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.currentUser, isNull);
      expect(authProvider.state, equals(AuthState.unauthenticated));
      expect(authProvider.errorMessage, isNotNull);
    });

    test('should reject non-existent user', () async {
      // Act
      final result = await authProvider.login(
        email: 'nonexistent@example.com',
        password: 'password123',
      );

      // Assert
      expect(result, isFalse);
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.currentUser, isNull);
      expect(authProvider.state, equals(AuthState.unauthenticated));
      expect(authProvider.errorMessage, isNotNull);
    });

    test('should handle logout correctly', () async {
      // Arrange - login first
      await authProvider.login(
        email: 'customer@example.com',
        password: 'customer123',
      );
      expect(authProvider.isAuthenticated, isTrue);

      // Act - logout
      await authProvider.logout();

      // Assert
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.currentUser, isNull);
      expect(authProvider.state, equals(AuthState.unauthenticated));
      expect(authProvider.errorMessage, isNull);
    });

    test('should handle multiple login attempts', () async {
      // First login attempt - valid
      await authProvider.login(
        email: 'customer@example.com',
        password: 'customer123',
      );
      expect(authProvider.isAuthenticated, isTrue);

      // Logout
      await authProvider.logout();
      expect(authProvider.isAuthenticated, isFalse);

      // Second login attempt - different user
      await authProvider.login(
        email: 'staff@example.com',
        password: 'staff123',
      );
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.currentUser?.email, equals('staff@example.com'));
      expect(authProvider.currentUser?.role, equals(UserRole.staff));

      // Third login attempt - invalid
      await authProvider.login(
        email: 'customer@example.com',
        password: 'wrongpassword',
      );
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.currentUser, isNull);
    });

    test('should handle edge cases', () async {
      // Empty email
      final result1 = await authProvider.login(
        email: '',
        password: 'customer123',
      );
      expect(result1, isFalse);
      expect(authProvider.state, equals(AuthState.unauthenticated));

      // Empty password
      final result2 = await authProvider.login(
        email: 'customer@example.com',
        password: '',
      );
      expect(result2, isFalse);
      expect(authProvider.state, equals(AuthState.unauthenticated));

      // Null credentials (would cause error in real app)
      try {
        await authProvider.login(email: 'test', password: '');
        // Should not reach here
        fail('Expected login to fail with empty password');
      } catch (e) {
        // Expected behavior
        expect(e, isA<Exception>());
      }
    });
  });
}
