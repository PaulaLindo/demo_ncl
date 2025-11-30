// test/unit/booking_flow_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:demo_ncl/models/booking_model.dart';

void main() {
  group('Booking Model Tests', () {
    test('should create Booking with required fields', () {
      // Arrange
      final booking = Booking(
        id: '1',
        serviceId: 'service123',
        serviceName: 'Standard Cleaning',
        customerId: 'customer123',
        bookingDate: DateTime(2023, 12, 25),
        timePreference: TimeOfDayPreference.morning,
        propertySize: PropertySize.medium,
        frequency: BookingFrequency.oneTime,
        status: BookingStatus.pending,
        address: '123 Main St',
        basePrice: 100.0,
        createdAt: DateTime(2023, 12, 20),
        startTime: DateTime(2023, 12, 25, 9, 0),
        endTime: DateTime(2023, 12, 25, 11, 0),
      );

      // Assert
      expect(booking.id, equals('1'));
      expect(booking.serviceId, equals('service123'));
      expect(booking.serviceName, equals('Standard Cleaning'));
      expect(booking.status, equals(BookingStatus.pending));
      expect(booking.basePrice, equals(100.0));
    });

    test('should create Booking with all fields', () {
      // Arrange
      final booking = Booking(
        id: '2',
        serviceId: 'service456',
        serviceName: 'Deep Cleaning',
        customerId: 'customer456',
        bookingDate: DateTime(2023, 12, 26),
        timePreference: TimeOfDayPreference.afternoon,
        propertySize: PropertySize.large,
        frequency: BookingFrequency.weekly,
        specialInstructions: 'Please focus on kitchen',
        address: '123 Main St',
        status: BookingStatus.confirmed,
        basePrice: 200.0,
        createdAt: DateTime(2023, 12, 20),
        updatedAt: DateTime(2023, 12, 21),
        startTime: DateTime(2023, 12, 26, 14, 0),
        endTime: DateTime(2023, 12, 26, 18, 0),
        finalPrice: 240.0,
      );

      // Assert
      expect(booking.id, equals('2'));
      expect(booking.specialInstructions, equals('Please focus on kitchen'));
      expect(booking.address, equals('123 Main St'));
      expect(booking.status, equals(BookingStatus.confirmed));
      expect(booking.updatedAt, isNotNull);
      expect(booking.finalPrice, equals(240.0));
    });

    test('should support copyWith method', () {
      // Arrange
      final original = Booking(
        id: '1',
        serviceId: 'service123',
        serviceName: 'Standard Cleaning',
        customerId: 'customer123',
        bookingDate: DateTime(2023, 12, 25),
        timePreference: TimeOfDayPreference.morning,
        propertySize: PropertySize.medium,
        frequency: BookingFrequency.oneTime,
        status: BookingStatus.pending,
        address: '123 Main St',
        basePrice: 100.0,
        createdAt: DateTime(2023, 12, 20),
        startTime: DateTime(2023, 12, 25, 9, 0),
        endTime: DateTime(2023, 12, 25, 11, 0),
      );

      // Act
      final updated = original.copyWith(
        status: BookingStatus.confirmed,
        specialInstructions: 'Updated instructions',
      );

      // Assert
      expect(updated.id, equals(original.id));
      expect(updated.status, equals(BookingStatus.confirmed));
      expect(updated.specialInstructions, equals('Updated instructions'));
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

    test('should support all status types', () {
      for (final status in BookingStatus.values) {
        expect(status, isA<BookingStatus>());
      }
    });

    test('should convert status to string correctly', () {
      expect(BookingStatus.pending.toString(), contains('pending'));
      expect(BookingStatus.confirmed.toString(), contains('confirmed'));
      expect(BookingStatus.completed.toString(), contains('completed'));
      expect(BookingStatus.cancelled.toString(), contains('cancelled'));
    });
  });

  group('TimeOfDayPreference Enum Tests', () {
    test('should have correct display names and time ranges', () {
      expect(TimeOfDayPreference.morning.displayName, equals('Morning'));
      expect(TimeOfDayPreference.morning.timeRange, equals('08:00 - 12:00'));
      
      expect(TimeOfDayPreference.afternoon.displayName, equals('Afternoon'));
      expect(TimeOfDayPreference.afternoon.timeRange, equals('12:00 - 16:00'));
      
      expect(TimeOfDayPreference.evening.displayName, equals('Evening'));
      expect(TimeOfDayPreference.evening.timeRange, equals('16:00 - 20:00'));
      
      expect(TimeOfDayPreference.flexible.displayName, equals('Flexible'));
      expect(TimeOfDayPreference.flexible.timeRange, equals('Anytime'));
    });

    test('should support all time preferences', () {
      for (final preference in TimeOfDayPreference.values) {
        expect(preference.displayName, isA<String>());
        expect(preference.timeRange, isA<String>());
      }
    });
  });

  group('PropertySize Enum Tests', () {
    test('should have correct display names and price multipliers', () {
      expect(PropertySize.small.displayName, equals('Small (1-2 rooms)'));
      expect(PropertySize.small.priceMultiplier, equals(1.0));
      
      expect(PropertySize.medium.displayName, equals('Medium (3-4 rooms)'));
      expect(PropertySize.medium.priceMultiplier, equals(1.5));
      
      expect(PropertySize.large.displayName, equals('Large (5+ rooms)'));
      expect(PropertySize.large.priceMultiplier, equals(2.0));
    });

    test('should support all property sizes', () {
      for (final size in PropertySize.values) {
        expect(size.displayName, isA<String>());
        expect(size.priceMultiplier, isA<double>());
        expect(size.priceMultiplier, greaterThan(0));
      }
    });

    test('should have logical price progression', () {
      expect(PropertySize.small.priceMultiplier, lessThan(PropertySize.medium.priceMultiplier));
      expect(PropertySize.medium.priceMultiplier, lessThan(PropertySize.large.priceMultiplier));
    });
  });

  group('BookingFrequency Enum Tests', () {
    test('should have correct display names and discount multipliers', () {
      expect(BookingFrequency.oneTime.displayName, equals('One-time'));
      expect(BookingFrequency.oneTime.discountMultiplier, equals(1.0));
      
      expect(BookingFrequency.weekly.displayName, equals('Weekly'));
      expect(BookingFrequency.weekly.discountMultiplier, equals(0.9));
      
      expect(BookingFrequency.biWeekly.displayName, equals('Bi-weekly'));
      expect(BookingFrequency.biWeekly.discountMultiplier, equals(0.85));
      
      expect(BookingFrequency.monthly.displayName, equals('Monthly'));
      expect(BookingFrequency.monthly.discountMultiplier, equals(0.8));
    });

    test('should support all booking frequencies', () {
      for (final frequency in BookingFrequency.values) {
        expect(frequency.displayName, isA<String>());
        expect(frequency.discountMultiplier, isA<double>());
        expect(frequency.discountMultiplier, greaterThan(0));
        expect(frequency.discountMultiplier, lessThanOrEqualTo(1.0));
      }
    });

    test('should have logical discount progression', () {
      expect(BookingFrequency.oneTime.discountMultiplier, greaterThan(BookingFrequency.weekly.discountMultiplier));
      expect(BookingFrequency.weekly.discountMultiplier, greaterThan(BookingFrequency.biWeekly.discountMultiplier));
      expect(BookingFrequency.biWeekly.discountMultiplier, greaterThan(BookingFrequency.monthly.discountMultiplier));
    });
  });

  group('Booking Price Calculation Tests', () {
    test('should calculate base price correctly', () {
      final basePrice = 100.0;
      final sizeMultiplier = PropertySize.medium.priceMultiplier;
      final frequencyMultiplier = BookingFrequency.oneTime.discountMultiplier;
      
      final expectedPrice = basePrice * sizeMultiplier * frequencyMultiplier;
      expect(expectedPrice, equals(150.0));
    });

    test('should apply frequency discounts correctly', () {
      final basePrice = 100.0;
      final sizeMultiplier = PropertySize.medium.priceMultiplier;
      
      // One-time: no discount
      final oneTimePrice = basePrice * sizeMultiplier * BookingFrequency.oneTime.discountMultiplier;
      expect(oneTimePrice, equals(150.0));
      
      // Weekly: 10% discount
      final weeklyPrice = basePrice * sizeMultiplier * BookingFrequency.weekly.discountMultiplier;
      expect(weeklyPrice, equals(135.0));
      
      // Monthly: 20% discount
      final monthlyPrice = basePrice * sizeMultiplier * BookingFrequency.monthly.discountMultiplier;
      expect(monthlyPrice, equals(120.0));
    });

    test('should apply property size multipliers correctly', () {
      final basePrice = 100.0;
      final frequencyMultiplier = BookingFrequency.oneTime.discountMultiplier;
      
      // Small: 1.0x
      final smallPrice = basePrice * PropertySize.small.priceMultiplier * frequencyMultiplier;
      expect(smallPrice, equals(100.0));
      
      // Medium: 1.5x
      final mediumPrice = basePrice * PropertySize.medium.priceMultiplier * frequencyMultiplier;
      expect(mediumPrice, equals(150.0));
      
      // Large: 2.0x
      final largePrice = basePrice * PropertySize.large.priceMultiplier * frequencyMultiplier;
      expect(largePrice, equals(200.0));
    });
  });

  group('Booking Date and Time Tests', () {
    test('should handle different date formats', () {
      final dates = [
        DateTime(2023, 12, 25),
        DateTime(2024, 1, 1),
        DateTime(2023, 2, 28), // Leap year handling
      ];

      for (final date in dates) {
        final booking = Booking(
          id: date.millisecondsSinceEpoch.toString(),
          serviceId: 'service123',
          serviceName: 'Test Service',
          customerId: 'customer123',
          bookingDate: date,
          timePreference: TimeOfDayPreference.morning,
          propertySize: PropertySize.medium,
          frequency: BookingFrequency.oneTime,
          status: BookingStatus.pending,
          address: '123 Main St',
          basePrice: 100.0,
          createdAt: DateTime(2023, 12, 20),
          startTime: date,
          endTime: date.add(const Duration(hours: 2)),
        );

        expect(booking.bookingDate, equals(date));
        expect(booking.startTime, equals(date));
        expect(booking.endTime, equals(date.add(const Duration(hours: 2))));
      }
    });

    test('should handle time zones correctly', () {
      final utcDate = DateTime.utc(2023, 12, 25);
      final localDate = DateTime(2023, 12, 25);

      final utcBooking = Booking(
        id: 'utc',
        serviceId: 'service123',
        serviceName: 'Test Service',
        customerId: 'customer123',
        bookingDate: utcDate,
        timePreference: TimeOfDayPreference.morning,
        propertySize: PropertySize.medium,
        frequency: BookingFrequency.oneTime,
        status: BookingStatus.pending,
        address: '123 Main St',
        basePrice: 100.0,
        createdAt: DateTime.utc(2023, 12, 20),
        startTime: utcDate,
        endTime: utcDate.add(const Duration(hours: 2)),
      );

      final localBooking = Booking(
        id: 'local',
        serviceId: 'service123',
        serviceName: 'Test Service',
        customerId: 'customer123',
        bookingDate: localDate,
        timePreference: TimeOfDayPreference.morning,
        propertySize: PropertySize.medium,
        frequency: BookingFrequency.oneTime,
        status: BookingStatus.pending,
        address: '123 Main St',
        basePrice: 100.0,
        createdAt: DateTime(2023, 12, 20),
        startTime: localDate,
        endTime: localDate.add(const Duration(hours: 2)),
      );

      expect(utcBooking.bookingDate.isUtc, isTrue);
      expect(localBooking.bookingDate.isUtc, isFalse);
    });
  });

  group('Booking Status Transitions Tests', () {
    test('should support valid status transitions', () {
      final booking = Booking(
        id: '1',
        serviceId: 'service123',
        serviceName: 'Test Service',
        customerId: 'customer123',
        bookingDate: DateTime(2023, 12, 25),
        timePreference: TimeOfDayPreference.morning,
        propertySize: PropertySize.medium,
        frequency: BookingFrequency.oneTime,
        status: BookingStatus.pending,
        address: '123 Main St',
        basePrice: 100.0,
        createdAt: DateTime(2023, 12, 20),
        startTime: DateTime(2023, 12, 25),
        endTime: DateTime(2023, 12, 25, 2),
      );

      // Valid transitions
      final confirmed = booking.copyWith(status: BookingStatus.confirmed);
      expect(confirmed.status, equals(BookingStatus.confirmed));

      final inProgress = confirmed.copyWith(status: BookingStatus.inProgress);
      expect(inProgress.status, equals(BookingStatus.inProgress));

      final completed = inProgress.copyWith(status: BookingStatus.completed);
      expect(completed.status, equals(BookingStatus.completed));

      final cancelled = booking.copyWith(status: BookingStatus.cancelled);
      expect(cancelled.status, equals(BookingStatus.cancelled));
    });
  });

  group('Booking Special Instructions Tests', () {
    test('should handle null special instructions', () {
      final booking = Booking(
        id: '1',
        serviceId: 'service123',
        serviceName: 'Test Service',
        customerId: 'customer123',
        bookingDate: DateTime(2023, 12, 25),
        timePreference: TimeOfDayPreference.morning,
        propertySize: PropertySize.medium,
        frequency: BookingFrequency.oneTime,
        status: BookingStatus.pending,
        address: '123 Main St',
        basePrice: 100.0,
        createdAt: DateTime(2023, 12, 20),
        startTime: DateTime(2023, 12, 25),
        endTime: DateTime(2023, 12, 25, 2),
      );

      expect(booking.specialInstructions, isNull);
    });

    test('should handle empty special instructions', () {
      final booking = Booking(
        id: '1',
        serviceId: 'service123',
        serviceName: 'Test Service',
        customerId: 'customer123',
        bookingDate: DateTime(2023, 12, 25),
        timePreference: TimeOfDayPreference.morning,
        propertySize: PropertySize.medium,
        frequency: BookingFrequency.oneTime,
        status: BookingStatus.pending,
        specialInstructions: '',
        address: '123 Main St',
        basePrice: 100.0,
        createdAt: DateTime(2023, 12, 20),
        startTime: DateTime(2023, 12, 25),
        endTime: DateTime(2023, 12, 25, 2),
      );

      expect(booking.specialInstructions, equals(''));
    });

    test('should handle long special instructions', () {
      final longInstructions = 'This is a very long set of special instructions that contains multiple words and should be handled properly by the booking model without any issues.';
      
      final booking = Booking(
        id: '1',
        serviceId: 'service123',
        serviceName: 'Test Service',
        customerId: 'customer123',
        bookingDate: DateTime(2023, 12, 25),
        timePreference: TimeOfDayPreference.morning,
        propertySize: PropertySize.medium,
        frequency: BookingFrequency.oneTime,
        status: BookingStatus.pending,
        specialInstructions: longInstructions,
        address: '123 Main St',
        basePrice: 100.0,
        createdAt: DateTime(2023, 12, 20),
        startTime: DateTime(2023, 12, 25),
        endTime: DateTime(2023, 12, 25, 2),
      );

      expect(booking.specialInstructions, equals(longInstructions));
      expect(booking.specialInstructions!.length, greaterThan(50));
    });
  });
}
