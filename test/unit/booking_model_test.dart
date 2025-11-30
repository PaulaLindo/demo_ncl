// test/unit/booking_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_ncl/models/booking_model.dart';

void main() {
  group('Booking Model Tests', () {
    group('BookingStatus Tests', () {
      test('should have correct enum values', () {
        expect(BookingStatus.pending.value, 'pending');
        expect(BookingStatus.confirmed.value, 'confirmed');
        expect(BookingStatus.inProgress.value, 'inProgress');
        expect(BookingStatus.completed.value, 'completed');
        expect(BookingStatus.cancelled.value, 'cancelled');
        expect(BookingStatus.rejected.value, 'rejected');
      });

      test('should have correct display names', () {
        expect(BookingStatus.pending.displayName, 'Pending');
        expect(BookingStatus.confirmed.displayName, 'Confirmed');
        expect(BookingStatus.inProgress.displayName, 'In Progress');
        expect(BookingStatus.completed.displayName, 'Completed');
        expect(BookingStatus.cancelled.displayName, 'Cancelled');
        expect(BookingStatus.rejected.displayName, 'Rejected');
      });
    });

    group('TimeOfDayPreference Tests', () {
      test('should have correct enum values', () {
        expect(TimeOfDayPreference.morning.displayName, 'Morning');
        expect(TimeOfDayPreference.morning.timeRange, '08:00 - 12:00');
        
        expect(TimeOfDayPreference.afternoon.displayName, 'Afternoon');
        expect(TimeOfDayPreference.afternoon.timeRange, '12:00 - 16:00');
        
        expect(TimeOfDayPreference.evening.displayName, 'Evening');
        expect(TimeOfDayPreference.evening.timeRange, '16:00 - 20:00');
        
        expect(TimeOfDayPreference.flexible.displayName, 'Flexible');
        expect(TimeOfDayPreference.flexible.timeRange, 'Anytime');
      });

      test('should have correct string values', () {
        expect(TimeOfDayPreference.morning.value, 'morning');
        expect(TimeOfDayPreference.afternoon.value, 'afternoon');
        expect(TimeOfDayPreference.evening.value, 'evening');
        expect(TimeOfDayPreference.flexible.value, 'flexible');
      });
    });

    group('PropertySize Tests', () {
      test('should have correct enum values', () {
        expect(PropertySize.small.displayName, 'Small (1-2 rooms)');
        expect(PropertySize.small.priceMultiplier, 1.0);
        
        expect(PropertySize.medium.displayName, 'Medium (3-4 rooms)');
        expect(PropertySize.medium.priceMultiplier, 1.5);
        
        expect(PropertySize.large.displayName, 'Large (5+ rooms)');
        expect(PropertySize.large.priceMultiplier, 2.0);
      });

      test('should have correct string values', () {
        expect(PropertySize.small.value, 'small');
        expect(PropertySize.medium.value, 'medium');
        expect(PropertySize.large.value, 'large');
      });
    });

    group('BookingFrequency Tests', () {
      test('should have correct enum values', () {
        expect(BookingFrequency.oneTime.displayName, 'One-time');
        expect(BookingFrequency.oneTime.discountMultiplier, 1.0);
        
        expect(BookingFrequency.weekly.displayName, 'Weekly');
        expect(BookingFrequency.weekly.discountMultiplier, 0.9);
        
        expect(BookingFrequency.biWeekly.displayName, 'Bi-weekly');
        expect(BookingFrequency.biWeekly.discountMultiplier, 0.85);
        
        expect(BookingFrequency.monthly.displayName, 'Monthly');
        expect(BookingFrequency.monthly.discountMultiplier, 0.8);
      });

      test('should have correct string values', () {
        expect(BookingFrequency.oneTime.value, 'oneTime');
        expect(BookingFrequency.weekly.value, 'weekly');
        expect(BookingFrequency.biWeekly.value, 'biWeekly');
        expect(BookingFrequency.monthly.value, 'monthly');
      });
    });

    group('Booking Tests', () {
      late Booking testBooking;

      setUp(() {
        testBooking = Booking(
          id: 'booking-123',
          customerId: 'user-123',
          serviceId: 'service-123',
          serviceName: 'Standard Cleaning',
          bookingDate: DateTime(2024, 1, 15),
          timePreference: TimeOfDayPreference.morning,
          address: '123 Test St',
          status: BookingStatus.confirmed,
          basePrice: 100.0,
          propertySize: PropertySize.medium,
          frequency: BookingFrequency.oneTime,
          startTime: DateTime(2024, 1, 15, 9),
          endTime: DateTime(2024, 1, 15, 11),
          createdAt: DateTime(2024, 1, 10),
        );
      });

      test('should create Booking with required fields', () {
        expect(testBooking.id, 'booking-123');
        expect(testBooking.customerId, 'user-123');
        expect(testBooking.serviceId, 'service-123');
        expect(testBooking.serviceName, 'Standard Cleaning');
        expect(testBooking.bookingDate, DateTime(2024, 1, 15));
        expect(testBooking.timePreference, TimeOfDayPreference.morning);
        expect(testBooking.address, '123 Test St');
        expect(testBooking.status, BookingStatus.confirmed);
        expect(testBooking.basePrice, 100.0);
        expect(testBooking.propertySize, PropertySize.medium);
        expect(testBooking.frequency, BookingFrequency.oneTime);
        expect(testBooking.startTime, DateTime(2024, 1, 15, 9));
        expect(testBooking.endTime, DateTime(2024, 1, 15, 11));
        expect(testBooking.createdAt, DateTime(2024, 1, 10));
        expect(testBooking.specialInstructions, isNull);
        expect(testBooking.assignedStaffId, isNull);
        expect(testBooking.assignedStaffName, isNull);
        expect(testBooking.updatedAt, isNull);
        expect(testBooking.cancellationReason, isNull);
        expect(testBooking.notes, isNull);
      });

      test('should create Booking with all fields', () {
        final now = DateTime.now();
        final booking = Booking(
          id: 'booking-456',
          customerId: 'user-456',
          serviceId: 'service-456',
          serviceName: 'Deep Cleaning',
          bookingDate: DateTime(2024, 2, 20),
          timePreference: TimeOfDayPreference.afternoon,
          address: '456 Test Ave',
          status: BookingStatus.inProgress,
          basePrice: 150.0,
          propertySize: PropertySize.large,
          frequency: BookingFrequency.weekly,
          startTime: DateTime(2024, 2, 20, 14),
          endTime: DateTime(2024, 2, 20, 16),
          specialInstructions: 'Please use eco-friendly products',
          assignedStaffId: 'staff-123',
          assignedStaffName: 'John Doe',
          createdAt: DateTime(2024, 2, 15),
          updatedAt: now,
          cancellationReason: null,
          notes: 'Customer prefers afternoon slots',
        );

        expect(booking.id, 'booking-456');
        expect(booking.specialInstructions, 'Please use eco-friendly products');
        expect(booking.assignedStaffId, 'staff-123');
        expect(booking.assignedStaffName, 'John Doe');
        expect(booking.updatedAt, now);
        expect(booking.notes, 'Customer prefers afternoon slots');
      });

      test('should calculate final price correctly', () {
        // When finalPrice is not provided, it should be null
        expect(testBooking.finalPrice, isNull);
        
        // Use copyWith to calculate finalPrice
        final bookingWithPrice = testBooking.copyWith();
        expect(bookingWithPrice.finalPrice, 150.0); // 100 * 1.5 * 1.0
      });

      test('should calculate final price with different sizes and frequencies', () {
        // Small, One-time: 100.0 * 1.0 * 1.0 = 100.0
        final smallBooking = testBooking.copyWith(
          propertySize: PropertySize.small,
          frequency: BookingFrequency.oneTime,
        );
        expect(smallBooking.finalPrice, 100.0);

        // Large, Weekly: 100.0 * 2.0 * 0.9 = 180.0
        final largeWeeklyBooking = testBooking.copyWith(
          propertySize: PropertySize.large,
          frequency: BookingFrequency.weekly,
        );
        expect(largeWeeklyBooking.finalPrice, 180.0);

        // Medium, Monthly: 100.0 * 1.5 * 0.8 = 120.0
        final mediumMonthlyBooking = testBooking.copyWith(
          propertySize: PropertySize.medium,
          frequency: BookingFrequency.monthly,
        );
        expect(mediumMonthlyBooking.finalPrice, 120.0);
      });

      test('should check if booking is upcoming', () {
        final now = DateTime.now();
        final upcomingBooking = Booking(
          id: 'booking-1',
          customerId: 'user-1',
          serviceId: 'service-1',
          serviceName: 'Service',
          bookingDate: now.add(const Duration(days: 1)),
          timePreference: TimeOfDayPreference.morning,
          address: '123 Test St',
          status: BookingStatus.confirmed,
          basePrice: 100.0,
          propertySize: PropertySize.medium,
          frequency: BookingFrequency.oneTime,
          startTime: now.add(const Duration(days: 1, hours: 9)),
          endTime: now.add(const Duration(days: 1, hours: 11)),
          createdAt: now,
        );

        final pastBooking = Booking(
          id: 'booking-2',
          customerId: 'user-2',
          serviceId: 'service-2',
          serviceName: 'Service',
          bookingDate: now.subtract(const Duration(days: 1)),
          timePreference: TimeOfDayPreference.morning,
          address: '123 Test St',
          status: BookingStatus.confirmed,
          basePrice: 100.0,
          propertySize: PropertySize.medium,
          frequency: BookingFrequency.oneTime,
          startTime: now.subtract(const Duration(days: 1, hours: 9)),
          endTime: now.subtract(const Duration(days: 1, hours: 11)),
          createdAt: now.subtract(const Duration(days: 2)),
        );

        expect(upcomingBooking.isUpcoming, true);
        expect(pastBooking.isUpcoming, false);
      });

      test('should check if booking is in progress', () {
        final now = DateTime.now();
        final inProgressBooking = Booking(
          id: 'booking-1',
          customerId: 'user-1',
          serviceId: 'service-1',
          serviceName: 'Service',
          bookingDate: now.subtract(const Duration(hours: 1)),
          timePreference: TimeOfDayPreference.morning,
          address: '123 Test St',
          status: BookingStatus.inProgress,
          basePrice: 100.0,
          propertySize: PropertySize.medium,
          frequency: BookingFrequency.oneTime,
          startTime: now.subtract(const Duration(hours: 1)),
          endTime: now.add(const Duration(hours: 1)),
          createdAt: now.subtract(const Duration(days: 1)),
        );

        final notInProgressBooking = Booking(
          id: 'booking-2',
          customerId: 'user-2',
          serviceId: 'service-2',
          serviceName: 'Service',
          bookingDate: now.add(const Duration(days: 1)),
          timePreference: TimeOfDayPreference.morning,
          address: '123 Test St',
          status: BookingStatus.confirmed,
          basePrice: 100.0,
          propertySize: PropertySize.medium,
          frequency: BookingFrequency.oneTime,
          startTime: now.add(const Duration(days: 1, hours: 9)),
          endTime: now.add(const Duration(days: 1, hours: 11)),
          createdAt: now,
        );

        expect(inProgressBooking.isInProgress, true);
        expect(notInProgressBooking.isInProgress, false);
      });

      test('should check if booking is completed', () {
        final completedBooking = testBooking.copyWith(status: BookingStatus.completed);
        final notCompletedBooking = testBooking.copyWith(status: BookingStatus.confirmed);

        expect(completedBooking.isCompleted, true);
        expect(notCompletedBooking.isCompleted, false);
      });

      test('should check if booking is cancelled or rejected', () {
        final cancelledBooking = testBooking.copyWith(status: BookingStatus.cancelled);
        final rejectedBooking = testBooking.copyWith(status: BookingStatus.rejected);
        final activeBooking = testBooking.copyWith(status: BookingStatus.confirmed);

        expect(cancelledBooking.isCancelledOrRejected, true);
        expect(rejectedBooking.isCancelledOrRejected, true);
        expect(activeBooking.isCancelledOrRejected, false);
      });

      test('should create Booking from JSON', () {
        final json = {
          'id': 'booking-123',
          'customerId': 'user-123',
          'serviceId': 'service-123',
          'serviceName': 'Standard Cleaning',
          'bookingDate': '2024-01-15T00:00:00Z',
          'timePreference': 'morning',
          'address': '123 Test St',
          'status': 'confirmed',
          'basePrice': 100.0,
          'propertySize': 'medium',
          'frequency': 'oneTime',
          'startTime': '2024-01-15T09:00:00Z',
          'endTime': '2024-01-15T11:00:00Z',
          'createdAt': '2024-01-10T00:00:00Z',
          'specialInstructions': 'Use eco-friendly products',
          'assignedStaffId': 'staff-123',
          'assignedStaffName': 'John Doe',
          'updatedAt': '2024-01-12T00:00:00Z',
          'notes': 'Customer prefers morning slots',
          'finalPrice': 150.0,
        };

        final booking = Booking.fromJson(json);

        expect(booking.id, 'booking-123');
        expect(booking.customerId, 'user-123');
        expect(booking.serviceId, 'service-123');
        expect(booking.serviceName, 'Standard Cleaning');
        expect(booking.bookingDate, DateTime.parse('2024-01-15T00:00:00Z'));
        expect(booking.timePreference, TimeOfDayPreference.morning);
        expect(booking.address, '123 Test St');
        expect(booking.status, BookingStatus.confirmed);
        expect(booking.basePrice, 100.0);
        expect(booking.propertySize, PropertySize.medium);
        expect(booking.frequency, BookingFrequency.oneTime);
        expect(booking.startTime, DateTime.parse('2024-01-15T09:00:00Z'));
        expect(booking.endTime, DateTime.parse('2024-01-15T11:00:00Z'));
        expect(booking.createdAt, DateTime.parse('2024-01-10T00:00:00Z'));
        expect(booking.specialInstructions, 'Use eco-friendly products');
        expect(booking.assignedStaffId, 'staff-123');
        expect(booking.assignedStaffName, 'John Doe');
        expect(booking.updatedAt, DateTime.parse('2024-01-12T00:00:00Z'));
        expect(booking.notes, 'Customer prefers morning slots');
        expect(booking.finalPrice, 150.0);
      });

      test('should create Booking from JSON with minimal data', () {
        final json = {
          'id': 'booking-123',
          'customerId': 'user-123',
          'serviceId': 'service-123',
          'serviceName': 'Standard Cleaning',
          'bookingDate': '2024-01-15T00:00:00Z',
          'timePreference': 'morning',
          'address': '123 Test St',
          'status': 'confirmed',
          'basePrice': 100.0,
          'propertySize': 'medium',
          'frequency': 'oneTime',
          'createdAt': '2024-01-10T00:00:00Z',
        };

        final booking = Booking.fromJson(json);

        expect(booking.id, 'booking-123');
        expect(booking.specialInstructions, isNull);
        expect(booking.assignedStaffId, isNull);
        expect(booking.assignedStaffName, isNull);
        expect(booking.updatedAt, isNull);
        expect(booking.notes, isNull);
        // Final price should be calculated
        expect(booking.finalPrice, 150.0); // 100 * 1.5 * 1.0
      });

      test('should convert Booking to JSON', () {
        final booking = Booking(
          id: 'booking-123',
          customerId: 'user-123',
          serviceId: 'service-123',
          serviceName: 'Standard Cleaning',
          bookingDate: DateTime.parse('2024-01-15T00:00:00Z'),
          timePreference: TimeOfDayPreference.morning,
          address: '123 Test St',
          status: BookingStatus.confirmed,
          basePrice: 100.0,
          propertySize: PropertySize.medium,
          frequency: BookingFrequency.oneTime,
          startTime: DateTime.parse('2024-01-15T09:00:00Z'),
          endTime: DateTime.parse('2024-01-15T11:00:00Z'),
          createdAt: DateTime.parse('2024-01-10T00:00:00Z'),
          specialInstructions: 'Use eco-friendly products',
          assignedStaffId: 'staff-123',
          assignedStaffName: 'John Doe',
          updatedAt: DateTime.parse('2024-01-12T00:00:00Z'),
          notes: 'Customer prefers morning slots',
          finalPrice: 150.0, // Provide finalPrice explicitly
        );

        final json = booking.toJson();

        expect(json['id'], 'booking-123');
        expect(json['customerId'], 'user-123');
        expect(json['serviceId'], 'service-123');
        expect(json['serviceName'], 'Standard Cleaning');
        expect(json['bookingDate'], '2024-01-15T00:00:00.000Z');
        expect(json['timePreference'], 'morning');
        expect(json['address'], '123 Test St');
        expect(json['status'], 'confirmed');
        expect(json['basePrice'], 100.0);
        expect(json['propertySize'], 'medium');
        expect(json['frequency'], 'oneTime');
        expect(json['startTime'], '2024-01-15T09:00:00.000Z');
        expect(json['endTime'], '2024-01-15T11:00:00.000Z');
        expect(json['createdAt'], '2024-01-10T00:00:00.000Z');
        expect(json['specialInstructions'], 'Use eco-friendly products');
        expect(json['assignedStaffId'], 'staff-123');
        expect(json['assignedStaffName'], 'John Doe');
        expect(json['updatedAt'], '2024-01-12T00:00:00.000Z');
        expect(json['notes'], 'Customer prefers morning slots');
        expect(json['finalPrice'], 150.0);
      });

      test('should copy Booking with updates', () {
        final updatedBooking = testBooking.copyWith(
          status: BookingStatus.completed,
          assignedStaffId: 'staff-456',
          assignedStaffName: 'Jane Smith',
          notes: 'Job completed successfully',
        );

        expect(updatedBooking.id, testBooking.id); // Unchanged
        expect(updatedBooking.customerId, testBooking.customerId); // Unchanged
        expect(updatedBooking.status, BookingStatus.completed);
        expect(updatedBooking.assignedStaffId, 'staff-456');
        expect(updatedBooking.assignedStaffName, 'Jane Smith');
        expect(updatedBooking.notes, 'Job completed successfully');
        expect(updatedBooking.updatedAt, isNotNull); // Should be updated
      });

      test('should handle Booking equality', () {
        final booking1 = testBooking;
        final booking2 = Booking(
          id: 'booking-123',
          customerId: 'user-123',
          serviceId: 'service-123',
          serviceName: 'Standard Cleaning',
          bookingDate: DateTime(2024, 1, 15),
          timePreference: TimeOfDayPreference.morning,
          address: '123 Test St',
          status: BookingStatus.confirmed,
          basePrice: 100.0,
          propertySize: PropertySize.medium,
          frequency: BookingFrequency.oneTime,
          startTime: DateTime(2024, 1, 15, 9),
          endTime: DateTime(2024, 1, 15, 11),
          createdAt: DateTime(2024, 1, 10),
        );

        final booking3 = Booking(
          id: 'booking-456',
          customerId: 'user-123',
          serviceId: 'service-123',
          serviceName: 'Standard Cleaning',
          bookingDate: DateTime(2024, 1, 15),
          timePreference: TimeOfDayPreference.morning,
          address: '123 Test St',
          status: BookingStatus.confirmed,
          basePrice: 100.0,
          propertySize: PropertySize.medium,
          frequency: BookingFrequency.oneTime,
          startTime: DateTime(2024, 1, 15, 9),
          endTime: DateTime(2024, 1, 15, 11),
          createdAt: DateTime(2024, 1, 10),
        );

        expect(booking1, equals(booking2));
        expect(booking1, isNot(equals(booking3)));
      });

      test('should handle Booking toString', () {
        final result = testBooking.toString();
        expect(result, contains('Booking'));
        expect(result, contains('booking-123'));
        expect(result, contains('Standard Cleaning'));
        expect(result, contains('2024-01-15'));
        expect(result, contains('BookingStatus.confirmed'));
      });

      test('should calculate final price static method', () {
        final price1 = Booking.calculateFinalPrice(100.0, 1.0, 1.0);
        expect(price1, 100.0);

        final price2 = Booking.calculateFinalPrice(100.0, 1.5, 0.9);
        expect(price2, 135.0);

        final price3 = Booking.calculateFinalPrice(99.99, 2.0, 0.8);
        expect(price3, 160.0); // Rounded
      });
    });

    group('Integration Tests', () {
      test('should handle complete booking lifecycle', () {
        final now = DateTime.now();
        
        // Create a new booking
        var booking = Booking(
          id: 'booking-123',
          customerId: 'user-123',
          serviceId: 'service-123',
          serviceName: 'Standard Cleaning',
          bookingDate: now.add(const Duration(days: 1)),
          timePreference: TimeOfDayPreference.morning,
          address: '123 Test St',
          status: BookingStatus.pending,
          basePrice: 100.0,
          propertySize: PropertySize.medium,
          frequency: BookingFrequency.oneTime,
          startTime: now.add(const Duration(days: 1, hours: 9)),
          endTime: now.add(const Duration(days: 1, hours: 11)),
          createdAt: now,
        );

        // Confirm the booking
        booking = booking.copyWith(status: BookingStatus.confirmed);
        expect(booking.status, BookingStatus.confirmed);
        expect(booking.isUpcoming, true);

        // Assign staff
        booking = booking.copyWith(
          assignedStaffId: 'staff-123',
          assignedStaffName: 'John Doe',
        );
        expect(booking.assignedStaffId, 'staff-123');
        expect(booking.assignedStaffName, 'John Doe');

        // Start the job
        booking = booking.copyWith(status: BookingStatus.inProgress);
        expect(booking.status, BookingStatus.inProgress);
        expect(booking.isInProgress, true);

        // Complete the job
        booking = booking.copyWith(status: BookingStatus.completed);
        expect(booking.status, BookingStatus.completed);
        expect(booking.isCompleted, true);
        expect(booking.isUpcoming, false);
      });

      test('should handle JSON serialization round trip', () {
        final originalBooking = Booking(
          id: 'booking-123',
          customerId: 'user-123',
          serviceId: 'service-123',
          serviceName: 'Deep Cleaning',
          bookingDate: DateTime.parse('2024-01-15T00:00:00Z'),
          timePreference: TimeOfDayPreference.afternoon,
          address: '456 Test Ave',
          status: BookingStatus.confirmed,
          basePrice: 150.0,
          propertySize: PropertySize.large,
          frequency: BookingFrequency.weekly,
          startTime: DateTime.parse('2024-01-15T14:00:00Z'),
          endTime: DateTime.parse('2024-01-15T16:00:00Z'),
          createdAt: DateTime.parse('2024-01-10T00:00:00Z'),
          specialInstructions: 'Use eco-friendly products',
          assignedStaffId: 'staff-123',
          assignedStaffName: 'John Doe',
          updatedAt: DateTime.parse('2024-01-12T00:00:00Z'),
          notes: 'Customer prefers afternoon slots',
          finalPrice: 270.0, // 150 * 2.0 * 0.9 = 270
        );

        // Convert to JSON
        final json = originalBooking.toJson();

        // Convert back from JSON
        final restoredBooking = Booking.fromJson(json);

        // Verify all fields match
        expect(restoredBooking, equals(originalBooking));
        expect(restoredBooking.id, originalBooking.id);
        expect(restoredBooking.customerId, originalBooking.customerId);
        expect(restoredBooking.serviceId, originalBooking.serviceId);
        expect(restoredBooking.serviceName, originalBooking.serviceName);
        expect(restoredBooking.bookingDate, originalBooking.bookingDate);
        expect(restoredBooking.timePreference, originalBooking.timePreference);
        expect(restoredBooking.address, originalBooking.address);
        expect(restoredBooking.status, originalBooking.status);
        expect(restoredBooking.basePrice, originalBooking.basePrice);
        expect(restoredBooking.propertySize, originalBooking.propertySize);
        expect(restoredBooking.frequency, originalBooking.frequency);
        expect(restoredBooking.specialInstructions, originalBooking.specialInstructions);
        expect(restoredBooking.assignedStaffId, originalBooking.assignedStaffId);
        expect(restoredBooking.assignedStaffName, originalBooking.assignedStaffName);
        expect(restoredBooking.updatedAt, originalBooking.updatedAt);
        expect(restoredBooking.notes, originalBooking.notes);
        expect(restoredBooking.finalPrice, originalBooking.finalPrice);
      });

      test('should handle cancelled booking', () {
        final booking = Booking(
          id: 'booking-123',
          customerId: 'user-123',
          serviceId: 'service-123',
          serviceName: 'Standard Cleaning',
          bookingDate: DateTime.now().add(const Duration(days: 1)),
          timePreference: TimeOfDayPreference.morning,
          address: '123 Test St',
          status: BookingStatus.confirmed,
          basePrice: 100.0,
          propertySize: PropertySize.medium,
          frequency: BookingFrequency.oneTime,
          startTime: DateTime.now().add(const Duration(days: 1, hours: 9)),
          endTime: DateTime.now().add(const Duration(days: 1, hours: 11)),
          createdAt: DateTime.now(),
        );

        // Cancel the booking
        final cancelledBooking = booking.copyWith(
          status: BookingStatus.cancelled,
          cancellationReason: 'Customer requested cancellation',
        );

        expect(cancelledBooking.status, BookingStatus.cancelled);
        expect(cancelledBooking.cancellationReason, 'Customer requested cancellation');
        expect(cancelledBooking.isCancelledOrRejected, true);
        expect(cancelledBooking.isUpcoming, false);
      });
    });
  });
}
