// test/unit/availability_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_ncl/models/availability_model.dart';

void main() {
  group('AvailabilityModel Tests', () {
    group('TimeSlot', () {
      test('should create TimeSlot with required properties', () {
        final startTime = DateTime(2024, 1, 15, 10, 0);
        final endTime = DateTime(2024, 1, 15, 12, 0);
        
        final timeSlot = TimeSlot(
          startTime: startTime,
          endTime: endTime,
          isAvailable: true,
          staffId: 'staff_1',
          staffName: 'John Doe',
          maxBookings: 2,
          currentBookings: 0,
        );

        expect(timeSlot.startTime, startTime);
        expect(timeSlot.endTime, endTime);
        expect(timeSlot.isAvailable, true);
        expect(timeSlot.staffId, 'staff_1');
        expect(timeSlot.staffName, 'John Doe');
        expect(timeSlot.maxBookings, 2);
        expect(timeSlot.currentBookings, 0);
      });

      test('should calculate duration correctly', () {
        final startTime = DateTime(2024, 1, 15, 10, 0);
        final endTime = DateTime(2024, 1, 15, 12, 0);
        
        final timeSlot = TimeSlot(
          startTime: startTime,
          endTime: endTime,
          isAvailable: true,
        );

        expect(timeSlot.duration.inHours, 2);
      });

      test('should format time range correctly', () {
        final startTime = DateTime(2024, 1, 15, 10, 0);
        final endTime = DateTime(2024, 1, 15, 12, 0);
        
        final timeSlot = TimeSlot(
          startTime: startTime,
          endTime: endTime,
          isAvailable: true,
        );

        expect(timeSlot.timeRange, '10:00 AM - 12:00 PM');
      });

      test('should format status text correctly', () {
        final availableSlot = TimeSlot(
          startTime: DateTime(2024, 1, 15, 10, 0),
          endTime: DateTime(2024, 1, 15, 12, 0),
          isAvailable: true,
          maxBookings: 2,
          currentBookings: 0,
        );

        final partiallyBookedSlot = TimeSlot(
          startTime: DateTime(2024, 1, 15, 14, 0),
          endTime: DateTime(2024, 1, 15, 16, 0),
          isAvailable: true,
          maxBookings: 2,
          currentBookings: 1,
        );

        final fullyBookedSlot = TimeSlot(
          startTime: DateTime(2024, 1, 15, 16, 0),
          endTime: DateTime(2024, 1, 15, 18, 0),
          isAvailable: true,
          maxBookings: 2,
          currentBookings: 2,
        );

        final unavailableSlot = TimeSlot(
          startTime: DateTime(2024, 1, 15, 18, 0),
          endTime: DateTime(2024, 1, 15, 20, 0),
          isAvailable: false,
        );

        expect(availableSlot.statusText, 'Available');
        expect(partiallyBookedSlot.statusText, '1 spots left');
        expect(fullyBookedSlot.statusText, 'Fully Booked');
        expect(unavailableSlot.statusText, 'Unavailable');
      });

      test('should serialize to and from JSON', () {
        final originalSlot = TimeSlot(
          startTime: DateTime(2024, 1, 15, 10, 0),
          endTime: DateTime(2024, 1, 15, 12, 0),
          isAvailable: true,
          staffId: 'staff_1',
          staffName: 'John Doe',
          maxBookings: 2,
          currentBookings: 1,
        );

        final json = originalSlot.toJson();
        final deserializedSlot = TimeSlot.fromJson(json);

        expect(deserializedSlot.startTime, originalSlot.startTime);
        expect(deserializedSlot.endTime, originalSlot.endTime);
        expect(deserializedSlot.isAvailable, originalSlot.isAvailable);
        expect(deserializedSlot.staffId, originalSlot.staffId);
        expect(deserializedSlot.maxBookings, originalSlot.maxBookings);
      });
    });

    group('DailyAvailability', () {
      test('should create DailyAvailability with time slots', () {
        final date = DateTime(2024, 1, 15);
        final timeSlots = [
          TimeSlot(
            startTime: DateTime(2024, 1, 15, 10, 0),
            endTime: DateTime(2024, 1, 15, 12, 0),
            isAvailable: true,
          ),
          TimeSlot(
            startTime: DateTime(2024, 1, 15, 14, 0),
            endTime: DateTime(2024, 1, 15, 16, 0),
            isAvailable: false,
          ),
        ];

        final dailyAvailability = DailyAvailability(
          date: date,
          timeSlots: timeSlots,
          isFullyBooked: false,
          hasAvailability: true,
        );

        expect(dailyAvailability.date, date);
        expect(dailyAvailability.timeSlots.length, 2);
        expect(dailyAvailability.isFullyBooked, false);
        expect(dailyAvailability.hasAvailability, true);
      });

      test('should filter available slots correctly', () {
        final timeSlots = [
          TimeSlot(
            startTime: DateTime(2024, 1, 15, 10, 0),
            endTime: DateTime(2024, 1, 15, 12, 0),
            isAvailable: true,
            maxBookings: 2,
            currentBookings: 0,
          ),
          TimeSlot(
            startTime: DateTime(2024, 1, 15, 14, 0),
            endTime: DateTime(2024, 1, 15, 16, 0),
            isAvailable: true,
            maxBookings: 2,
            currentBookings: 2, // Fully booked
          ),
          TimeSlot(
            startTime: DateTime(2024, 1, 15, 16, 0),
            endTime: DateTime(2024, 1, 15, 18, 0),
            isAvailable: false,
          ),
        ];

        final dailyAvailability = DailyAvailability(
          date: DateTime(2024, 1, 15),
          timeSlots: timeSlots,
          isFullyBooked: false,
          hasAvailability: true,
        );

        final availableSlots = dailyAvailability.availableSlots;
        expect(availableSlots.length, 1); // Only the first slot is truly available
      });

      test('should format date correctly', () {
        final dailyAvailability = DailyAvailability(
          date: DateTime(2024, 1, 15), // Monday
          timeSlots: [],
          isFullyBooked: false,
          hasAvailability: true,
        );

        expect(dailyAvailability.formattedDate, 'Mon, Jan 15');
      });

      test('should count available slots correctly', () {
        final timeSlots = [
          TimeSlot(
            startTime: DateTime(2024, 1, 15, 10, 0),
            endTime: DateTime(2024, 1, 15, 12, 0),
            isAvailable: true,
            maxBookings: 2,
            currentBookings: 0,
          ),
          TimeSlot(
            startTime: DateTime(2024, 1, 15, 14, 0),
            endTime: DateTime(2024, 1, 15, 16, 0),
            isAvailable: true,
            maxBookings: 2,
            currentBookings: 1,
          ),
        ];

        final dailyAvailability = DailyAvailability(
          date: DateTime(2024, 1, 15),
          timeSlots: timeSlots,
          isFullyBooked: false,
          hasAvailability: true,
        );

        expect(dailyAvailability.availableSlotCount, 2);
      });
    });

    group('AvailabilityCheckResult', () {
      test('should create result with weekly availability', () {
        final weeklyAvailability = [
          DailyAvailability(
            date: DateTime(2024, 1, 15),
            timeSlots: [],
            isFullyBooked: false,
            hasAvailability: true,
          ),
          DailyAvailability(
            date: DateTime(2024, 1, 16),
            timeSlots: [],
            isFullyBooked: true,
            hasAvailability: false,
          ),
        ];

        final result = AvailabilityCheckResult(
          isAvailable: true,
          weeklyAvailability: weeklyAvailability,
          conflictingBookings: [],
          message: 'Available slots found',
        );

        expect(result.isAvailable, true);
        expect(result.weeklyAvailability.length, 2);
        expect(result.conflictingBookings.isEmpty, true);
        expect(result.message, 'Available slots found');
      });

      test('should find next available day', () {
        final weeklyAvailability = [
          DailyAvailability(
            date: DateTime(2024, 1, 15),
            timeSlots: [],
            isFullyBooked: true,
            hasAvailability: false,
          ),
          DailyAvailability(
            date: DateTime(2024, 1, 16),
            timeSlots: [
              TimeSlot(
                startTime: DateTime(2024, 1, 16, 10, 0),
                endTime: DateTime(2024, 1, 16, 12, 0),
                isAvailable: true,
              ),
            ],
            isFullyBooked: false,
            hasAvailability: true,
          ),
        ];

        final result = AvailabilityCheckResult(
          isAvailable: true,
          weeklyAvailability: weeklyAvailability,
          conflictingBookings: [],
        );

        final nextAvailable = result.nextAvailableDay;
        expect(nextAvailable, isNotNull);
        expect(nextAvailable!.date, DateTime(2024, 1, 16));
      });

      test('should calculate total available slots', () {
        final weeklyAvailability = [
          DailyAvailability(
            date: DateTime(2024, 1, 15),
            timeSlots: [
              TimeSlot(
                startTime: DateTime(2024, 1, 15, 10, 0),
                endTime: DateTime(2024, 1, 15, 12, 0),
                isAvailable: true,
              ),
              TimeSlot(
                startTime: DateTime(2024, 1, 15, 14, 0),
                endTime: DateTime(2024, 1, 15, 16, 0),
                isAvailable: true,
              ),
            ],
            isFullyBooked: false,
            hasAvailability: true,
          ),
          DailyAvailability(
            date: DateTime(2024, 1, 16),
            timeSlots: [
              TimeSlot(
                startTime: DateTime(2024, 1, 16, 10, 0),
                endTime: DateTime(2024, 1, 16, 12, 0),
                isAvailable: true,
              ),
            ],
            isFullyBooked: false,
            hasAvailability: true,
          ),
        ];

        final result = AvailabilityCheckResult(
          isAvailable: true,
          weeklyAvailability: weeklyAvailability,
          conflictingBookings: [],
        );

        expect(result.totalAvailableSlots, 3);
      });

      test('should serialize to and from JSON', () {
        final originalResult = AvailabilityCheckResult(
          isAvailable: true,
          weeklyAvailability: [
            DailyAvailability(
              date: DateTime(2024, 1, 15),
              timeSlots: [
                TimeSlot(
                  startTime: DateTime(2024, 1, 15, 10, 0),
                  endTime: DateTime(2024, 1, 15, 12, 0),
                  isAvailable: true,
                ),
              ],
              isFullyBooked: false,
              hasAvailability: true,
            ),
          ],
          conflictingBookings: ['booking_1'],
          message: 'Test message',
          nextAvailableDate: DateTime(2024, 1, 20),
        );

        final json = originalResult.toJson();
        final deserializedResult = AvailabilityCheckResult.fromJson(json);

        expect(deserializedResult.isAvailable, originalResult.isAvailable);
        expect(deserializedResult.weeklyAvailability.length, originalResult.weeklyAvailability.length);
        expect(deserializedResult.conflictingBookings, originalResult.conflictingBookings);
        expect(deserializedResult.message, originalResult.message);
      });
    });

    group('BookingConflict', () {
      test('should create booking conflict with all properties', () {
        final conflict = BookingConflict(
          bookingId: 'booking_1',
          startTime: DateTime(2024, 1, 15, 10, 0),
          endTime: DateTime(2024, 1, 15, 12, 0),
          staffId: 'staff_1',
          staffName: 'John Doe',
          conflictType: 'time',
          description: 'Time slot already booked',
        );

        expect(conflict.bookingId, 'booking_1');
        expect(conflict.conflictType, 'time');
        expect(conflict.description, 'Time slot already booked');
      });

      test('should serialize to and from JSON', () {
        final originalConflict = BookingConflict(
          bookingId: 'booking_1',
          startTime: DateTime(2024, 1, 15, 10, 0),
          endTime: DateTime(2024, 1, 15, 12, 0),
          staffId: 'staff_1',
          staffName: 'John Doe',
          conflictType: 'time',
          description: 'Time slot already booked',
        );

        final json = originalConflict.toJson();
        final deserializedConflict = BookingConflict.fromJson(json);

        expect(deserializedConflict.bookingId, originalConflict.bookingId);
        expect(deserializedConflict.conflictType, originalConflict.conflictType);
        expect(deserializedConflict.description, originalConflict.description);
      });
    });
  });
}
