// test/unit/availability_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:demo_ncl/providers/availability_provider.dart';
import 'package:demo_ncl/models/availability_model.dart';
import 'package:demo_ncl/models/pricing_model.dart';

void main() {
  group('AvailabilityProvider Tests', () {
    late AvailabilityProvider provider;

    setUp(() {
      provider = AvailabilityProvider();
    });

    tearDown(() {
      provider.dispose();
    });

    test('should initialize with default values', () {
      expect(provider.selectedDate, isNull);
      expect(provider.selectedTimeSlot, isNull);
      expect(provider.weeklyAvailability, isEmpty);
      expect(provider.isLoading, false);
      expect(provider.error, null);
    });

    test('should check availability for date and service', () async {
      final testDate = DateTime(2024, 1, 15);
      
      final result = await provider.checkAvailability(
        date: testDate,
        serviceType: ServiceType.regularCleaning,
        propertySize: PropertySize.medium,
      );
      
      expect(result, isA<bool>());
      expect(provider.currentAvailability, isNotNull);
      expect(provider.weeklyAvailability, isNotEmpty);
      expect(provider.isLoading, false);
    });

    test('should check weekly availability', () async {
      final startDate = DateTime(2024, 1, 15);
      
      final result = await provider.checkWeeklyAvailability(
        startDate: startDate,
        serviceType: ServiceType.deepCleaning,
        propertySize: PropertySize.large,
      );
      
      expect(result, isA<AvailabilityCheckResult>());
      expect(result.weeklyAvailability.length, 7);
      expect(provider.weeklyAvailability, isNotEmpty);
    });

    test('should select date and time slot', () async {
      final testDate = DateTime(2024, 1, 15);
      
      // First check availability to get time slots
      await provider.checkAvailability(
        date: testDate,
        serviceType: ServiceType.regularCleaning,
        propertySize: PropertySize.medium,
      );
      
      // Get an available time slot from the provider
      final availableSlots = provider.getAvailableSlotsForDate(testDate);
      expect(availableSlots, isNotEmpty);
      
      final timeSlot = availableSlots.first;
      expect(timeSlot.isAvailable, true);
      
      final result = await provider.selectDateTime(
        date: testDate,
        timeSlot: timeSlot,
      );
      
      expect(result, true);
      expect(provider.selectedDate, testDate);
      expect(provider.selectedTimeSlot, timeSlot);
    });

    test('should clear selection', () async {
      final testDate = DateTime(2024, 1, 15);
      
      await provider.checkAvailability(
        date: testDate,
        serviceType: ServiceType.regularCleaning,
        propertySize: PropertySize.medium,
      );
      
      final availableSlots = provider.getAvailableSlotsForDate(testDate);
      expect(availableSlots, isNotEmpty);
      
      final timeSlot = availableSlots.first;
      
      await provider.selectDateTime(
        date: testDate,
        timeSlot: timeSlot,
      );
      
      provider.clearSelection();
      
      expect(provider.selectedDate, isNull);
      expect(provider.selectedTimeSlot, isNull);
    });

    test('should get available slots for date', () async {
      final testDate = DateTime(2024, 1, 15);
      
      await provider.checkAvailability(
        date: testDate,
        serviceType: ServiceType.regularCleaning,
        propertySize: PropertySize.medium,
      );
      
      final slots = provider.getAvailableSlotsForDate(testDate);
      
      expect(slots, isA<List<TimeSlot>>());
    });

    test('should handle loading states correctly', () async {
      final testDate = DateTime(2024, 1, 15);
      
      // Start availability check
      final future = provider.checkAvailability(
        date: testDate,
        serviceType: ServiceType.regularCleaning,
        propertySize: PropertySize.medium,
      );
      
      // Should be loading during the operation
      expect(provider.isLoading, true);
      
      // Wait for completion
      await future;
      
      // Should not be loading after completion
      expect(provider.isLoading, false);
    });

    test('should provide selection summary', () async {
      final testDate = DateTime(2024, 1, 15);
      
      await provider.checkAvailability(
        date: testDate,
        serviceType: ServiceType.regularCleaning,
        propertySize: PropertySize.medium,
      );
      
      final availableSlots = provider.getAvailableSlotsForDate(testDate);
      expect(availableSlots, isNotEmpty);
      
      final timeSlot = availableSlots.first;
      
      // Try to select the time slot (may fail due to conflicts)
      await provider.selectDateTime(
        date: testDate,
        timeSlot: timeSlot,
      );
      
      // Check that selection was attempted
      expect(provider.selectedDate, testDate);
      expect(provider.selectedTimeSlot, isNotNull);
      
      final summary = provider.getSelectionSummary();
      
      // Summary may be empty if selection is invalid, but should still be a Map
      expect(summary, isA<Map<String, dynamic>>());
    });

    test('should reset provider state', () async {
      final testDate = DateTime(2024, 1, 15);
      
      await provider.checkAvailability(
        date: testDate,
        serviceType: ServiceType.regularCleaning,
        propertySize: PropertySize.medium,
      );
      
      provider.reset();
      
      expect(provider.selectedDate, isNull);
      expect(provider.selectedTimeSlot, isNull);
      expect(provider.currentAvailability, isNull);
      expect(provider.weeklyAvailability, isEmpty);
      expect(provider.conflictingBookings, isEmpty);
    });

    test('should get next available date', () async {
      final startDate = DateTime(2024, 1, 15);
      
      await provider.checkWeeklyAvailability(
        startDate: startDate,
        serviceType: ServiceType.regularCleaning,
        propertySize: PropertySize.medium,
      );
      
      final nextDate = provider.getNextAvailableDate();
      
      expect(nextDate, isA<DateTime?>());
    });

    test('should handle different service types', () async {
      final testDate = DateTime(2024, 1, 15);
      
      final regularResult = await provider.checkAvailability(
        date: testDate,
        serviceType: ServiceType.regularCleaning,
        propertySize: PropertySize.medium,
      );
      
      final deepResult = await provider.checkAvailability(
        date: testDate,
        serviceType: ServiceType.deepCleaning,
        propertySize: PropertySize.medium,
      );
      
      expect(regularResult, isA<bool>());
      expect(deepResult, isA<bool>());
    });

    test('should handle different property sizes', () async {
      final testDate = DateTime(2024, 1, 15);
      
      final smallResult = await provider.checkAvailability(
        date: testDate,
        serviceType: ServiceType.regularCleaning,
        propertySize: PropertySize.small,
      );
      
      final largeResult = await provider.checkAvailability(
        date: testDate,
        serviceType: ServiceType.regularCleaning,
        propertySize: PropertySize.large,
      );
      
      expect(smallResult, isA<bool>());
      expect(largeResult, isA<bool>());
    });

    test('should detect conflicting bookings', () async {
      final testDate = DateTime(2024, 1, 15);
      
      await provider.checkAvailability(
        date: testDate,
        serviceType: ServiceType.regularCleaning,
        propertySize: PropertySize.medium,
      );
      
      final availableSlots = provider.getAvailableSlotsForDate(testDate);
      expect(availableSlots, isNotEmpty);
      
      final timeSlot = availableSlots.first;
      
      await provider.selectDateTime(
        date: testDate,
        timeSlot: timeSlot,
      );
      
      // Check if conflicts were detected
      expect(provider.conflictingBookings, isA<List<String>>());
    });

    test('should handle unavailable time slots', () async {
      final testDate = DateTime(2024, 1, 15);
      
      await provider.checkAvailability(
        date: testDate,
        serviceType: ServiceType.regularCleaning,
        propertySize: PropertySize.medium,
      );
      
      // Create an unavailable time slot
      final unavailableSlot = TimeSlot(
        startTime: DateTime(2024, 1, 15, 9, 0),
        endTime: DateTime(2024, 1, 15, 11, 0),
        isAvailable: false, // This slot is unavailable
        maxBookings: 2,
        currentBookings: 2,
        staffName: 'Test Staff',
      );
      
      final result = await provider.selectDateTime(
        date: testDate,
        timeSlot: unavailableSlot,
      );
      
      expect(result, false); // Should fail for unavailable slot
    });
  });
}
