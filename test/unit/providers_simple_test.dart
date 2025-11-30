// test/unit/providers_simple_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_ncl/providers/auth_provider.dart';
import 'package:demo_ncl/providers/booking_provider.dart';
import 'package:demo_ncl/models/auth_model.dart';
import 'package:demo_ncl/models/booking_model.dart';

void main() {
  group('Simple Provider Tests', () {
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

      test('should cancel booking correctly', () async {
        // Arrange
        final booking = Booking(
          id: 'booking1',
          customerId: 'customer1',
          serviceId: 'service1',
          serviceName: 'Test Service',
          bookingDate: DateTime.now().add(const Duration(days: 1)),
          timePreference: TimeOfDayPreference.morning,
          address: '123 Test St',
          status: BookingStatus.confirmed,
          basePrice: 100.0,
          propertySize: PropertySize.medium,
          frequency: BookingFrequency.oneTime,
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 2)),
          createdAt: DateTime.now(),
        );
        await bookingProvider.addBooking(booking);

        // Act - use the actual booking ID from the created booking
        final createdBooking = bookingProvider.bookings.first;
        await bookingProvider.cancelBooking(createdBooking.id, reason: 'Customer requested cancellation');

        // Assert
        final cancelledBooking = bookingProvider.bookings.first;
        expect(cancelledBooking.status, equals(BookingStatus.cancelled));
        expect(cancelledBooking.cancellationReason, equals('Customer requested cancellation'));
      });
    });
  });
}
