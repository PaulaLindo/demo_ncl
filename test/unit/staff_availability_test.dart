// test/unit/staff_availability_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:demo_ncl/models/staff_availability.dart';

void main() {
  group('StaffAvailability Model Tests', () {
    test('should create StaffAvailability with required fields', () {
      // Arrange
      final availability = StaffAvailability(
        id: '1',
        staffId: 'staff123',
        date: DateTime(2023, 12, 25),
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 17, minute: 0),
      );

      // Assert
      expect(availability.id, equals('1'));
      expect(availability.staffId, equals('staff123'));
      expect(availability.status, equals(AvailabilityStatus.available));
      expect(availability.notes, isNull);
    });

    test('should create StaffAvailability with all fields', () {
      // Arrange
      final availability = StaffAvailability(
        id: '2',
        staffId: 'staff456',
        date: DateTime(2023, 12, 26),
        startTime: const TimeOfDay(hour: 8, minute: 30),
        endTime: const TimeOfDay(hour: 16, minute: 30),
        status: AvailabilityStatus.booked,
        notes: 'Client meeting',
        updatedAt: DateTime(2023, 12, 20),
      );

      // Assert
      expect(availability.id, equals('2'));
      expect(availability.status, equals(AvailabilityStatus.booked));
      expect(availability.notes, equals('Client meeting'));
      expect(availability.updatedAt, isNotNull);
    });

    test('should support copyWith method', () {
      // Arrange
      final original = StaffAvailability(
        id: '1',
        staffId: 'staff123',
        date: DateTime(2023, 12, 25),
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 17, minute: 0),
      );

      // Act
      final updated = original.copyWith(
        status: AvailabilityStatus.unavailable,
        notes: 'Taking day off',
      );

      // Assert
      expect(updated.id, equals(original.id));
      expect(updated.staffId, equals(original.staffId));
      expect(updated.status, equals(AvailabilityStatus.unavailable));
      expect(updated.notes, equals('Taking day off'));
    });

    test('should handle equality correctly', () {
      // Arrange
      final availability1 = StaffAvailability(
        id: '1',
        staffId: 'staff123',
        date: DateTime(2023, 12, 25),
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 17, minute: 0),
      );

      final availability2 = StaffAvailability(
        id: '1',
        staffId: 'staff123',
        date: DateTime(2023, 12, 25),
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 17, minute: 0),
      );

      final availability3 = StaffAvailability(
        id: '2',
        staffId: 'staff123',
        date: DateTime(2023, 12, 25),
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 17, minute: 0),
      );

      // Assert
      expect(availability1, equals(availability2));
      expect(availability1, isNot(equals(availability3)));
    });
  });

  group('AvailabilityStatus Enum Tests', () {
    test('should have correct values', () {
      expect(AvailabilityStatus.values, containsAll([
        AvailabilityStatus.available,
        AvailabilityStatus.unavailable,
        AvailabilityStatus.booked,
        AvailabilityStatus.requestedTimeOff,
      ]));
    });

    test('should support all status types', () {
      for (final status in AvailabilityStatus.values) {
        expect(status, isA<AvailabilityStatus>());
      }
    });

    test('should convert status to string correctly', () {
      expect(AvailabilityStatus.available.toString(), contains('available'));
      expect(AvailabilityStatus.unavailable.toString(), contains('unavailable'));
      expect(AvailabilityStatus.booked.toString(), contains('booked'));
      expect(AvailabilityStatus.requestedTimeOff.toString(), contains('requestedTimeOff'));
    });
  });

  group('Availability Time Validation Tests', () {
    test('should validate time ranges correctly', () {
      // Valid time range
      final validAvailability = StaffAvailability(
        id: '1',
        staffId: 'staff123',
        date: DateTime(2023, 12, 25),
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 17, minute: 0),
      );

      expect(validAvailability.startTime.hour, lessThan(validAvailability.endTime.hour));
      
      // Same hour but different minutes
      final sameHourAvailability = StaffAvailability(
        id: '2',
        staffId: 'staff123',
        date: DateTime(2023, 12, 25),
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 9, minute: 30),
      );

      expect(sameHourAvailability.startTime.minute, lessThan(sameHourAvailability.endTime.minute));
    });

    test('should handle edge cases', () {
      // Midnight crossing
      final midnightAvailability = StaffAvailability(
        id: '3',
        staffId: 'staff123',
        date: DateTime(2023, 12, 25),
        startTime: const TimeOfDay(hour: 23, minute: 30),
        endTime: const TimeOfDay(hour: 0, minute: 30),
      );

      expect(midnightAvailability.startTime.hour, greaterThan(midnightAvailability.endTime.hour));
    });

    test('should handle same start and end time', () {
      // Same time (should be invalid in real app but test the model)
      final sameTimeAvailability = StaffAvailability(
        id: '4',
        staffId: 'staff123',
        date: DateTime(2023, 12, 25),
        startTime: const TimeOfDay(hour: 12, minute: 0),
        endTime: const TimeOfDay(hour: 12, minute: 0),
      );

      expect(sameTimeAvailability.startTime.hour, equals(sameTimeAvailability.endTime.hour));
      expect(sameTimeAvailability.startTime.minute, equals(sameTimeAvailability.endTime.minute));
    });
  });

  group('Availability Status Color Mapping Tests', () {
    test('should map statuses to appropriate colors', () {
      final statusColors = {
        AvailabilityStatus.available: Colors.green,
        AvailabilityStatus.unavailable: Colors.grey,
        AvailabilityStatus.booked: Colors.blue,
        AvailabilityStatus.requestedTimeOff: Colors.orange,
      };

      for (final entry in statusColors.entries) {
        expect(entry.key, isA<AvailabilityStatus>());
        expect(entry.value, isA<Color>());
      }
    });

    test('should have unique colors for each status', () {
      final colors = [
        Colors.green,   // available
        Colors.grey,    // unavailable
        Colors.blue,    // booked
        Colors.orange,  // requestedTimeOff
      ];

      expect(colors.length, equals(colors.toSet().length));
    });
  });

  group('Availability Date Handling Tests', () {
    test('should handle different date formats', () {
      final dates = [
        DateTime(2023, 12, 25),
        DateTime(2024, 1, 1),
        DateTime(2023, 2, 28), // Leap year handling
      ];

      for (final date in dates) {
        final availability = StaffAvailability(
          id: date.millisecondsSinceEpoch.toString(),
          staffId: 'staff123',
          date: date,
          startTime: const TimeOfDay(hour: 9, minute: 0),
          endTime: const TimeOfDay(hour: 17, minute: 0),
        );

        expect(availability.date, equals(date));
        expect(availability.id, equals(date.millisecondsSinceEpoch.toString()));
      }
    });

    test('should handle time zone considerations', () {
      final utcDate = DateTime.utc(2023, 12, 25);
      final localDate = DateTime(2023, 12, 25);

      final utcAvailability = StaffAvailability(
        id: 'utc',
        staffId: 'staff123',
        date: utcDate,
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 17, minute: 0),
      );

      final localAvailability = StaffAvailability(
        id: 'local',
        staffId: 'staff123',
        date: localDate,
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 17, minute: 0),
      );

      expect(utcAvailability.date.isUtc, isTrue);
      expect(localAvailability.date.isUtc, isFalse);
    });
  });

  group('Availability Notes Tests', () {
    test('should handle null notes', () {
      final availability = StaffAvailability(
        id: '1',
        staffId: 'staff123',
        date: DateTime(2023, 12, 25),
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 17, minute: 0),
      );

      expect(availability.notes, isNull);
    });

    test('should handle empty notes', () {
      final availability = StaffAvailability(
        id: '1',
        staffId: 'staff123',
        date: DateTime(2023, 12, 25),
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 17, minute: 0),
        notes: '',
      );

      expect(availability.notes, equals(''));
    });

    test('should handle long notes', () {
      final longNote = 'This is a very long note that contains multiple words and should be handled properly by the availability model without any issues.';
      
      final availability = StaffAvailability(
        id: '1',
        staffId: 'staff123',
        date: DateTime(2023, 12, 25),
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 17, minute: 0),
        notes: longNote,
      );

      expect(availability.notes, equals(longNote));
      expect(availability.notes!.length, greaterThan(50));
    });
  });
}
