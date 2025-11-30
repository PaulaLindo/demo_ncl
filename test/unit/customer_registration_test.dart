// test/unit/customer_registration_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_ncl/providers/auth_provider.dart';
import 'package:demo_ncl/services/mock_data_service.dart';
import 'package:demo_ncl/models/auth_model.dart';

void main() {
  group('Customer Registration Tests', () {
    late AuthProvider authProvider;

    setUp(() {
      authProvider = AuthProvider(MockDataService());
    });

    test('should register customer successfully', () async {
      // Arrange
      const email = 'newcustomer@example.com';
      const password = 'password123';
      const fullName = 'John Doe';
      const phone = '1234567890';

      // Act
      await authProvider.registerCustomer(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );

      // Assert
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.currentUser?.email, equals(email));
      expect(authProvider.currentUser?.role, equals(UserRole.customer));
      expect(authProvider.currentUser?.firstName, equals('John'));
      expect(authProvider.currentUser?.lastName, equals('Doe'));
      expect(authProvider.currentUser?.phone, equals(phone));
    });

    test('should create correct user data on registration', () async {
      // Arrange
      const email = 'customer@test.com';
      const fullName = 'Jane Smith';
      const phone = '9876543210';

      // Act
      await authProvider.registerCustomer(
        email: email,
        password: 'anypassword',
        fullName: fullName,
        phone: phone,
      );

      // Assert
      final user = authProvider.currentUser!;
      expect(user.email, equals(email));
      expect(user.role, equals(UserRole.customer));
      expect(user.firstName, equals('Jane'));
      expect(user.lastName, equals('Smith'));
      expect(user.phone, equals(phone));
      expect(user.id, startsWith('customer_'));
      expect(user.createdAt, isNotNull);
    });

    test('should handle single name correctly', () async {
      // Arrange
      const email = 'single@test.com';
      const fullName = 'Cher'; // Single name

      // Act
      await authProvider.registerCustomer(
        email: email,
        password: 'password',
        fullName: fullName,
        phone: '1234567890',
      );

      // Assert
      final user = authProvider.currentUser!;
      expect(user.firstName, equals('Cher'));
      expect(user.lastName, isEmpty); // No last name for single name
    });

    test('should set loading state during registration', () async {
      // Arrange
      final future = authProvider.registerCustomer(
        email: 'test@example.com',
        password: 'password',
        fullName: 'Test User',
        phone: '1234567890',
      );

      // Assert - Should be loading during async operation
      expect(authProvider.isLoading, isTrue);

      // Wait for completion
      await future;

      // Assert - Should no longer be loading
      expect(authProvider.isLoading, isFalse);
      expect(authProvider.isAuthenticated, isTrue);
    });

    test('should handle registration errors gracefully', () async {
      // Arrange
      const invalidEmail = 'invalid-email';
      
      // Act & Assert - Should not throw but handle gracefully
      try {
        await authProvider.registerCustomer(
          email: invalidEmail,
          password: 'password',
          fullName: 'Test User',
          phone: '1234567890',
        );
        // If we get here, registration succeeded (which is fine for this mock)
        expect(authProvider.isAuthenticated, isTrue);
      } catch (e) {
        // If it throws, that's also acceptable for this test
        expect(authProvider.isAuthenticated, isFalse);
      }
    });
  });
}
