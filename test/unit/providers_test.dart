// test/unit/providers_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:demo_ncl/providers/auth_provider.dart';
import 'package:demo_ncl/providers/booking_provider.dart';
import 'package:demo_ncl/providers/staff_provider.dart';
import 'package:demo_ncl/providers/timekeeping_provider.dart';
import 'package:demo_ncl/models/auth_model.dart';
import 'package:demo_ncl/models/user_model.dart';
import 'package:demo_ncl/models/booking_model.dart';
import 'package:demo_ncl/models/time_record_model.dart';

void main() {
  // Initialize Flutter binding for tests
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Provider Tests', () {
    group('AuthProvider Tests', () {
      late AuthProvider authProvider;

      setUp(() {
        authProvider = AuthProvider();
      });

      test('should initialize with no user', () {
        expect(authProvider.currentUser, isNull);
        expect(authProvider.isLoading, isFalse);
        expect(authProvider.hasError, isFalse);
      });

      test('should handle login state correctly', () {
        // Arrange
        final testUser = AuthUser(
          id: 'test123',
          email: 'test@example.com',
          role: UserRole.customer,
          firstName: 'Test',
        );

        // Act
        authProvider.setUser(testUser);

        // Assert
        expect(authProvider.currentUser, equals(testUser));
        expect(authProvider.isLoggedIn, isTrue);
      });

      test('should handle logout correctly', () async {
        // Arrange
        final testUser = AuthUser(
          id: 'test123',
          email: 'test@example.com',
          role: UserRole.customer,
          firstName: 'Test',
        );
        authProvider.setUser(testUser);

        // Act
        await authProvider.logout();

        // Assert
        expect(authProvider.currentUser, isNull);
        expect(authProvider.isLoggedIn, isFalse);
      });

      test('should handle loading state', () {
        // Act
        authProvider.setLoading(true);

        // Assert
        expect(authProvider.isLoading, isTrue);

        // Act
        authProvider.setLoading(false);

        // Assert
        expect(authProvider.isLoading, isFalse);
      });

      test('should handle error state', () {
        // Act
        authProvider.setError('Test error');

        // Assert
        expect(authProvider.hasError, isTrue);
        expect(authProvider.errorMessage, equals('Test error'));

        // Act
        authProvider.clearError();

        // Assert
        expect(authProvider.hasError, isFalse);
        expect(authProvider.errorMessage, isNull);
      });
    });

    group('BookingProvider Tests', () {
      late BookingProvider bookingProvider;

      setUp(() {
        bookingProvider = BookingProvider();
      });

      test('should initialize with empty bookings', () {
        expect(bookingProvider.bookings, isEmpty);
        expect(bookingProvider.isLoading, isFalse);
        expect(bookingProvider.hasError, isFalse);
      });

      test('should add booking correctly', () {
        // Arrange
        final booking = Booking(
          id: 'booking1',
          customerId: 'customer123',
          serviceId: 'service123',
          serviceName: 'Test Service',
          bookingDate: DateTime.now(),
          timePreference: TimeOfDayPreference.morning,
          address: '123 Test St',
          status: BookingStatus.pending,
          basePrice: 100.0,
          propertySize: PropertySize.medium,
          frequency: BookingFrequency.oneTime,
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 2)),
          createdAt: DateTime.now(),
        );

        // Act
        bookingProvider.addBooking(booking);

        // Assert
        expect(bookingProvider.bookings, contains(booking));
        expect(bookingProvider.bookings.length, equals(1));
      });

      test('should update booking status correctly', () {
        // Arrange
        final booking = Booking(
          id: 'booking1',
          customerId: 'customer123',
          serviceId: 'service123',
          serviceName: 'Test Service',
          bookingDate: DateTime.now(),
          timePreference: TimeOfDayPreference.morning,
          address: '123 Test St',
          status: BookingStatus.pending,
          basePrice: 100.0,
          propertySize: PropertySize.medium,
          frequency: BookingFrequency.oneTime,
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 2)),
          createdAt: DateTime.now(),
        );
        bookingProvider.addBooking(booking);

        // Act
        bookingProvider.updateBookingStatus('booking1', BookingStatus.confirmed);

        // Assert
        final updatedBooking = bookingProvider.bookings.first;
        expect(updatedBooking.status, equals(BookingStatus.confirmed));
      });

      test('should filter bookings by customer', () {
        // Arrange
        final booking1 = Booking(
          id: 'booking1',
          customerId: 'customer1',
          serviceId: 'service123',
          serviceName: 'Test Service',
          bookingDate: DateTime.now(),
          timePreference: TimeOfDayPreference.morning,
          address: '123 Test St',
          status: BookingStatus.pending,
          basePrice: 100.0,
          propertySize: PropertySize.medium,
          frequency: BookingFrequency.oneTime,
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 2)),
          createdAt: DateTime.now(),
        );
        final booking2 = Booking(
          id: 'booking2',
          customerId: 'customer2',
          serviceId: 'service456',
          serviceName: 'Test Service 2',
          bookingDate: DateTime.now(),
          timePreference: TimeOfDayPreference.afternoon,
          address: '456 Test St',
          status: BookingStatus.confirmed,
          basePrice: 150.0,
          propertySize: PropertySize.large,
          frequency: BookingFrequency.weekly,
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 3)),
          createdAt: DateTime.now(),
        );
        bookingProvider.addBooking(booking1);
        bookingProvider.addBooking(booking2);

        // Act
        final customerBookings = bookingProvider.getBookingsForCustomer('customer1');

        // Assert
        expect(customerBookings, contains(booking1));
        expect(customerBookings, isNot(contains(booking2)));
        expect(customerBookings.length, equals(1));
      });

      test('should get upcoming bookings correctly', () {
        // Arrange
        final pastBooking = Booking(
          id: 'past',
          customerId: 'customer1',
          serviceId: 'service123',
          serviceName: 'Past Service',
          bookingDate: DateTime.now().subtract(const Duration(days: 1)),
          timePreference: TimeOfDayPreference.morning,
          address: '123 Test St',
          status: BookingStatus.completed,
          basePrice: 100.0,
          propertySize: PropertySize.medium,
          frequency: BookingFrequency.oneTime,
          startTime: DateTime.now().subtract(const Duration(days: 1)),
          endTime: DateTime.now().subtract(const Duration(days: 1)).add(const Duration(hours: 2)),
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        );
        final upcomingBooking = Booking(
          id: 'upcoming',
          customerId: 'customer1',
          serviceId: 'service456',
          serviceName: 'Upcoming Service',
          bookingDate: DateTime.now().add(const Duration(days: 1)),
          timePreference: TimeOfDayPreference.afternoon,
          address: '456 Test St',
          status: BookingStatus.confirmed,
          basePrice: 150.0,
          propertySize: PropertySize.large,
          frequency: BookingFrequency.weekly,
          startTime: DateTime.now().add(const Duration(days: 1)),
          endTime: DateTime.now().add(const Duration(days: 1)).add(const Duration(hours: 3)),
          createdAt: DateTime.now(),
        );
        bookingProvider.addBooking(pastBooking);
        bookingProvider.addBooking(upcomingBooking);

        // Act
        final upcomingBookings = bookingProvider.getUpcomingBookings();

        // Assert
        expect(upcomingBookings, contains(upcomingBooking));
        expect(upcomingBookings, isNot(contains(pastBooking)));
        expect(upcomingBookings.length, equals(1));
      });
    });

    group('StaffProvider Tests', () {
      late StaffProvider staffProvider;

      setUp(() {
        staffProvider = StaffProvider();
      });

      test('should initialize with empty staff list', () {
        expect(staffProvider.staff, isEmpty);
        expect(staffProvider.isLoading, isFalse);
        expect(staffProvider.hasError, isFalse);
      });

      test('should add staff member correctly', () {
        // Arrange
        final staffMember = User(
          id: 'staff123',
          name: 'Staff Member',
          email: 'staff@example.com',
          isStaff: true,
        );

        // Act
        staffProvider.addStaffMember(staffMember);

        // Assert
        expect(staffProvider.staff, contains(staffMember));
        expect(staffProvider.staff.length, equals(1));
      });

      test('should remove staff member correctly', () {
        // Arrange
        final staffMember = User(
          id: 'staff123',
          name: 'Staff Member',
          email: 'staff@example.com',
          isStaff: true,
        );
        staffProvider.addStaffMember(staffMember);

        // Act
        staffProvider.removeStaffMember('staff123');

        // Assert
        expect(staffProvider.staff, isEmpty);
      });

      test('should get active staff correctly', () {
        // Arrange
        final activeStaff = User(
          id: 'staff123',
          name: 'Active Staff',
          email: 'active@example.com',
          isStaff: true,
        );
        final inactiveStaff = User(
          id: 'staff456',
          name: 'Inactive Staff',
          email: 'inactive@example.com',
          isStaff: false,
        );

        // Act
        staffProvider.addStaffMember(activeStaff);
        staffProvider.addStaffMember(inactiveStaff);

        // Assert
        final activeStaffList = staffProvider.getActiveStaff();
        expect(activeStaffList, contains(activeStaff));
        expect(activeStaffList, isNot(contains(inactiveStaff)));
        expect(activeStaffList.length, equals(1));
      });
    });

    group('TimekeepingProvider Tests', () {
      late TimekeepingProvider timekeepingProvider;

      setUp(() {
        // Mock the method channel to prevent binding issues
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('flutter/connectivity'),
          (MethodCall methodCall) async {
            return {'networkStatus': 'connected'};
          },
        );
        
        timekeepingProvider = TimekeepingProvider();
      });

      test('should initialize with empty time records', () {
        expect(timekeepingProvider.timeRecords, isEmpty);
        expect(timekeepingProvider.isLoading, isFalse);
        expect(timekeepingProvider.hasError, isFalse);
      });

      test('should add time record correctly', () {
        // Arrange
        final timeRecord = TimeRecord(
          id: 'record1',
          staffId: 'staff123',
          jobId: 'job123',
          checkInTime: DateTime.now(),
          startTime: DateTime.now(),
          type: TimeRecordType.self,
          status: TimeRecordStatus.inProgress,
        );

        // Act
        timekeepingProvider.addTimeRecord(timeRecord);

        // Assert
        expect(timekeepingProvider.timeRecords, contains(timeRecord));
        expect(timekeepingProvider.timeRecords.length, equals(1));
      });

      test('should get active time record correctly', () {
        // Arrange
        final activeRecord = TimeRecord(
          id: 'active1',
          staffId: 'staff123',
          jobId: 'job123',
          checkInTime: DateTime.now(),
          startTime: DateTime.now(),
          type: TimeRecordType.self,
          status: TimeRecordStatus.inProgress,
        );
        final completedRecord = TimeRecord(
          id: 'completed1',
          staffId: 'staff123',
          jobId: 'job456',
          checkInTime: DateTime.now().subtract(const Duration(hours: 2)),
          checkOutTime: DateTime.now().subtract(const Duration(hours: 1)),
          startTime: DateTime.now().subtract(const Duration(hours: 2)),
          endTime: DateTime.now().subtract(const Duration(hours: 1)),
          type: TimeRecordType.self,
          status: TimeRecordStatus.completed,
        );
        timekeepingProvider.addTimeRecord(activeRecord);
        timekeepingProvider.addTimeRecord(completedRecord);

        // Act
        final activeRecords = timekeepingProvider.getActiveTimeRecords();

        // Assert
        expect(activeRecords, contains(activeRecord));
        expect(activeRecords, isNot(contains(completedRecord)));
        expect(activeRecords.length, equals(1));
      });

      test('should get time records for staff correctly', () {
        // Arrange
        final staff1Record = TimeRecord(
          id: 'staff1_record1',
          staffId: 'staff1',
          jobId: 'job123',
          checkInTime: DateTime.now(),
          startTime: DateTime.now(),
          type: TimeRecordType.self,
          status: TimeRecordStatus.inProgress,
        );
        final staff2Record = TimeRecord(
          id: 'staff2_record1',
          staffId: 'staff2',
          jobId: 'job456',
          checkInTime: DateTime.now(),
          startTime: DateTime.now(),
          type: TimeRecordType.self,
          status: TimeRecordStatus.inProgress,
        );
        timekeepingProvider.addTimeRecord(staff1Record);
        timekeepingProvider.addTimeRecord(staff2Record);

        // Act
        final staff1Records = timekeepingProvider.getTimeRecordsForStaff('staff1');

        // Assert
        expect(staff1Records, contains(staff1Record));
        expect(staff1Records, isNot(contains(staff2Record)));
        expect(staff1Records.length, equals(1));
      });

      test('should calculate total hours correctly', () {
        // Arrange
        final record1 = TimeRecord(
          id: 'record1',
          staffId: 'staff123',
          jobId: 'job123',
          checkInTime: DateTime(2023, 12, 25, 9, 0),
          checkOutTime: DateTime(2023, 12, 25, 17, 0),
          startTime: DateTime(2023, 12, 25, 9, 0),
          endTime: DateTime(2023, 12, 25, 17, 0),
          type: TimeRecordType.self,
          status: TimeRecordStatus.completed,
        );
        final record2 = TimeRecord(
          id: 'record2',
          staffId: 'staff123',
          jobId: 'job456',
          checkInTime: DateTime(2023, 12, 26, 8, 0),
          checkOutTime: DateTime(2023, 12, 26, 12, 0),
          startTime: DateTime(2023, 12, 26, 8, 0),
          endTime: DateTime(2023, 12, 26, 12, 0),
          type: TimeRecordType.self,
          status: TimeRecordStatus.completed,
        );
        timekeepingProvider.addTimeRecord(record1);
        timekeepingProvider.addTimeRecord(record2);

        // Act
        final totalHours = timekeepingProvider.getTotalHoursForStaff('staff123');

        // Assert
        expect(totalHours, equals(12.0)); // 8 hours + 4 hours
      });
    });
  });
}
