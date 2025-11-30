// test/unit/auth_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_ncl/models/auth_model.dart';
import 'package:demo_ncl/services/mock_data_service.dart';
import 'package:demo_ncl/providers/auth_provider.dart';

void main() {
  group('Auth Model Tests', () {
    test('should create AuthUser with required fields', () {
      // Arrange
      const user = AuthUser(
        id: '1',
        email: 'test@example.com',
        role: UserRole.customer,
        firstName: 'John',
        password: 'password123',
      );

      // Assert
      expect(user.id, equals('1'));
      expect(user.email, equals('test@example.com'));
      expect(user.role, equals(UserRole.customer));
      expect(user.firstName, equals('John'));
      expect(user.password, equals('password123'));
    });

    test('should get full name correctly', () {
      // Arrange
      const user = AuthUser(
        id: '1',
        email: 'test@example.com',
        role: UserRole.customer,
        firstName: 'John',
        lastName: 'Doe',
      );

      // Assert
      expect(user.fullName, equals('John Doe'));
      expect(user.name, equals('John Doe'));
    });

    test('should handle single name correctly', () {
      // Arrange
      const user = AuthUser(
        id: '1',
        email: 'test@example.com',
        role: UserRole.customer,
        firstName: 'John',
      );

      // Assert
      expect(user.fullName, equals('John'));
      expect(user.name, equals('John'));
    });

    test('should check user roles correctly', () {
      // Arrange & Assert
      const customer = AuthUser(
        id: '1',
        email: 'customer@example.com',
        role: UserRole.customer,
        firstName: 'Customer',
      );
      expect(customer.role.isCustomer, isTrue);
      expect(customer.role.isStaff, isFalse);
      expect(customer.role.isAdmin, isFalse);

      const staff = AuthUser(
        id: '2',
        email: 'staff@example.com',
        role: UserRole.staff,
        firstName: 'Staff',
      );
      expect(staff.role.isCustomer, isFalse);
      expect(staff.role.isStaff, isTrue);
      expect(staff.role.isAdmin, isFalse);

      const admin = AuthUser(
        id: '3',
        email: 'admin@example.com',
        role: UserRole.admin,
        firstName: 'Admin',
      );
      expect(admin.role.isCustomer, isFalse);
      expect(admin.role.isStaff, isFalse);
      expect(admin.role.isAdmin, isTrue);
    });
  });

  group('AuthResult Tests', () {
    test('should create success result', () {
      // Arrange
      const user = AuthUser(
        id: '1',
        email: 'test@example.com',
        role: UserRole.customer,
        firstName: 'Test',
      );
      final result = AuthResult.success(user);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.user, equals(user));
      expect(result.error, isNull);
    });

    test('should create failure result', () {
      // Arrange
      const errorMessage = 'Invalid credentials';
      final result = AuthResult.failure(errorMessage);

      // Assert
      expect(result.isSuccess, isFalse);
      expect(result.user, isNull);
      expect(result.error, equals(errorMessage));
    });

    test('should fold result correctly', () {
      // Arrange
      const user = AuthUser(
        id: '1',
        email: 'test@example.com',
        role: UserRole.customer,
        firstName: 'Test',
      );
      final successResult = AuthResult.success(user);
      final failureResult = AuthResult.failure('Error');

      // Assert success
      final successValue = successResult.fold(
        (error) => 'failure',
        (user) => 'success',
      );
      expect(successValue, equals('success'));

      // Assert failure
      final failureValue = failureResult.fold(
        (error) => 'failure',
        (user) => 'success',
      );
      expect(failureValue, equals('failure'));
    });
  });

  group('MockDataService Auth Tests', () {
    late MockDataService mockDataService;

    setUp(() {
      mockDataService = MockDataService();
    });

    test('should authenticate valid customer credentials', () async {
      // Act
      final result = await mockDataService.authenticateUser(
        'customer@example.com',
        'customer123',
      );

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.user?.email, equals('customer@example.com'));
      expect(result.user?.role, equals(UserRole.customer));
      expect(result.user?.password, isNull); // Password should be removed
    });

    test('should authenticate valid staff credentials', () async {
      // Act
      final result = await mockDataService.authenticateUser(
        'staff@example.com',
        'staff123',
      );

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.user?.email, equals('staff@example.com'));
      expect(result.user?.role, equals(UserRole.staff));
      expect(result.user?.password, isNull); // Password should be removed
    });

    test('should authenticate valid admin credentials', () async {
      // Act
      final result = await mockDataService.authenticateUser(
        'admin@example.com',
        'admin123',
      );

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.user?.email, equals('admin@example.com'));
      expect(result.user?.role, equals(UserRole.admin));
      expect(result.user?.password, isNull); // Password should be removed
    });

    test('should fail with invalid email', () async {
      // Act
      final result = await mockDataService.authenticateUser(
        'nonexistent@example.com',
        'password123',
      );

      // Assert
      expect(result.isSuccess, isFalse);
      expect(result.user, isNull);
      expect(result.error, equals('User not found'));
    });

    test('should fail with invalid password', () async {
      // Act
      final result = await mockDataService.authenticateUser(
        'customer@example.com',
        'wrongpassword',
      );

      // Assert
      expect(result.isSuccess, isFalse);
      expect(result.user, isNull);
      expect(result.error, equals('Invalid credentials'));
    });

    test('should fail with empty credentials', () async {
      // Act
      final result = await mockDataService.authenticateUser('', '');

      // Assert
      expect(result.isSuccess, isFalse);
      expect(result.user, isNull);
      expect(result.error, equals('User not found'));
    });
  });

  group('AuthProvider Tests', () {
    late AuthProvider authProvider;

    setUp(() {
      authProvider = AuthProvider();
    });

    tearDown(() {
      authProvider.dispose();
    });

    test('should start in unauthenticated state', () {
      // Assert
      expect(authProvider.state, equals(AuthState.unauthenticated));
      expect(authProvider.currentUser, isNull);
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.isLoading, isFalse);
    });

    test('should login customer successfully', () async {
      // Act
      final result = await authProvider.login(
        email: 'customer@example.com',
        password: 'customer123',
      );

      // Assert
      expect(result, isTrue);
      expect(authProvider.state, equals(AuthState.authenticated));
      expect(authProvider.currentUser?.email, equals('customer@example.com'));
      expect(authProvider.currentUser?.role, equals(UserRole.customer));
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.errorMessage, isNull);
    });

    test('should login staff successfully', () async {
      // Act
      final result = await authProvider.login(
        email: 'staff@example.com',
        password: 'staff123',
      );

      // Assert
      expect(result, isTrue);
      expect(authProvider.state, equals(AuthState.authenticated));
      expect(authProvider.currentUser?.email, equals('staff@example.com'));
      expect(authProvider.currentUser?.role, equals(UserRole.staff));
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.errorMessage, isNull);
    });

    test('should login admin successfully', () async {
      // Act
      final result = await authProvider.login(
        email: 'admin@example.com',
        password: 'admin123',
      );

      // Assert
      expect(result, isTrue);
      expect(authProvider.state, equals(AuthState.authenticated));
      expect(authProvider.currentUser?.email, equals('admin@example.com'));
      expect(authProvider.currentUser?.role, equals(UserRole.admin));
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.errorMessage, isNull);
    });

    test('should fail login with invalid credentials', () async {
      // Act
      final result = await authProvider.login(
        email: 'customer@example.com',
        password: 'wrongpassword',
      );

      // Assert
      expect(result, isFalse);
      expect(authProvider.state, equals(AuthState.unauthenticated));
      expect(authProvider.currentUser, isNull);
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.errorMessage, equals('Invalid credentials'));
    });

    test('should logout successfully', () async {
      // Arrange - login first
      await authProvider.login(
        email: 'customer@example.com',
        password: 'customer123',
      );
      expect(authProvider.isAuthenticated, isTrue);

      // Act - logout
      await authProvider.logout();

      // Assert
      expect(authProvider.state, equals(AuthState.unauthenticated));
      expect(authProvider.currentUser, isNull);
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.errorMessage, isNull);
    });

    test('should handle loading state during login', () async {
      // Start login and check loading state
      final loginFuture = authProvider.login(
        email: 'customer@example.com',
        password: 'customer123',
      );

      // Note: In real tests, you might need to add delays to check loading state
      // For now, we'll just check the final state
      final result = await loginFuture;

      // Assert
      expect(result, isTrue);
      expect(authProvider.state, equals(AuthState.authenticated));
      expect(authProvider.isLoading, isFalse);
    });
  });
}
