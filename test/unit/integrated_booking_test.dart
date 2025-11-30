// test/unit/integrated_booking_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:demo_ncl/providers/integrated_booking_provider.dart';
import 'package:demo_ncl/models/booking_model.dart';
import 'package:demo_ncl/models/service_model.dart';
import 'package:demo_ncl/repositories/booking_repository.dart';

import 'integrated_booking_test.mocks.dart';

@GenerateMocks([BookingRepository])
void main() {
  group('TC 2.1: Integrated Booking Features', () {
    late IntegratedBookingProvider provider;
    late MockBookingRepository mockRepository;

    setUp(() {
      mockRepository = MockBookingRepository();
      provider = IntegratedBookingProvider(repository: mockRepository);
    });

    group('Core + Expansion Service Selection', () {
      test('should allow simultaneous selection of Core Cleaning and Home Care services', () async {
        // Arrange
        final coreCleaning = Service(
          id: 'core_001',
          name: 'Regular Home Cleaning',
          category: ServiceCategory.core,
          basePrice: 150.0,
          duration: const Duration(hours: 2),
          description: 'Complete home cleaning service',
        );

        final gardening = Service(
          id: 'expansion_001',
          name: 'Garden Maintenance',
          category: ServiceCategory.homeCare,
          basePrice: 80.0,
          duration: const Duration(hours: 1),
          description: 'Professional garden care',
        );

        final windowCleaning = Service(
          id: 'expansion_002',
          name: 'Window Cleaning',
          category: ServiceCategory.homeCare,
          basePrice: 60.0,
          duration: const Duration(minutes: 45),
          description: 'Interior and exterior window cleaning',
        );

        when(mockRepository.getServicesByCategory(ServiceCategory.core))
            .thenAnswer((_) async => [coreCleaning]);
        when(mockRepository.getServicesByCategory(ServiceCategory.homeCare))
            .thenAnswer((_) async => [gardening, windowCleaning]);

        // Act
        await provider.loadAvailableServices();
        provider.selectService(coreCleaning);
        provider.selectService(gardening);
        provider.selectService(windowCleaning);

        final selectedServices = provider.selectedServices;

        // Assert
        expect(selectedServices.length, equals(3));
        expect(selectedServices, contains(coreCleaning));
        expect(selectedServices, contains(gardening));
        expect(selectedServices, contains(windowCleaning));
        
        // Verify we have both core and expansion services
        final coreServices = selectedServices.where((s) => s.category == ServiceCategory.core);
        final expansionServices = selectedServices.where((s) => s.category == ServiceCategory.homeCare);
        
        expect(coreServices.length, equals(1));
        expect(expansionServices.length, equals(2));
      });

      test('should calculate combined price for multiple service types', () async {
        // Arrange
        final services = [
          Service(
            id: 'core_001',
            name: 'Regular Home Cleaning',
            category: ServiceCategory.core,
            basePrice: 150.0,
            duration: const Duration(hours: 2),
          ),
          Service(
            id: 'expansion_001',
            name: 'Garden Maintenance',
            category: ServiceCategory.homeCare,
            basePrice: 80.0,
            duration: const Duration(hours: 1),
          ),
          Service(
            id: 'expansion_002',
            name: 'Window Cleaning',
            category: ServiceCategory.homeCare,
            basePrice: 60.0,
            duration: const Duration(minutes: 45),
          ),
        ];

        // Act
        for (final service in services) {
          provider.selectService(service);
        }

        final totalPrice = provider.calculateTotalPrice();

        // Assert
        expect(totalPrice, equals(290.0)); // 150 + 80 + 60
      });

      test('should handle service scheduling for multiple services', () async {
        // Arrange
        final scheduledDate = DateTime.now().add(const Duration(days: 3));
        final scheduledTime = const TimeOfDay(hour: 10, minute: 0);

        final services = [
          Service(
            id: 'core_001',
            name: 'Regular Home Cleaning',
            category: ServiceCategory.core,
            basePrice: 150.0,
            duration: const Duration(hours: 2),
          ),
          Service(
            id: 'expansion_001',
            name: 'Garden Maintenance',
            category: ServiceCategory.homeCare,
            basePrice: 80.0,
            duration: const Duration(hours: 1),
          ),
        ];

        // Act
        for (final service in services) {
          provider.selectService(service);
        }
        
        provider.setSchedule(scheduledDate, scheduledTime);
        final booking = provider.createIntegratedBooking();

        // Assert
        expect(booking.services.length, equals(2));
        expect(booking.preferredDate, equals(scheduledDate));
        expect(booking.preferredTime, equals(scheduledTime));
        expect(booking.totalDuration, equals(const Duration(hours: 3))); // 2 + 1
      });

      test('should validate service combination compatibility', () async {
        // Arrange
        final incompatibleServices = [
          Service(
            id: 'core_001',
            name: 'Regular Home Cleaning',
            category: ServiceCategory.core,
            basePrice: 150.0,
            duration: const Duration(hours: 2),
            incompatibleServices: ['deep_cleaning_001'], // Can't combine with deep cleaning
          ),
          Service(
            id: 'deep_cleaning_001',
            name: 'Deep Cleaning',
            category: ServiceCategory.core,
            basePrice: 250.0,
            duration: const Duration(hours: 4),
            incompatibleServices: ['core_001'],
          ),
        ];

        // Act
        provider.selectService(incompatibleServices[0]);
        final canAddSecond = provider.canSelectService(incompatibleServices[1]);

        // Assert
        expect(canAddSecond, isFalse);
        expect(provider.getCompatibilityErrors(), isNotEmpty);
      });

      test('should handle add-on services for multiple base services', () async {
        // Arrange
        final coreService = Service(
          id: 'core_001',
          name: 'Regular Home Cleaning',
          category: ServiceCategory.core,
          basePrice: 150.0,
          duration: const Duration(hours: 2),
          availableAddOns: [
            ServiceAddon(
              id: 'addon_001',
              name: 'Fridge Cleaning',
              price: 25.0,
              applicableServices: ['core_001'],
            ),
            ServiceAddon(
              id: 'addon_002',
              name: 'Oven Cleaning',
              price: 35.0,
              applicableServices: ['core_001', 'deep_cleaning_001'],
            ),
          ],
        );

        final expansionService = Service(
          id: 'expansion_001',
          name: 'Garden Maintenance',
          category: ServiceCategory.homeCare,
          basePrice: 80.0,
          duration: const Duration(hours: 1),
          availableAddOns: [
            ServiceAddon(
              id: 'addon_003',
              name: 'Lawn Treatment',
              price: 40.0,
              applicableServices: ['expansion_001'],
            ),
          ],
        );

        // Act
        provider.selectService(coreService);
        provider.selectService(expansionService);
        
        // Add add-ons to different services
        provider.selectAddOn(coreService.availableAddOns![0]); // Fridge cleaning
        provider.selectAddOn(coreService.availableAddOns![1]); // Oven cleaning
        provider.selectAddOn(expansionService.availableAddOns![0]); // Lawn treatment

        final totalWithAddOns = provider.calculateTotalPrice();

        // Assert
        expect(totalWithAddOns, equals(330.0)); // 150 + 80 + 25 + 35 + 40
        expect(provider.selectedAddOns.length, equals(3));
      });

      test('should create single transaction for multiple services', () async {
        // Arrange
        final booking = Booking(
          id: 'booking_001',
          customerId: 'customer_001',
          services: [
            Service(
              id: 'core_001',
              name: 'Regular Home Cleaning',
              category: ServiceCategory.core,
              basePrice: 150.0,
            ),
            Service(
              id: 'expansion_001',
              name: 'Garden Maintenance',
              category: ServiceCategory.homeCare,
              basePrice: 80.0,
            ),
          ],
          preferredDate: DateTime.now().add(const Duration(days: 3)),
          preferredTime: const TimeOfDay(hour: 10, minute: 0),
          totalPrice: 230.0,
          status: BookingStatus.pending,
        );

        when(mockRepository.createIntegratedBooking(any))
            .thenAnswer((_) async => booking);

        // Act
        final result = await provider.submitIntegratedBooking(booking);

        // Assert
        expect(result.success, isTrue);
        expect(result.bookingId, equals('booking_001'));
        expect(result.transactionId, isNotNull);
        verify(mockRepository.createIntegratedBooking(booking)).called(1);
      });
    });

    group('Service Category Management', () {
      test('should organize services by category correctly', () async {
        // Arrange
        final allServices = [
          Service(id: 'core_001', name: 'Regular Cleaning', category: ServiceCategory.core),
          Service(id: 'core_002', name: 'Deep Cleaning', category: ServiceCategory.core),
          Service(id: 'homecare_001', name: 'Gardening', category: ServiceCategory.homeCare),
          Service(id: 'homecare_002', name: 'Window Cleaning', category: ServiceCategory.homeCare),
          Service(id: 'homecare_003', name: 'Pool Maintenance', category: ServiceCategory.homeCare),
        ];

        when(mockRepository.getAllServices())
            .thenAnswer((_) async => allServices);

        // Act
        await provider.loadAvailableServices();
        final categorizedServices = provider.getCategorizedServices();

        // Assert
        expect(categorizedServices[ServiceCategory.core]?.length, equals(2));
        expect(categorizedServices[ServiceCategory.homeCare]?.length, equals(3));
        expect(categorizedServices.keys, containsAll([ServiceCategory.core, ServiceCategory.homeCare]));
      });

      test('should enforce minimum service requirements', () async {
        // Arrange
        final coreService = Service(
          id: 'core_001',
          name: 'Regular Home Cleaning',
          category: ServiceCategory.core,
          basePrice: 150.0,
          isRequired: true, // Core service is required
        );

        // Act
        final validation = provider.validateServiceSelection([]);

        // Assert
        expect(validation.isValid, isFalse);
        expect(validation.errors, contains('At least one core service is required'));
      });

      test('should handle service quantity limits', () async {
        // Arrange
        final limitedService = Service(
          id: 'limited_001',
          name: 'Pool Maintenance',
          category: ServiceCategory.homeCare,
          basePrice: 100.0,
          maxQuantity: 1, // Only one per booking
        );

        // Act
        provider.selectService(limitedService);
        final canAddSecond = provider.canSelectService(limitedService);

        // Assert
        expect(canAddSecond, isFalse);
        expect(provider.getServiceQuantity(limitedService), equals(1));
      });
    });

    group('Pricing and Discounts', () {
      test('should apply multi-service discounts', () async {
        // Arrange
        final services = [
          Service(id: 'core_001', name: 'Regular Cleaning', category: ServiceCategory.core, basePrice: 150.0),
          Service(id: 'homecare_001', name: 'Gardening', category: ServiceCategory.homeCare, basePrice: 80.0),
          Service(id: 'homecare_002', name: 'Window Cleaning', category: ServiceCategory.homeCare, basePrice: 60.0),
        ];

        // Act
        for (final service in services) {
          provider.selectService(service);
        }

        final basePrice = provider.calculateBasePrice();
        final discountedPrice = provider.calculateTotalPrice();

        // Assert
        expect(basePrice, equals(290.0)); // 150 + 80 + 60
        expect(discountedPrice, lessThan(basePrice)); // Should have discount
        expect(provider.appliedDiscounts, isNotEmpty);
      });

      test('should calculate service bundle pricing', () async {
        // Arrange
        final bundle = ServiceBundle(
          id: 'bundle_001',
          name: 'Complete Home Care Package',
          services: ['core_001', 'homecare_001', 'homecare_002'],
          bundlePrice: 250.0, // Discounted from individual prices
          description: 'Core cleaning + garden + windows',
        );

        when(mockRepository.getServiceBundle('bundle_001'))
            .thenAnswer((_) async => bundle);

        // Act
        await provider.selectServiceBundle('bundle_001');
        final bundlePrice = provider.calculateTotalPrice();

        // Assert
        expect(bundlePrice, equals(250.0));
        expect(provider.selectedBundle, equals(bundle));
      });
    });

    group('Error Handling and Validation', () {
      test('should handle scheduling conflicts between services', () async {
        // Arrange
        final overlappingServices = [
          Service(
            id: 'service_001',
            name: 'Service 1',
            category: ServiceCategory.core,
            basePrice: 100.0,
            duration: const Duration(hours: 3),
          ),
          Service(
            id: 'service_002',
            name: 'Service 2',
            category: ServiceCategory.homeCare,
            basePrice: 80.0,
            duration: const Duration(hours: 2),
          ),
        ];

        final sameDateTime = DateTime.now().add(const Duration(days: 2));

        // Act
        for (final service in overlappingServices) {
          provider.selectService(service);
        }

        provider.setSchedule(sameDateTime, const TimeOfDay(hour: 10, minute: 0));
        final conflicts = provider.checkSchedulingConflicts();

        // Assert
        expect(conflicts, isNotEmpty);
        expect(conflicts.first.type, equals(SchedulingConflictType.overlappingServices));
      });

      test('should validate service availability before booking', () async {
        // Arrange
        final unavailableService = Service(
          id: 'unavailable_001',
          name: 'Unavailable Service',
          category: ServiceCategory.core,
          basePrice: 150.0,
          isAvailable: false,
        );

        // Act
        final canSelect = provider.canSelectService(unavailableService);

        // Assert
        expect(canSelect, isFalse);
        expect(provider.getAvailabilityErrors(), contains('Service is currently unavailable'));
      });

      test('should handle booking creation failures gracefully', () async {
        // Arrange
        final booking = Booking(
          id: 'booking_fail',
          customerId: 'customer_001',
          services: [],
          preferredDate: DateTime.now(),
          preferredTime: const TimeOfDay(hour: 10, minute: 0),
          totalPrice: 0.0,
        );

        when(mockRepository.createIntegratedBooking(any))
            .thenThrow(Exception('Payment processing failed'));

        // Act
        final result = await provider.submitIntegratedBooking(booking);

        // Assert
        expect(result.success, isFalse);
        expect(result.errorMessage, contains('Payment processing failed'));
      });
    });

    group('Integration Tests', () {
      test('should handle complete integrated booking workflow', () async {
        // Arrange
        final coreService = Service(
          id: 'core_001',
          name: 'Regular Home Cleaning',
          category: ServiceCategory.core,
          basePrice: 150.0,
          availableAddOns: [
            ServiceAddon(id: 'addon_001', name: 'Fridge Cleaning', price: 25.0),
          ],
        );

        final expansionService = Service(
          id: 'homecare_001',
          name: 'Garden Maintenance',
          category: ServiceCategory.homeCare,
          basePrice: 80.0,
        );

        final scheduledDate = DateTime.now().add(const Duration(days: 5));
        final scheduledTime = const TimeOfDay(hour: 14, minute: 0);

        when(mockRepository.getServicesByCategory(ServiceCategory.core))
            .thenAnswer((_) async => [coreService]);
        when(mockRepository.getServicesByCategory(ServiceCategory.homeCare))
            .thenAnswer((_) async => [expansionService]);

        // Act
        await provider.loadAvailableServices();
        
        // Select services
        provider.selectService(coreService);
        provider.selectService(expansionService);
        provider.selectAddOn(coreService.availableAddOns!.first);
        
        // Set schedule
        provider.setSchedule(scheduledDate, scheduledTime);
        
        // Create booking
        final booking = provider.createIntegratedBooking();
        
        // Submit booking
        when(mockRepository.createIntegratedBooking(any))
            .thenAnswer((_) async => booking);

        final result = await provider.submitIntegratedBooking(booking);

        // Assert
        expect(result.success, isTrue);
        expect(booking.services.length, equals(2));
        expect(booking.selectedAddOns.length, equals(1));
        expect(booking.totalPrice, equals(255.0)); // 150 + 80 + 25
        expect(booking.preferredDate, equals(scheduledDate));
        expect(booking.preferredTime, equals(scheduledTime));
      });
    });
  });
}

// Supporting classes for testing
enum ServiceCategory {
  core('Core Cleaning'),
  homeCare('Home Care Expansion'),
  specialty('Specialty Services');

  const ServiceCategory(this.displayName);
  final String displayName;
}

enum BookingStatus {
  pending('Pending'),
  confirmed('Confirmed'),
  completed('Completed'),
  cancelled('Cancelled');

  const BookingStatus(this.displayName);
  final String displayName;
}

enum SchedulingConflictType {
  overlappingServices('Overlapping Services'),
  staffUnavailable('Staff Unavailable'),
  timeSlotUnavailable('Time Slot Unavailable');

  const SchedulingConflictType(this.displayName);
  final String displayName;
}

class Service {
  final String id;
  final String name;
  final ServiceCategory category;
  final double basePrice;
  final Duration duration;
  final String description;
  final List<String>? incompatibleServices;
  final List<ServiceAddon>? availableAddOns;
  final bool isRequired;
  final int maxQuantity;
  final bool isAvailable;

  Service({
    required this.id,
    required this.name,
    required this.category,
    required this.basePrice,
    required this.duration,
    this.description = '',
    this.incompatibleServices,
    this.availableAddOns,
    this.isRequired = false,
    this.maxQuantity = 1,
    this.isAvailable = true,
  });
}

class ServiceAddon {
  final String id;
  final String name;
  final double price;
  final List<String> applicableServices;

  ServiceAddon({
    required this.id,
    required this.name,
    required this.price,
    required this.applicableServices,
  });
}

class ServiceBundle {
  final String id;
  final String name;
  final List<String> services;
  final double bundlePrice;
  final String description;

  ServiceBundle({
    required this.id,
    required this.name,
    required this.services,
    required this.bundlePrice,
    required this.description,
  });
}

class Booking {
  final String id;
  final String customerId;
  final List<Service> services;
  final List<ServiceAddon> selectedAddOns;
  final DateTime preferredDate;
  final TimeOfDay preferredTime;
  final double totalPrice;
  final Duration totalDuration;
  final BookingStatus status;
  final ServiceBundle? selectedBundle;

  Booking({
    required this.id,
    required this.customerId,
    required this.services,
    this.selectedAddOns = const [],
    required this.preferredDate,
    required this.preferredTime,
    required this.totalPrice,
    required this.totalDuration,
    required this.status,
    this.selectedBundle,
  });
}

class TimeOfDay {
  final int hour;
  final int minute;

  const TimeOfDay({required this.hour, required this.minute});
}

class BookingResult {
  final bool success;
  final String? bookingId;
  final String? transactionId;
  final String? errorMessage;

  BookingResult({
    required this.success,
    this.bookingId,
    this.transactionId,
    this.errorMessage,
  });
}

class ServiceSelectionValidation {
  final bool isValid;
  final List<String> errors;

  ServiceSelectionValidation({
    required this.isValid,
    this.errors = const [],
  });
}

class SchedulingConflict {
  final SchedulingConflictType type;
  final String description;
  final List<String> conflictingServices;

  SchedulingConflict({
    required this.type,
    required this.description,
    required this.conflictingServices,
  });
}

class AppliedDiscount {
  final String type;
  final double amount;
  final String description;

  AppliedDiscount({
    required this.type,
    required this.amount,
    required this.description,
  });
}
