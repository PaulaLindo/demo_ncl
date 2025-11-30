// test/unit/auth_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_ncl/models/auth_model.dart';

void main() {
  group('AuthModel Tests', () {
    group('UserRole Tests', () {
      test('should have correct enum values', () {
        expect(UserRole.admin.value, 'admin');
        expect(UserRole.staff.value, 'staff');
        expect(UserRole.customer.value, 'customer');
      });

      test('should create UserRole from string', () {
        expect(UserRole.fromString('admin'), UserRole.admin);
        expect(UserRole.fromString('staff'), UserRole.staff);
        expect(UserRole.fromString('customer'), UserRole.customer);
        expect(UserRole.fromString('invalid'), UserRole.customer); // Default
      });

      test('should check role privileges', () {
        expect(UserRole.admin.isAdmin, true);
        expect(UserRole.admin.isStaff, false);
        expect(UserRole.admin.isCustomer, false);

        expect(UserRole.staff.isAdmin, false);
        expect(UserRole.staff.isStaff, true);
        expect(UserRole.staff.isCustomer, false);

        expect(UserRole.customer.isAdmin, false);
        expect(UserRole.customer.isStaff, false);
        expect(UserRole.customer.isCustomer, true);
      });

      test('should handle UserRole toString', () {
        expect(UserRole.admin.toString(), 'UserRole.admin');
        expect(UserRole.staff.toString(), 'UserRole.staff');
        expect(UserRole.customer.toString(), 'UserRole.customer');
      });
    });

    group('AuthUser Tests', () {
      test('should create AuthUser with required fields', () {
        final user = AuthUser(
          id: 'user-123',
          email: 'test@example.com',
          firstName: 'Test',
          role: UserRole.customer,
        );

        expect(user.id, 'user-123');
        expect(user.email, 'test@example.com');
        expect(user.firstName, 'Test');
        expect(user.lastName, isNull);
        expect(user.role, UserRole.customer);
        expect(user.phone, isNull);
        expect(user.createdAt, isNull);
        expect(user.password, isNull);
      });

      test('should create AuthUser with all fields', () {
        final now = DateTime.now();
        final user = AuthUser(
          id: 'user-123',
          email: 'test@example.com',
          firstName: 'Test',
          lastName: 'User',
          role: UserRole.staff,
          phone: '+1234567890',
          createdAt: now,
          password: 'hashedPassword',
        );

        expect(user.id, 'user-123');
        expect(user.email, 'test@example.com');
        expect(user.firstName, 'Test');
        expect(user.lastName, 'User');
        expect(user.role, UserRole.staff);
        expect(user.phone, '+1234567890');
        expect(user.createdAt, now);
        expect(user.password, 'hashedPassword');
      });

      test('should get full name', () {
        final user = AuthUser(
          id: 'user-123',
          email: 'test@example.com',
          firstName: 'John',
          lastName: 'Doe',
          role: UserRole.customer,
        );

        expect(user.fullName, 'John Doe');
      });

      test('should get full name when lastName is null', () {
        final user = AuthUser(
          id: 'user-123',
          email: 'test@example.com',
          firstName: 'John',
          role: UserRole.customer,
        );

        expect(user.fullName, 'John');
      });

      test('should get name alias', () {
        final user = AuthUser(
          id: 'user-123',
          email: 'test@example.com',
          firstName: 'John',
          lastName: 'Doe',
          role: UserRole.customer,
        );

        expect(user.name, 'John Doe');
      });

      test('should create AuthUser from JSON', () {
        final json = {
          'id': 'user-123',
          'email': 'test@example.com',
          'firstName': 'John',
          'lastName': 'Doe',
          'role': 'staff',
          'phone': '+1234567890',
          'createdAt': '2024-01-15T10:30:00Z',
          'password': 'hashedPassword',
        };

        final user = AuthUser.fromJson(json);

        expect(user.id, 'user-123');
        expect(user.email, 'test@example.com');
        expect(user.firstName, 'John');
        expect(user.lastName, 'Doe');
        expect(user.role, UserRole.staff);
        expect(user.phone, '+1234567890');
        expect(user.createdAt, DateTime.parse('2024-01-15T10:30:00Z'));
        expect(user.password, 'hashedPassword');
      });

      test('should create AuthUser from JSON with UserRole enum', () {
        final json = {
          'id': 'user-123',
          'email': 'test@example.com',
          'firstName': 'John',
          'role': UserRole.staff, // Direct enum
        };

        final user = AuthUser.fromJson(json);

        expect(user.role, UserRole.staff);
      });

      test('should convert AuthUser to JSON', () {
        final user = AuthUser(
          id: 'user-123',
          email: 'test@example.com',
          firstName: 'John',
          lastName: 'Doe',
          role: UserRole.staff,
          phone: '+1234567890',
          createdAt: DateTime.parse('2024-01-15T10:30:00Z'),
          password: 'hashedPassword',
        );

        final json = user.toJson();

        expect(json['id'], 'user-123');
        expect(json['email'], 'test@example.com');
        expect(json['firstName'], 'John');
        expect(json['lastName'], 'Doe');
        expect(json['role'], 'staff');
        expect(json['phone'], '+1234567890');
        expect(json['createdAt'], '2024-01-15T10:30:00.000Z');
        expect(json['password'], 'hashedPassword');
      });

      test('should convert AuthUser to JSON without optional fields', () {
        final user = AuthUser(
          id: 'user-123',
          email: 'test@example.com',
          firstName: 'John',
          role: UserRole.customer,
        );

        final json = user.toJson();

        expect(json['id'], 'user-123');
        expect(json['email'], 'test@example.com');
        expect(json['firstName'], 'John');
        expect(json['role'], 'customer');
        expect(json.containsKey('lastName'), false);
        expect(json.containsKey('phone'), false);
        expect(json.containsKey('createdAt'), false);
        expect(json.containsKey('password'), false);
      });

      test('should handle AuthUser equality', () {
        final user1 = AuthUser(
          id: 'user-123',
          email: 'test@example.com',
          firstName: 'John',
          role: UserRole.customer,
        );

        final user2 = AuthUser(
          id: 'user-123',
          email: 'test@example.com',
          firstName: 'John',
          role: UserRole.customer,
        );

        final user3 = AuthUser(
          id: 'user-456',
          email: 'test@example.com',
          firstName: 'John',
          role: UserRole.customer,
        );

        // AuthUser doesn't extend Equatable, so we check properties
        expect(user1.id, equals(user2.id));
        expect(user1.email, equals(user2.email));
        expect(user1.firstName, equals(user2.firstName));
        expect(user1.role, equals(user2.role));
        expect(user1.id, isNot(equals(user3.id)));
      });

      test('should handle AuthUser toString', () {
        final user = AuthUser(
          id: 'user-123',
          email: 'test@example.com',
          firstName: 'John',
          role: UserRole.customer,
        );

        expect(user.toString(), 'AuthUser(id: user-123, email: test@example.com, role: UserRole.customer)');
      });

      test('should handle null values in JSON conversion', () {
        final json = {
          'id': 'user-123',
          'email': 'test@example.com',
          'firstName': 'John',
          'role': 'customer',
          'createdAt': '2024-01-15T10:30:00Z',
          // lastName, phone, password are null/missing
        };

        final user = AuthUser.fromJson(json);

        expect(user.lastName, isNull);
        expect(user.phone, isNull);
        expect(user.password, isNull);
      });

      test('should handle password field correctly', () {
        final user = AuthUser(
          id: 'user-123',
          email: 'test@example.com',
          firstName: 'John',
          role: UserRole.customer,
          password: 'secret123',
        );

        expect(user.password, 'secret123');
      });
    });

    group('AuthResult Tests', () {
      test('should create successful AuthResult', () {
        final user = AuthUser(
          id: 'user-123',
          email: 'test@example.com',
          firstName: 'John',
          role: UserRole.customer,
        );

        final result = AuthResult.success(user);

        expect(result.isSuccess, true);
        expect(result.user, user);
        expect(result.error, isNull);
      });

      test('should create failed AuthResult', () {
        const errorMessage = 'Authentication failed';
        const result = AuthResult.failure(errorMessage);

        expect(result.isSuccess, false);
        expect(result.user, isNull);
        expect(result.error, errorMessage);
      });

      test('should create AuthResult with constructor', () {
        final user = AuthUser(
          id: 'user-123',
          email: 'test@example.com',
          firstName: 'John',
          role: UserRole.customer,
        );

        final result = AuthResult(user: user, error: null);

        expect(result.isSuccess, true);
        expect(result.user, user);
        expect(result.error, isNull);
      });

      test('should handle AuthResult fold - success case', () {
        final user = AuthUser(
          id: 'user-123',
          email: 'test@example.com',
          firstName: 'John',
          role: UserRole.customer,
        );

        final result = AuthResult.success(user);

        final folded = result.fold(
          (error) => 'Error: $error',
          (user) => 'Success: ${user.email}',
        );

        expect(folded, 'Success: test@example.com');
      });

      test('should handle AuthResult fold - failure case', () {
        const result = AuthResult.failure('Invalid credentials');

        final folded = result.fold(
          (error) => 'Error: $error',
          (user) => 'Success: ${user.email}',
        );

        expect(folded, 'Error: Invalid credentials');
      });

      test('should handle AuthResult equality', () {
        final user1 = AuthUser(
          id: 'user-123',
          email: 'test@example.com',
          firstName: 'John',
          role: UserRole.customer,
        );

        final user2 = AuthUser(
          id: 'user-123',
          email: 'test@example.com',
          firstName: 'John',
          role: UserRole.customer,
        );

        final result1 = AuthResult.success(user1);
        final result2 = AuthResult.success(user2);
        final result3 = AuthResult.failure('Error');

        // AuthUser doesn't extend Equatable, so we check the properties
        expect(result1.isSuccess, equals(result2.isSuccess));
        expect(result1.user?.id, equals(result2.user?.id));
        expect(result1.user?.email, equals(result2.user?.email));
        expect(result1.isSuccess, isNot(equals(result3.isSuccess)));
      });

      test('should handle AuthResult toString', () {
        final user = AuthUser(
          id: 'user-123',
          email: 'test@example.com',
          firstName: 'John',
          role: UserRole.customer,
        );

        final successResult = AuthResult.success(user);
        const failureResult = AuthResult.failure('Invalid credentials');

        expect(successResult.toString(), contains('AuthResult'));
        expect(failureResult.toString(), contains('AuthResult'));
      });
    });

    group('Integration Tests', () {
      test('should create complete auth flow', () {
        // Create a user
        final user = AuthUser(
          id: 'user-123',
          email: 'test@example.com',
          firstName: 'John',
          lastName: 'Doe',
          role: UserRole.staff,
          phone: '+1234567890',
        );

        // Create a successful auth result
        final authResult = AuthResult.success(user);

        // Verify the flow
        expect(authResult.isSuccess, true);
        expect(authResult.user?.role.isStaff, true);
        expect(authResult.user?.fullName, 'John Doe');
        expect(authResult.user?.name, 'John Doe');

        // Test fold operation
        final result = authResult.fold(
          (error) => false,
          (user) => user.role.isStaff,
        );

        expect(result, true);
      });

      test('should handle user role-based logic', () {
        final customer = AuthUser(
          id: 'customer-123',
          email: 'customer@example.com',
          firstName: 'Jane',
          lastName: 'Smith',
          role: UserRole.customer,
        );

        final staff = AuthUser(
          id: 'staff-123',
          email: 'staff@example.com',
          firstName: 'Bob',
          lastName: 'Johnson',
          role: UserRole.staff,
        );

        final admin = AuthUser(
          id: 'admin-123',
          email: 'admin@example.com',
          firstName: 'Alice',
          lastName: 'Williams',
          role: UserRole.admin,
        );

        // Check role-based privileges
        expect(customer.role.isCustomer, true);
        expect(customer.role.isStaff, false);
        expect(customer.role.isAdmin, false);

        expect(staff.role.isCustomer, false);
        expect(staff.role.isStaff, true);
        expect(staff.role.isAdmin, false);

        expect(admin.role.isCustomer, false);
        expect(admin.role.isStaff, false);
        expect(admin.role.isAdmin, true);
      });

      test('should handle JSON serialization round trip', () {
        final originalUser = AuthUser(
          id: 'user-123',
          email: 'test@example.com',
          firstName: 'John',
          lastName: 'Doe',
          role: UserRole.staff,
          phone: '+1234567890',
          createdAt: DateTime.parse('2024-01-15T10:30:00.000Z'),
          password: 'hashedPassword',
        );

        // Convert to JSON
        final json = originalUser.toJson();

        // Convert back from JSON
        final restoredUser = AuthUser.fromJson(json);

        // Verify all fields match (AuthUser doesn't extend Equatable)
        expect(restoredUser.id, originalUser.id);
        expect(restoredUser.email, originalUser.email);
        expect(restoredUser.firstName, originalUser.firstName);
        expect(restoredUser.lastName, originalUser.lastName);
        expect(restoredUser.role, originalUser.role);
        expect(restoredUser.phone, originalUser.phone);
        expect(restoredUser.createdAt, originalUser.createdAt);
        expect(restoredUser.password, originalUser.password);
      });

      test('should handle JSON round trip with minimal data', () {
        final originalUser = AuthUser(
          id: 'user-123',
          email: 'test@example.com',
          firstName: 'John',
          role: UserRole.customer,
        );

        // Convert to JSON
        final json = originalUser.toJson();

        // Convert back from JSON
        final restoredUser = AuthUser.fromJson(json);

        // Verify all fields match (AuthUser doesn't extend Equatable)
        expect(restoredUser.id, originalUser.id);
        expect(restoredUser.email, originalUser.email);
        expect(restoredUser.firstName, originalUser.firstName);
        expect(restoredUser.role, originalUser.role);
      });
    });
  });
}
