// test/unit/admin_service_management_simple_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_ncl/providers/admin_service_provider.dart';
import 'package:demo_ncl/models/service_model.dart';

void main() {
  group('Admin Service Management - Simple Tests', () {
    late AdminServiceProvider provider;

    setUp(() {
      provider = AdminServiceProvider();
    });

    group('Service Status Management', () {
      test('should initialize with empty services', () {
        expect(provider.allServices, isEmpty);
        expect(provider.getActiveServices(), isEmpty);
        expect(provider.isLoading, isFalse);
        expect(provider.error, isNull);
      });

      test('should correctly identify active services', () {
        // Arrange
        final services = [
          Service(
            id: 'service1',
            name: 'Basic Cleaning',
            description: 'Basic house cleaning',
            basePrice: 50.0,
            category: 'Core Cleaning',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Service(
            id: 'service2',
            name: 'Deep Cleaning',
            description: 'Deep house cleaning',
            basePrice: 100.0,
            category: 'Core Cleaning',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Service(
            id: 'service3',
            name: 'Window Washing',
            description: 'Window cleaning service',
            basePrice: 75.0,
            category: 'Specialty',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        // Act
        provider.setServices(services);
        provider.setActiveServices({'service1', 'service3'});

        // Assert
        expect(provider.allServices.length, equals(3));
        expect(provider.getActiveServices().length, equals(2));
        expect(provider.isServiceActive('service1'), isTrue);
        expect(provider.isServiceActive('service2'), isFalse);
        expect(provider.isServiceActive('service3'), isTrue);
        expect(provider.isServiceActive('nonexistent'), isFalse);
      });

      test('should handle empty active services list', () {
        // Arrange
        final services = [
          Service(
            id: 'service1',
            name: 'Basic Cleaning',
            description: 'Basic house cleaning',
            basePrice: 50.0,
            category: 'Core Cleaning',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        // Act
        provider.setServices(services);
        provider.setActiveServices({});

        // Assert
        expect(provider.getActiveServices().isEmpty, isTrue);
        expect(provider.isServiceActive('service1'), isFalse);
      });
    });

    group('Service Statistics', () {
      test('should calculate correct statistics', () {
        // Arrange
        final services = [
          Service(
            id: 'service1',
            name: 'Basic Cleaning',
            description: 'Basic house cleaning',
            basePrice: 50.0,
            category: 'Core Cleaning',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Service(
            id: 'service2',
            name: 'Deep Cleaning',
            description: 'Deep house cleaning',
            basePrice: 100.0,
            category: 'Core Cleaning',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Service(
            id: 'service3',
            name: 'Window Washing',
            description: 'Window cleaning service',
            basePrice: 75.0,
            category: 'Specialty',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Service(
            id: 'service4',
            name: 'Carpet Cleaning',
            description: 'Carpet cleaning service',
            basePrice: 80.0,
            category: 'Home Care',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        provider.setServices(services);
        provider.setActiveServices({'service1', 'service3', 'service4'});

        // Act
        final stats = provider.getServiceStatistics();

        // Assert
        expect(stats['total'], equals(4));
        expect(stats['active'], equals(3));
        expect(stats['inactive'], equals(1));
        expect(stats['Core Cleaning'], equals(2));
        expect(stats['Specialty'], equals(1));
        expect(stats['Home Care'], equals(1));
      });

      test('should handle empty services in statistics', () {
        // Act
        final stats = provider.getServiceStatistics();

        // Assert
        expect(stats['total'], equals(0));
        expect(stats['active'], equals(0));
        expect(stats['inactive'], equals(0));
      });
    });

    group('Service Search and Filtering', () {
      test('should search services by name', () {
        // Arrange
        final services = [
          Service(
            id: 'service1',
            name: 'Basic Cleaning',
            description: 'Basic house cleaning',
            basePrice: 50.0,
            category: 'Core Cleaning',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Service(
            id: 'service2',
            name: 'Deep Cleaning',
            description: 'Deep house cleaning',
            basePrice: 100.0,
            category: 'Core Cleaning',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Service(
            id: 'service3',
            name: 'Window Washing',
            description: 'Window cleaning service',
            basePrice: 75.0,
            category: 'Specialty',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        provider.setServices(services);

        // Act
        final results = provider.searchServices('cleaning');

        // Assert - Should find 3 results (Basic Cleaning, Deep Cleaning, and Window Washing due to description)
        expect(results.length, equals(3));
        final resultNames = results.map((s) => s.name).toList();
        expect(resultNames, contains('Basic Cleaning'));
        expect(resultNames, contains('Deep Cleaning'));
        expect(resultNames, contains('Window Washing'));
      });

      test('should search services by description', () {
        // Arrange
        final services = [
          Service(
            id: 'service1',
            name: 'Basic Service',
            description: 'Basic house cleaning',
            basePrice: 50.0,
            category: 'Core Cleaning',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Service(
            id: 'service2',
            name: 'Premium Service',
            description: 'Premium house cleaning',
            basePrice: 100.0,
            category: 'Core Cleaning',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        provider.setServices(services);

        // Act
        final results = provider.searchServices('house cleaning');

        // Assert
        expect(results.length, equals(2));
        expect(results[0].name, equals('Basic Service'));
        expect(results[1].name, equals('Premium Service'));
      });

      test('should search services by category', () {
        // Arrange
        final services = [
          Service(
            id: 'service1',
            name: 'Basic Cleaning',
            description: 'Basic house cleaning',
            basePrice: 50.0,
            category: 'Core Cleaning',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Service(
            id: 'service2',
            name: 'Window Service',
            description: 'Window cleaning service',
            basePrice: 75.0,
            category: 'Specialty',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        provider.setServices(services);

        // Act
        final results = provider.searchServices('specialty');

        // Assert
        expect(results.length, equals(1));
        expect(results[0].name, equals('Window Service'));
      });

      test('should return all services for empty search', () {
        // Arrange
        final services = [
          Service(
            id: 'service1',
            name: 'Basic Cleaning',
            description: 'Basic house cleaning',
            basePrice: 50.0,
            category: 'Core Cleaning',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        provider.setServices(services);

        // Act
        final results = provider.searchServices('');

        // Assert
        expect(results.length, equals(1));
        expect(results[0].name, equals('Basic Cleaning'));
      });

      test('should get services by category', () {
        // Arrange
        final services = [
          Service(
            id: 'service1',
            name: 'Basic Cleaning',
            description: 'Basic house cleaning',
            basePrice: 50.0,
            category: 'Core Cleaning',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Service(
            id: 'service2',
            name: 'Deep Cleaning',
            description: 'Deep house cleaning',
            basePrice: 100.0,
            category: 'Core Cleaning',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Service(
            id: 'service3',
            name: 'Window Washing',
            description: 'Window cleaning service',
            basePrice: 75.0,
            category: 'Specialty',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        provider.setServices(services);

        // Act
        final coreServices = provider.getServicesByCategory('Core Cleaning');
        final specialtyServices = provider.getServicesByCategory('Specialty');
        final emptyServices = provider.getServicesByCategory('Nonexistent');

        // Assert
        expect(coreServices.length, equals(2));
        expect(coreServices.every((s) => s.category == 'Core Cleaning'), isTrue);
        
        expect(specialtyServices.length, equals(1));
        expect(specialtyServices[0].category, equals('Specialty'));
        
        expect(emptyServices.isEmpty, isTrue);
      });
    });

    group('Error Handling and State Management', () {
      test('should handle loading state correctly', () {
        // Act
        provider.setLoading(true);

        // Assert
        expect(provider.isLoading, isTrue);

        // Act
        provider.setLoading(false);

        // Assert
        expect(provider.isLoading, isFalse);
      });

      test('should handle error state correctly', () {
        // Act
        provider.setError('Test error message');

        // Assert
        expect(provider.error, equals('Test error message'));

        // Act
        provider.clearError();

        // Assert
        expect(provider.error, isNull);
      });

      test('should handle case-insensitive search', () {
        // Arrange
        final services = [
          Service(
            id: 'service1',
            name: 'Basic Cleaning',
            description: 'Basic house cleaning',
            basePrice: 50.0,
            category: 'Core Cleaning',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Service(
            id: 'service2',
            name: 'DEEP CLEANING',
            description: 'Deep house cleaning',
            basePrice: 100.0,
            category: 'Core Cleaning',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        provider.setServices(services);

        // Act
        final results1 = provider.searchServices('basic');
        final results2 = provider.searchServices('DEEP');
        final results3 = provider.searchServices('cleaning');

        // Assert
        expect(results1.length, equals(1));
        expect(results1[0].name, equals('Basic Cleaning'));
        
        expect(results2.length, equals(1));
        expect(results2[0].name, equals('DEEP CLEANING'));
        
        expect(results3.length, equals(2));
      });
    });

    group('Service Data Validation', () {
      test('should handle service with all required fields', () {
        // Arrange
        final service = Service(
          id: 'test_service',
          name: 'Test Service',
          description: 'Test description',
          basePrice: 99.99,
          category: 'Test Category',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        provider.setServices([service]);

        // Assert
        expect(provider.allServices.length, equals(1));
        expect(provider.allServices[0].id, equals('test_service'));
        expect(provider.allServices[0].name, equals('Test Service'));
        expect(provider.allServices[0].basePrice, equals(99.99));
        expect(provider.allServices[0].category, equals('Test Category'));
      });

      test('should handle multiple services with same category', () {
        // Arrange
        final services = [
          Service(
            id: 'service1',
            name: 'Service 1',
            description: 'Description 1',
            basePrice: 50.0,
            category: 'Same Category',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Service(
            id: 'service2',
            name: 'Service 2',
            description: 'Description 2',
            basePrice: 75.0,
            category: 'Same Category',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Service(
            id: 'service3',
            name: 'Service 3',
            description: 'Description 3',
            basePrice: 100.0,
            category: 'Same Category',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        // Act
        provider.setServices(services);

        // Assert
        final sameCategoryServices = provider.getServicesByCategory('Same Category');
        expect(sameCategoryServices.length, equals(3));
        
        final stats = provider.getServiceStatistics();
        expect(stats['Same Category'], equals(3));
      });
    });
  });
}
