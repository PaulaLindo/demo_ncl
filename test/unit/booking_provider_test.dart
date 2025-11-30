// test/unit/booking_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:demo_ncl/providers/booking_provider.dart';

import 'package:demo_ncl/models/booking_model.dart';

class MockBookingProvider extends Mock implements BookingProvider {}

void main() {
  late BookingProvider bookingProvider;
  late Booking testBooking;

  setUp(() {
    bookingProvider = BookingProvider();
    testBooking = Booking(
      id: '1',
      customerId: 'user1',
      serviceId: 's1', // Use correct service ID from mock data
      serviceName: 'Standard Cleaning', // Use correct service name
      bookingDate: DateTime.now().add(const Duration(days: 1)),
      timePreference: TimeOfDayPreference.morning,
      address: '123 Test St',
      status: BookingStatus.pending,
      basePrice: 50.0, // Use correct base price from mock data
      propertySize: PropertySize.medium,
      frequency: BookingFrequency.oneTime,
      startTime: DateTime.now().add(const Duration(days: 1, hours: 9)),
      endTime: DateTime.now().add(const Duration(days: 1, hours: 11)),
      createdAt: DateTime.now(),
    );
  });

  test('initial values are correct', () {
    expect(bookingProvider.bookings, isEmpty);
    expect(bookingProvider.isLoading, isFalse);
    expect(bookingProvider.hasError, isFalse);
  });

  test('loadBookings updates state correctly', () async {
    await bookingProvider.loadBookings();
    expect(bookingProvider.bookings, isNotEmpty);
    expect(bookingProvider.isLoading, isFalse);
  });

  test('createBooking adds new booking', () async {
    await bookingProvider.createBooking(
      serviceId: testBooking.serviceId,
      bookingDate: testBooking.bookingDate,
      address: testBooking.address,
      propertySize: testBooking.propertySize.name,
      frequency: testBooking.frequency.name,
      timePreference: testBooking.timePreference,
      notes: testBooking.notes,
    );
    expect(bookingProvider.bookings.length, 1);
    expect(bookingProvider.bookings.first.serviceId, testBooking.serviceId);
  });

  test('cancelBooking updates status to cancelled', () async {
    await bookingProvider.createBooking(
      serviceId: testBooking.serviceId,
      bookingDate: testBooking.bookingDate,
      address: testBooking.address,
      propertySize: testBooking.propertySize.name,
      frequency: testBooking.frequency.name,
      timePreference: testBooking.timePreference,
      notes: testBooking.notes,
    );
    
    // Get the actual booking ID that was generated
    final createdBooking = bookingProvider.bookings.first;
    await bookingProvider.cancelBooking(createdBooking.id, reason: 'Test cancellation');
    
    final updated = bookingProvider.bookings.firstWhere((b) => b.id == createdBooking.id);
    expect(updated.status, BookingStatus.cancelled);
    expect(updated.cancellationReason, 'Test cancellation');
  });

  test('getUpcomingBookings returns only upcoming bookings', () async {
    final pastBooking = testBooking.copyWith(
      id: '2',
      bookingDate: DateTime.now().subtract(Duration(days: 1)),
    );
    
    // Create the upcoming booking first
    await bookingProvider.createBooking(
      serviceId: testBooking.serviceId,
      bookingDate: testBooking.bookingDate,
      address: testBooking.address,
      propertySize: testBooking.propertySize.name,
      frequency: testBooking.frequency.name,
      timePreference: testBooking.timePreference,
      notes: testBooking.notes,
    );
    
    // Get the ID of the upcoming booking
    final upcomingBookingId = bookingProvider.bookings.first.id;
    
    // Create the past booking
    await bookingProvider.createBooking(
      serviceId: pastBooking.serviceId,
      bookingDate: pastBooking.bookingDate,
      address: pastBooking.address,
      propertySize: pastBooking.propertySize.name,
      frequency: pastBooking.frequency.name,
      timePreference: pastBooking.timePreference,
      notes: pastBooking.notes,
    );
    
    final upcoming = bookingProvider.getUpcomingBookings();
    expect(upcoming.length, 1);
    expect(upcoming.first.id, upcomingBookingId);
  });
}