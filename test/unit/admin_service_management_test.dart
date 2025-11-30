// test/unit/admin_service_management_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:demo_ncl/providers/admin_service_provider.dart';
import 'package:demo_ncl/models/service_model.dart';

import 'admin_service_management_test.mocks.dart';

@GenerateMocks([FirebaseFirestore, CollectionReference, DocumentReference, Query, QuerySnapshot, DocumentSnapshot])
void main() {
  group('Admin Service Management Tests', () {
    late AdminServiceProvider provider;
    late MockFirebaseFirestore mockFirestore;
    late MockCollectionReference mockCollection;
    late MockDocumentReference mockDocRef;
    late MockQuery mockQuery;
    late MockQuerySnapshot mockQuerySnapshot;
    late MockDocumentSnapshot mockDocumentSnapshot;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockCollection = MockCollectionReference();
      mockDocRef = MockDocumentReference();
      mockQuery = MockQuery();
      mockQuerySnapshot = MockQuerySnapshot();
      mockDocumentSnapshot = MockDocumentSnapshot();
      
      provider = AdminServiceProvider();

      // Setup mock returns
      when(mockFirestore.collection('services')).thenReturn(mockCollection);
      when(mockFirestore.collection('service_settings')).thenReturn(mockCollection);
      when(mockCollection.doc('active_services')).thenReturn(mockDocRef);
    });

    group('Service Loading', () {
      test('should load all services successfully', () async {
        // Arrange
        final mockServices = [
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
        ];

        when(mockCollection.get()).thenAnswer((_) async => mockQuerySnapshot);
        when(mockQuerySnapshot.docs).thenReturn([
          MockQueryDocumentSnapshot('service1', mockServices[0].toJson()),
          MockQueryDocumentSnapshot('service2', mockServices[1].toJson()),
        ]);
        when(mockDocRef.get()).thenAnswer((_) async => mockDocumentSnapshot);
        when(mockDocumentSnapshot.exists).thenReturn(true);
        when(mockDocumentSnapshot.data()).thenReturn({
          'active_service_ids': ['service1', 'service2']
        });

        // Act
        await provider.loadAllServices();

        // Assert
        expect(provider.allServices.length, equals(2));
        expect(provider.allServices[0].name, equals('Basic Cleaning'));
        expect(provider.allServices[1].name, equals('Deep Cleaning'));
        expect(provider.getActiveServices().length, equals(2));
        expect(provider.isServiceActive('service1'), isTrue);
        expect(provider.isServiceActive('service2'), isTrue);
      });

      test('should handle empty services list', () async {
        // Arrange
        when(mockCollection.get()).thenAnswer((_) async => mockQuerySnapshot);
        when(mockQuerySnapshot.docs).thenReturn([]);
        when(mockDocRef.get()).thenAnswer((_) async => mockDocumentSnapshot);
        when(mockDocumentSnapshot.exists).thenReturn(false);

        // Act
        await provider.loadAllServices();

        // Assert
        expect(provider.allServices.isEmpty, isTrue);
        expect(provider.getActiveServices().isEmpty, isTrue);
      });
    });

    group('Service Status Management', () {
      test('should activate service successfully', () async {
        // Arrange
        final service = Service(
          id: 'service1',
          name: 'Test Service',
          description: 'Test description',
          basePrice: 75.0,
          category: 'Test Category',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        provider.setServices([service]);
        provider.setActiveServices({}); // Initially inactive

        when(mockDocRef.get()).thenAnswer((_) async => mockDocumentSnapshot);
        when(mockDocumentSnapshot.exists).thenReturn(false);
        when(mockFirestore.runTransaction(any)).thenAnswer((_) async {
          // Mock transaction success
        });

        // Act
        await provider.updateServiceStatus('service1', true);

        // Assert
        expect(provider.isServiceActive('service1'), isTrue);
      });

      test('should deactivate service successfully', () async {
        // Arrange
        final service = Service(
          id: 'service1',
          name: 'Test Service',
          description: 'Test description',
          basePrice: 75.0,
          category: 'Test Category',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        provider.setServices([service]);
        provider.setActiveServices({'service1'}); // Initially active

        when(mockDocRef.get()).thenAnswer((_) async => mockDocumentSnapshot);
        when(mockDocumentSnapshot.exists).thenReturn(true);
        when(mockDocumentSnapshot.data()).thenReturn({
          'active_service_ids': ['service1']
        });
        when(mockFirestore.runTransaction(any)).thenAnswer((_) async {
          // Mock transaction success
        });

        // Act
        await provider.updateServiceStatus('service1', false);

        // Assert
        expect(provider.isServiceActive('service1'), isFalse);
      });
    });

    group('Service CRUD Operations', () {
      test('should add new service successfully', () async {
        // Arrange
        final newService = Service(
          id: 'new_service',
          name: 'New Service',
          description: 'New service description',
          basePrice: 125.0,
          category: 'New Category',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(mockCollection.doc('new_service')).thenReturn(mockDocRef);
        when(mockDocRef.set(any)).thenAnswer((_) async {});
        when(mockDocRef.get()).thenAnswer((_) async => mockDocumentSnapshot);
        when(mockDocumentSnapshot.exists).thenReturn(false);
        when(mockFirestore.runTransaction(any)).thenAnswer((_) async {});

        // Act
        await provider.addService(newService);

        // Assert
        expect(provider.allServices.contains(newService), isTrue);
        expect(provider.isServiceActive('new_service'), isTrue);
      });

      test('should update existing service successfully', () async {
        // Arrange
        final existingService = Service(
          id: 'service1',
          name: 'Original Name',
          description: 'Original description',
          basePrice: 50.0,
          category: 'Original Category',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final updatedService = Service(
          id: 'service1',
          name: 'Updated Name',
          description: 'Updated description',
          basePrice: 75.0,
          category: 'Updated Category',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        provider.setServices([existingService]);

        when(mockCollection.doc('service1')).thenReturn(mockDocRef);
        when(mockDocRef.update(any)).thenAnswer((_) async {});

        // Act
        await provider.updateService(updatedService);

        // Assert
        expect(provider.allServices.length, equals(1));
        expect(provider.allServices[0].name, equals('Updated Name'));
        expect(provider.allServices[0].basePrice, equals(75.0));
      });

      test('should delete service successfully', () async {
        // Arrange
        final serviceToDelete = Service(
          id: 'service1',
          name: 'Service to Delete',
          description: 'Will be deleted',
          basePrice: 50.0,
          category: 'Test Category',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        provider.setServices([serviceToDelete]);
        provider.setActiveServices({'service1'});

        when(mockCollection.doc('service1')).thenReturn(mockDocRef);
        when(mockDocRef.delete()).thenAnswer((_) async {});
        when(mockDocRef.get()).thenAnswer((_) async => mockDocumentSnapshot);
        when(mockDocumentSnapshot.exists).thenReturn(true);
        when(mockDocumentSnapshot.data()).thenReturn({
          'active_service_ids': ['service1']
        });
        when(mockFirestore.runTransaction(any)).thenAnswer((_) async {});

        // Act
        await provider.deleteService('service1');

        // Assert
        expect(provider.allServices.isEmpty, isTrue);
        expect(provider.isServiceActive('service1'), isFalse);
      });
    });

    group('Service Statistics', () {
      test('should calculate correct statistics', () {
        // Arrange
        final services = [
          Service(
            id: 'service1',
            name: 'Service 1',
            description: 'Description 1',
            basePrice: 50.0,
            category: 'Core Cleaning',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Service(
            id: 'service2',
            name: 'Service 2',
            description: 'Description 2',
            basePrice: 75.0,
            category: 'Home Care',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Service(
            id: 'service3',
            name: 'Service 3',
            description: 'Description 3',
            basePrice: 100.0,
            category: 'Core Cleaning',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        provider.setServices(services);
        provider.setActiveServices({'service1', 'service3'});

        // Act
        final stats = provider.getServiceStatistics();

        // Assert
        expect(stats['total'], equals(3));
        expect(stats['active'], equals(2));
        expect(stats['inactive'], equals(1));
        expect(stats['Core Cleaning'], equals(2));
        expect(stats['Home Care'], equals(1));
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

        // Assert
        expect(results.length, equals(2));
        expect(results[0].name, equals('Basic Cleaning'));
        expect(results[1].name, equals('Deep Cleaning'));
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

        // Assert
        expect(coreServices.length, equals(2));
        expect(coreServices.every((s) => s.category == 'Core Cleaning'), isTrue);
      });
    });

    group('Error Handling', () {
      test('should handle load services error', () async {
        // Arrange
        when(mockCollection.get()).thenThrow(Exception('Firestore error'));

        // Act
        await provider.loadAllServices();

        // Assert
        expect(provider.error, isNotNull);
        expect(provider.error!.contains('Failed to load services'), isTrue);
        expect(provider.isLoading, isFalse);
      });

      test('should clear error successfully', () {
        // Arrange
        provider.setError('Test error');

        // Act
        provider.clearError();

        // Assert
        expect(provider.error, isNull);
      });
    });
  });
}

// Mock helper class
class MockQueryDocumentSnapshot {
  final String id;
  final Map<String, dynamic> data;

  MockQueryDocumentSnapshot(this.id, this.data);
}
