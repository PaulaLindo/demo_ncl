// test/unit/core_models_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_ncl/models/auth_model.dart';
import 'package:demo_ncl/models/booking_model.dart';
import 'package:demo_ncl/models/service_model.dart';
import 'package:demo_ncl/models/time_record_model.dart';

void main() {
  group('Core Models Tests', () {
    group('AuthUser Model Tests', () {
      test('should create AuthUser with required fields', () {
        // Arrange
        final user = const AuthUser(
          id: 'user123',
          email: 'test@example.com',
          role: UserRole.customer,
          firstName: 'Test',
        );

        // Assert
        expect(user.id, equals('user123'));
        expect(user.email, equals('test@example.com'));
        expect(user.firstName, equals('Test'));
        expect(user.role, equals(UserRole.customer));
      });

      test('should create AuthUser with all fields', () {
        // Arrange
        final user = AuthUser(
          id: 'staff123',
          email: 'staff@example.com',
          role: UserRole.staff,
          firstName: 'Staff',
          lastName: 'Member',
          phone: '+1234567890',
          createdAt: DateTime(2023, 1, 1),
        );

        // Assert
        expect(user.role, equals(UserRole.staff));
        expect(user.firstName, equals('Staff'));
        expect(user.lastName, equals('Member'));
        expect(user.phone, equals('+1234567890'));
        expect(user.createdAt, equals(DateTime(2023, 1, 1)));
      });

      test('should handle all UserRole enum values', () {
        for (final role in UserRole.values) {
          final user = AuthUser(
            id: role.name,
            email: '$role@example.com',
            role: role,
            firstName: role.toString(),
          );
          expect(user.role, equals(role));
        }
      });
    });

    group('Service Model Tests', () {
      test('should create Service with required fields', () {
        // Arrange
        final service = Service(
          id: 'service1',
          name: 'Test Service',
          description: 'Test Description',
          basePrice: 100.0,
          duration: '2 hours',
          category: 'Test',
          rating: 4.5,
          reviewCount: 10,
          features: ['Feature 1', 'Feature 2'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Assert
        expect(service.id, equals('service1'));
        expect(service.name, equals('Test Service'));
        expect(service.basePrice, equals(100.0));
        expect(service.duration, equals('2 hours'));
        expect(service.category, equals('Test'));
        expect(service.pricingUnit == 'hour', isFalse); // Default value
        expect(service.rating, equals(4.5));
        expect(service.reviewCount, equals(10));
        expect(service.features, contains('Feature 1'));
        expect(service.features, contains('Feature 2'));
      });

      test('should handle Service with optional fields', () {
        // Arrange
        final service = Service(
          id: 'service2',
          name: 'Minimal Service',
          description: 'Minimal Description',
          basePrice: 50.0,
          duration: '1 hour',
          category: 'Basic',
          rating: 0.0,
          reviewCount: 0,
          features: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Assert
        expect(service.imageUrl, isNull);
        expect(service.features, isEmpty);
        expect(service.rating, equals(0.0));
        expect(service.reviewCount, equals(0));
        expect(service.pricingUnit == 'hour', isFalse);
      });

      test('should handle popular and featured services', () {
        // Arrange
        final service = Service(
          id: 'service3',
          name: 'Premium Service',
          description: 'Premium Description',
          basePrice: 200.0,
          duration: '3 hours',
          category: 'Premium',
          isPopular: true,
          isFeatured: true,
          rating: 5.0,
          reviewCount: 100,
          features: ['Premium Feature 1', 'Premium Feature 2'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Assert
        expect(service.basePrice, equals(200.0));
        expect(service.duration, equals('3 hours'));
        expect(service.isPopular, isTrue);
        expect(service.isFeatured, isTrue);
      });
    });

    group('TimeRecord Model Tests', () {
      test('should create TimeRecord with required fields', () {
        // Arrange
        final timeRecord = TimeRecord(
          id: 'record1',
          staffId: 'staff123',
          jobId: 'job123',
          checkInTime: DateTime(2023, 12, 25, 9, 0),
          startTime: DateTime(2023, 12, 25, 9, 0),
          type: TimeRecordType.self,
          status: TimeRecordStatus.inProgress,
        );

        // Assert
        expect(timeRecord.id, equals('record1'));
        expect(timeRecord.staffId, equals('staff123'));
        expect(timeRecord.jobId, equals('job123'));
        expect(timeRecord.type, equals(TimeRecordType.self));
        expect(timeRecord.status, equals(TimeRecordStatus.inProgress));
        expect(timeRecord.isBreak, isFalse);
      });

      test('should handle all TimeRecordType enum values', () {
        for (final type in TimeRecordType.values) {
          final timeRecord = TimeRecord(
            id: type.name,
            staffId: 'staff123',
            jobId: 'job123',
            checkInTime: DateTime.now(),
            startTime: DateTime.now(),
            type: type,
            status: TimeRecordStatus.inProgress,
          );
          expect(timeRecord.type, equals(type));
        }
      });

      test('should handle all TimeRecordStatus enum values', () {
        for (final status in TimeRecordStatus.values) {
          final timeRecord = TimeRecord(
            id: status.name,
            staffId: 'staff123',
            jobId: 'job123',
            checkInTime: DateTime.now(),
            startTime: DateTime.now(),
            type: TimeRecordType.self,
            status: status,
          );
          expect(timeRecord.status, equals(status));
        }
      });

      test('should calculate duration correctly', () {
        // Arrange
        final checkInTime = DateTime(2023, 12, 25, 9, 0);
        final checkOutTime = DateTime(2023, 12, 25, 17, 30); // 8.5 hours later

        final timeRecord = TimeRecord(
          id: 'duration_test',
          staffId: 'staff123',
          jobId: 'job123',
          checkInTime: checkInTime,
          checkOutTime: checkOutTime,
          startTime: checkInTime,
          endTime: checkOutTime,
          type: TimeRecordType.self,
          status: TimeRecordStatus.completed,
        );

        // Assert
        final duration = timeRecord.endTime!.difference(timeRecord.startTime);
        expect(duration.inHours, equals(8));
        expect(duration.inMinutes % 60, equals(30));
      });
    });

    group('Booking Model Tests', () {
      test('should create Booking with required fields', () {
        // Arrange
        final booking = Booking(
          id: 'booking1',
          customerId: 'customer123',
          serviceId: 'service123',
          serviceName: 'Test Service',
          bookingDate: DateTime(2023, 12, 25),
          timePreference: TimeOfDayPreference.morning,
          address: '123 Test St',
          status: BookingStatus.pending,
          basePrice: 100.0,
          propertySize: PropertySize.medium,
          frequency: BookingFrequency.oneTime,
          startTime: DateTime(2023, 12, 25, 9, 0),
          endTime: DateTime(2023, 12, 25, 11, 0),
          createdAt: DateTime(2023, 12, 25),
        );

        // Assert
        expect(booking.id, equals('booking1'));
        expect(booking.customerId, equals('customer123'));
        expect(booking.serviceId, equals('service123'));
        expect(booking.serviceName, equals('Test Service'));
        expect(booking.bookingDate, equals(DateTime(2023, 12, 25)));
        expect(booking.basePrice, equals(100.0));
        expect(booking.status, equals(BookingStatus.pending));
      });

      test('should handle all BookingStatus enum values', () {
        for (final status in BookingStatus.values) {
          final booking = Booking(
            id: status.name,
            customerId: 'customer123',
            serviceId: 'service123',
            serviceName: 'Test Service',
            bookingDate: DateTime.now(),
            timePreference: TimeOfDayPreference.flexible,
            address: '123 Test St',
            status: status,
            basePrice: 100.0,
            propertySize: PropertySize.medium,
            frequency: BookingFrequency.oneTime,
            startTime: DateTime.now(),
            endTime: DateTime.now().add(const Duration(hours: 2)),
            createdAt: DateTime.now(),
          );
          expect(booking.status, equals(status));
        }
      });

      test('should handle optional fields in Booking', () {
        // Arrange
        final booking = Booking(
          id: 'booking2',
          customerId: 'customer123',
          serviceId: 'service123',
          serviceName: 'Test Service',
          bookingDate: DateTime(2023, 12, 25),
          timePreference: TimeOfDayPreference.morning,
          address: '123 Test St',
          status: BookingStatus.confirmed,
          basePrice: 150.0,
          finalPrice: 180.0,
          propertySize: PropertySize.medium,
          frequency: BookingFrequency.oneTime,
          startTime: DateTime(2023, 12, 25, 9, 0),
          endTime: DateTime(2023, 12, 25, 11, 0),
          specialInstructions: 'Special instructions',
          assignedStaffId: 'staff123',
          assignedStaffName: 'Staff Member',
          createdAt: DateTime(2023, 12, 25),
        );

        // Assert
        expect(booking.finalPrice, equals(180.0));
        expect(booking.specialInstructions, equals('Special instructions'));
        expect(booking.assignedStaffId, equals('staff123'));
        expect(booking.assignedStaffName, equals('Staff Member'));
      });
    });

    group('UserRole Enum Tests', () {
      test('should have correct values', () {
        expect(UserRole.values, containsAll([
          UserRole.customer,
          UserRole.staff,
          UserRole.admin,
        ]));
      });

      test('should convert to string correctly', () {
        expect(UserRole.customer.toString(), contains('customer'));
        expect(UserRole.staff.toString(), contains('staff'));
        expect(UserRole.admin.toString(), contains('admin'));
      });

      test('should have correct helper methods', () {
        expect(UserRole.admin.isAdmin, isTrue);
        expect(UserRole.admin.isStaff, isFalse);
        expect(UserRole.admin.isCustomer, isFalse);

        expect(UserRole.staff.isAdmin, isFalse);
        expect(UserRole.staff.isStaff, isTrue);
        expect(UserRole.staff.isCustomer, isFalse);

        expect(UserRole.customer.isAdmin, isFalse);
        expect(UserRole.customer.isStaff, isFalse);
        expect(UserRole.customer.isCustomer, isTrue);
      });
    });

    group('BookingStatus Enum Tests', () {
      test('should have correct values', () {
        expect(BookingStatus.values, containsAll([
          BookingStatus.pending,
          BookingStatus.confirmed,
          BookingStatus.inProgress,
          BookingStatus.completed,
          BookingStatus.cancelled,
          BookingStatus.rejected,
        ]));
      });

      test('should convert to string correctly', () {
        expect(BookingStatus.pending.toString(), contains('pending'));
        expect(BookingStatus.confirmed.toString(), contains('confirmed'));
        expect(BookingStatus.inProgress.toString(), contains('inProgress'));
        expect(BookingStatus.completed.toString(), contains('completed'));
        expect(BookingStatus.cancelled.toString(), contains('cancelled'));
        expect(BookingStatus.rejected.toString(), contains('rejected'));
      });
    });

    group('TimeOfDayPreference Enum Tests', () {
      test('should have correct values', () {
        expect(TimeOfDayPreference.values, containsAll([
          TimeOfDayPreference.morning,
          TimeOfDayPreference.afternoon,
          TimeOfDayPreference.evening,
          TimeOfDayPreference.flexible,
        ]));
      });

      test('should have correct display names', () {
        expect(TimeOfDayPreference.morning.displayName, equals('Morning'));
        expect(TimeOfDayPreference.afternoon.displayName, equals('Afternoon'));
        expect(TimeOfDayPreference.evening.displayName, equals('Evening'));
        expect(TimeOfDayPreference.flexible.displayName, equals('Flexible'));
      });

      test('should have correct time ranges', () {
        expect(TimeOfDayPreference.morning.timeRange, equals('08:00 - 12:00'));
        expect(TimeOfDayPreference.afternoon.timeRange, equals('12:00 - 16:00'));
        expect(TimeOfDayPreference.evening.timeRange, equals('16:00 - 20:00'));
        expect(TimeOfDayPreference.flexible.timeRange, equals('Anytime'));
      });
    });

    group('PropertySize Enum Tests', () {
      test('should have correct values', () {
        expect(PropertySize.values, containsAll([
          PropertySize.small,
          PropertySize.medium,
          PropertySize.large,
        ]));
      });

      test('should have correct display names and multipliers', () {
        expect(PropertySize.small.displayName, equals('Small (1-2 rooms)'));
        expect(PropertySize.small.priceMultiplier, equals(1.0));

        expect(PropertySize.medium.displayName, equals('Medium (3-4 rooms)'));
        expect(PropertySize.medium.priceMultiplier, equals(1.5));

        expect(PropertySize.large.displayName, equals('Large (5+ rooms)'));
        expect(PropertySize.large.priceMultiplier, equals(2.0));
      });
    });

    group('BookingFrequency Enum Tests', () {
      test('should have correct values', () {
        expect(BookingFrequency.values, containsAll([
          BookingFrequency.oneTime,
          BookingFrequency.weekly,
          BookingFrequency.biWeekly,
          BookingFrequency.monthly,
        ]));
      });

      test('should have correct display names and discounts', () {
        expect(BookingFrequency.oneTime.displayName, equals('One-time'));
        expect(BookingFrequency.oneTime.discountMultiplier, equals(1.0));

        expect(BookingFrequency.weekly.displayName, equals('Weekly'));
        expect(BookingFrequency.weekly.discountMultiplier, equals(0.9));

        expect(BookingFrequency.biWeekly.displayName, equals('Bi-weekly'));
        expect(BookingFrequency.biWeekly.discountMultiplier, equals(0.85));

        expect(BookingFrequency.monthly.displayName, equals('Monthly'));
        expect(BookingFrequency.monthly.discountMultiplier, equals(0.8));
      });
    });
  });
}
