// test/unit/other_providers_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';

// Import providers that don't require Firebase
import 'package:demo_ncl/providers/timekeeping_provider.dart';
import 'package:demo_ncl/providers/booking_provider.dart';
import 'package:demo_ncl/providers/jobs_provider.dart';

void main() {
  // Initialize Flutter binding for tests
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Other Providers Test', () {
    test('should initialize TimekeepingProvider without errors', () {
      // Mock the method channel to prevent binding issues
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter/connectivity'),
        (MethodCall methodCall) async {
          return {'networkStatus': 'connected'};
        },
      );
      
      expect(() => TimekeepingProvider(), returnsNormally);
    });

    test('should initialize BookingProvider without errors', () {
      expect(() => BookingProvider(), returnsNormally);
    });

    test('should initialize JobsProvider without errors', () {
      expect(() => JobsProvider(), returnsNormally);
    });

    test('should test TimekeepingProvider basic functionality', () {
      // Mock connectivity
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter/connectivity'),
        (MethodCall methodCall) async {
          return {'networkStatus': 'connected'};
        },
      );
      
      final provider = TimekeepingProvider();
      
      // TimekeepingProvider starts loading on initialization
      expect(provider.timeRecords, isEmpty);
      // isLoading might be true initially due to loadInitialData()
      expect(provider.error, null);
    });

    test('should test BookingProvider basic functionality', () {
      final provider = BookingProvider();
      
      expect(provider.isLoading, false);
      expect(provider.bookings, isEmpty);
      expect(provider.hasError, false);
      expect(provider.errorMessage, null);
    });

    test('should test JobsProvider basic functionality', () {
      final provider = JobsProvider();
      
      expect(provider.isLoading, false);
      expect(provider.jobs, isEmpty);
      expect(provider.error, null);
    });
  });
}
