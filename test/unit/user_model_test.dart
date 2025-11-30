// test/unit/user_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_ncl/models/user_model.dart';

void main() {
  group('User Model Tests', () {
    group('User Tests', () {
      test('should create User with required fields', () {
        final user = User(
          id: 'user-123',
          name: 'John Doe',
        );

        expect(user.id, 'user-123');
        expect(user.name, 'John Doe');
        expect(user.email, isNull);
        expect(user.avatarUrl, isNull);
        expect(user.isStaff, false);
        expect(user.isAdmin, false);
      });

      test('should create User with all fields', () {
        final user = User(
          id: 'user-456',
          name: 'Jane Smith',
          email: 'jane.smith@example.com',
          avatarUrl: 'https://example.com/avatar.jpg',
          isStaff: true,
          isAdmin: false,
        );

        expect(user.id, 'user-456');
        expect(user.name, 'Jane Smith');
        expect(user.email, 'jane.smith@example.com');
        expect(user.avatarUrl, 'https://example.com/avatar.jpg');
        expect(user.isStaff, true);
        expect(user.isAdmin, false);
      });

      test('should create admin user', () {
        final user = User(
          id: 'admin-123',
          name: 'Admin User',
          email: 'admin@example.com',
          isStaff: true,
          isAdmin: true,
        );

        expect(user.id, 'admin-123');
        expect(user.name, 'Admin User');
        expect(user.email, 'admin@example.com');
        expect(user.isStaff, true);
        expect(user.isAdmin, true);
      });

      test('should assert admin must be staff', () {
        expect(
          () => User(
            id: 'admin-123',
            name: 'Admin User',
            isAdmin: true,
            isStaff: false, // This should cause an assertion error
          ),
          throwsA(isA<AssertionError>()),
        );
      });

      test('should create User from JSON', () {
        final json = {
          'id': 'user-123',
          'name': 'John Doe',
          'email': 'john.doe@example.com',
          'avatarUrl': 'https://example.com/avatar.jpg',
          'isStaff': true,
          'isAdmin': false,
        };

        final user = User.fromJson(json);

        expect(user.id, 'user-123');
        expect(user.name, 'John Doe');
        expect(user.email, 'john.doe@example.com');
        expect(user.avatarUrl, 'https://example.com/avatar.jpg');
        expect(user.isStaff, true);
        expect(user.isAdmin, false);
      });

      test('should create User from JSON with minimal data', () {
        final json = {
          'id': 'user-123',
          'name': 'John Doe',
        };

        final user = User.fromJson(json);

        expect(user.id, 'user-123');
        expect(user.name, 'John Doe');
        expect(user.email, isNull);
        expect(user.avatarUrl, isNull);
        expect(user.isStaff, false);
        expect(user.isAdmin, false);
      });

      test('should create User from JSON with null values', () {
        final json = {
          'id': 'user-123',
          'name': 'John Doe',
          'email': null,
          'avatarUrl': null,
          'isStaff': null,
          'isAdmin': null,
        };

        final user = User.fromJson(json);

        expect(user.id, 'user-123');
        expect(user.name, 'John Doe');
        expect(user.email, isNull);
        expect(user.avatarUrl, isNull);
        expect(user.isStaff, false); // Default
        expect(user.isAdmin, false); // Default
      });

      test('should convert User to JSON', () {
        final user = User(
          id: 'user-123',
          name: 'John Doe',
          email: 'john.doe@example.com',
          avatarUrl: 'https://example.com/avatar.jpg',
          isStaff: true,
          isAdmin: false,
        );

        final json = user.toJson();

        expect(json['id'], 'user-123');
        expect(json['name'], 'John Doe');
        expect(json['email'], 'john.doe@example.com');
        expect(json['avatarUrl'], 'https://example.com/avatar.jpg');
        expect(json['isStaff'], true);
        expect(json['isAdmin'], false);
      });

      test('should convert User to JSON without optional fields', () {
        final user = User(
          id: 'user-123',
          name: 'John Doe',
        );

        final json = user.toJson();

        expect(json['id'], 'user-123');
        expect(json['name'], 'John Doe');
        expect(json.containsKey('email'), false);
        expect(json.containsKey('avatarUrl'), false);
        expect(json['isStaff'], false);
        expect(json['isAdmin'], false);
      });

      test('should copy User with updates', () {
        final originalUser = User(
          id: 'user-123',
          name: 'John Doe',
          email: 'john.doe@example.com',
        );

        final updatedUser = originalUser.copyWith(
          name: 'Jane Doe',
          isStaff: true,
          isAdmin: true,
        );

        expect(updatedUser.id, 'user-123'); // Unchanged
        expect(updatedUser.name, 'Jane Doe');
        expect(updatedUser.email, 'john.doe@example.com'); // Unchanged
        expect(updatedUser.isStaff, true);
        expect(updatedUser.isAdmin, true);
      });

      test('should handle User equality', () {
        final user1 = User(
          id: 'user-123',
          name: 'John Doe',
          email: 'john.doe@example.com',
        );

        final user2 = User(
          id: 'user-123',
          name: 'John Doe',
          email: 'john.doe@example.com',
        );

        final user3 = User(
          id: 'user-456',
          name: 'John Doe',
          email: 'john.doe@example.com',
        );

        expect(user1, equals(user2));
        expect(user1, isNot(equals(user3)));
      });

      test('should handle User toString', () {
        final user = User(
          id: 'user-123',
          name: 'John Doe',
          email: 'john.doe@example.com',
          isStaff: false,
          isAdmin: false,
        );

        final result = user.toString();
        expect(result, contains('User'));
        expect(result, contains('user-123'));
        expect(result, contains('John Doe'));
        expect(result, contains('john.doe@example.com'));
        expect(result, contains('isStaff: false'));
        expect(result, contains('isAdmin: false'));
      });

      test('should handle User toString without email', () {
        final user = User(
          id: 'user-123',
          name: 'John Doe',
          isStaff: true,
          isAdmin: false,
        );

        final result = user.toString();
        expect(result, contains('User'));
        expect(result, contains('user-123'));
        expect(result, contains('John Doe'));
        expect(result, contains('email: null'));
        expect(result, contains('isStaff: true'));
        expect(result, contains('isAdmin: false'));
      });
    });

    group('Integration Tests', () {
      test('should handle JSON serialization round trip', () {
        final originalUser = User(
          id: 'user-123',
          name: 'John Doe',
          email: 'john.doe@example.com',
          avatarUrl: 'https://example.com/avatar.jpg',
          isStaff: true,
          isAdmin: false,
        );

        // Convert to JSON
        final json = originalUser.toJson();

        // Convert back from JSON
        final restoredUser = User.fromJson(json);

        // Verify all fields match
        expect(restoredUser, equals(originalUser));
        expect(restoredUser.id, originalUser.id);
        expect(restoredUser.name, originalUser.name);
        expect(restoredUser.email, originalUser.email);
        expect(restoredUser.avatarUrl, originalUser.avatarUrl);
        expect(restoredUser.isStaff, originalUser.isStaff);
        expect(restoredUser.isAdmin, originalUser.isAdmin);
      });

      test('should handle user role hierarchy', () {
        // Regular customer
        final customer = User(
          id: 'customer-123',
          name: 'Customer User',
          email: 'customer@example.com',
        );

        // Staff member
        final staff = User(
          id: 'staff-123',
          name: 'Staff User',
          email: 'staff@example.com',
          isStaff: true,
          isAdmin: false,
        );

        // Admin (must also be staff)
        final admin = User(
          id: 'admin-123',
          name: 'Admin User',
          email: 'admin@example.com',
          isStaff: true,
          isAdmin: true,
        );

        // Verify roles
        expect(customer.isStaff, false);
        expect(customer.isAdmin, false);

        expect(staff.isStaff, true);
        expect(staff.isAdmin, false);

        expect(admin.isStaff, true);
        expect(admin.isAdmin, true);
      });

      test('should handle user updates', () {
        // Start as customer
        var user = User(
          id: 'user-123',
          name: 'John Doe',
          email: 'john.doe@example.com',
        );

        expect(user.isStaff, false);
        expect(user.isAdmin, false);

        // Promote to staff
        user = user.copyWith(isStaff: true);
        expect(user.isStaff, true);
        expect(user.isAdmin, false);

        // Promote to admin
        user = user.copyWith(isAdmin: true);
        expect(user.isStaff, true);
        expect(user.isAdmin, true);

        // Update name and email
        user = user.copyWith(
          name: 'Jane Doe',
          email: 'jane.doe@example.com',
        );
        expect(user.name, 'Jane Doe');
        expect(user.email, 'jane.doe@example.com');
        expect(user.isStaff, true);
        expect(user.isAdmin, true);
      });

      test('should handle partial JSON data', () {
        // Test with only required fields
        final json1 = {'id': 'user-123', 'name': 'John Doe'};
        final user1 = User.fromJson(json1);
        expect(user1.email, isNull);
        expect(user1.avatarUrl, isNull);
        expect(user1.isStaff, false);
        expect(user1.isAdmin, false);

        // Test with some optional fields
        final json2 = {
          'id': 'user-456',
          'name': 'Jane Smith',
          'email': 'jane@example.com',
          'isStaff': true,
        };
        final user2 = User.fromJson(json2);
        expect(user2.email, 'jane@example.com');
        expect(user2.avatarUrl, isNull);
        expect(user2.isStaff, true);
        expect(user2.isAdmin, false);
      });

      test('should handle JSON export consistency', () {
        final user = User(
          id: 'user-123',
          name: 'John Doe',
          email: 'john.doe@example.com',
          avatarUrl: 'https://example.com/avatar.jpg',
          isStaff: true,
          isAdmin: false,
        );

        // Convert to JSON
        final json = user.toJson();

        // Convert back from JSON
        final restoredUser = User.fromJson(json);

        // Convert to JSON again
        final json2 = restoredUser.toJson();

        // JSON should be identical
        expect(json, equals(json2));
      });
    });
  });
}
