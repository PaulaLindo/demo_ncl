// test/unit/services_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:demo_ncl/models/service_model.dart' as models;
import 'package:demo_ncl/providers/booking_provider.dart';
import 'package:demo_ncl/screens/customer/enhanced_services_screen.dart';

void main() {
  group('Services Screen Tests', () {
    testWidgets('should display services correctly', (WidgetTester tester) async {
      // Build the widget with provider
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => BookingProvider()),
        ],
        child: const MaterialApp(
          home: EnhancedServicesScreen(),
        ),
      ));

      // Verify the app bar title
      expect(find.text('Services'), findsOneWidget);

      // Verify search bar exists
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search services...'), findsOneWidget);

      // Verify category filters exist
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Cleaning'), findsOneWidget);

      // Verify service cards are displayed
      expect(find.text('Standard Cleaning'), findsOneWidget);
      expect(find.text('Deep Cleaning'), findsOneWidget);
      expect(find.text('Window Cleaning'), findsOneWidget);

      // Verify pricing is displayed
      expect(find.text('\$100.00'), findsOneWidget);
      expect(find.text('\$200.00'), findsOneWidget);
      expect(find.text('\$80.00'), findsOneWidget);
    });

    testWidgets('should filter services by category', (WidgetTester tester) async {
      // Build the widget with provider
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => BookingProvider()),
        ],
        child: const MaterialApp(
          home: EnhancedServicesScreen(),
        ),
      ));

      // Verify all services are initially shown
      expect(find.text('Standard Cleaning'), findsOneWidget);
      expect(find.text('Window Cleaning'), findsOneWidget);

      // Tap on Cleaning category filter
      await tester.tap(find.text('Cleaning'));
      await tester.pumpAndSettle();

      // Verify only cleaning services are shown
      expect(find.text('Standard Cleaning'), findsOneWidget);
      expect(find.text('Deep Cleaning'), findsOneWidget);
      expect(find.text('Window Cleaning'), findsOneWidget);
    });

    testWidgets('should search services correctly', (WidgetTester tester) async {
      // Build the widget with provider
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => BookingProvider()),
        ],
        child: const MaterialApp(
          home: EnhancedServicesScreen(),
        ),
      ));

      // Verify all services are initially shown
      expect(find.text('Standard Cleaning'), findsOneWidget);
      expect(find.text('Deep Cleaning'), findsOneWidget);

      // Enter search query
      await tester.enterText(find.byType(TextField), 'Deep');
      await tester.pumpAndSettle();

      // Verify only matching services are shown
      expect(find.text('Deep Cleaning'), findsOneWidget);
      expect(find.text('Standard Cleaning'), findsNothing);
    });

    testWidgets('should show service details when tapped', (WidgetTester tester) async {
      // Build the widget with provider
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => BookingProvider()),
        ],
        child: const MaterialApp(
          home: EnhancedServicesScreen(),
        ),
      ));

      // Tap on a service card
      await tester.tap(find.text('Standard Cleaning'));
      await tester.pumpAndSettle();

      // Verify service details modal is shown
      expect(find.text('Standard Cleaning'), findsWidgets); // One in card, one in modal
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('What\'s Included'), findsOneWidget);
      expect(find.text('Duration'), findsOneWidget);
      expect(find.text('Price'), findsOneWidget);
      expect(find.text('Book This Service'), findsOneWidget);
    });

    testWidgets('should display service ratings correctly', (WidgetTester tester) async {
      // Build the widget with provider
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => BookingProvider()),
        ],
        child: const MaterialApp(
          home: EnhancedServicesScreen(),
        ),
      ));

      // Verify ratings are displayed
      expect(find.text('4.5'), findsOneWidget);
      expect(find.text('4.8'), findsOneWidget);
      expect(find.text('4.3'), findsOneWidget);

      // Verify review counts are displayed
      expect(find.text('(128 reviews)'), findsOneWidget);
      expect(find.text('(89 reviews)'), findsOneWidget);
      expect(find.text('(67 reviews)'), findsOneWidget);
    });

    testWidgets('should display service features correctly', (WidgetTester tester) async {
      // Build the widget with provider
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => BookingProvider()),
        ],
        child: const MaterialApp(
          home: EnhancedServicesScreen(),
        ),
      ));

      // Verify features are displayed in service cards
      expect(find.text('All rooms'), findsOneWidget);
      expect(find.text('Deep scrubbing'), findsOneWidget);
      expect(find.text('Interior windows'), findsOneWidget);
    });

    testWidgets('should show availability status correctly', (WidgetTester tester) async {
      // Build the widget with provider
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => BookingProvider()),
        ],
        child: const MaterialApp(
          home: EnhancedServicesScreen(),
        ),
      ));

      // Verify availability badges are shown
      expect(find.text('Available'), findsWidgets); // Multiple services are available
    });

    testWidgets('should handle no results correctly', (WidgetTester tester) async {
      // Build the widget with provider
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => BookingProvider()),
        ],
        child: const MaterialApp(
          home: EnhancedServicesScreen(),
        ),
      ));

      // Enter search query with no results
      await tester.enterText(find.byType(TextField), 'NonexistentService');
      await tester.pumpAndSettle();

      // Verify no results message is shown
      expect(find.text('No services found'), findsOneWidget);
      expect(find.text('Try adjusting your search or filters'), findsOneWidget);
    });
  });

  group('Service Model Tests', () {
    test('should create Service with required properties', () {
      // Arrange
      final service = models.Service(
        id: '1',
        name: 'Test Service',
        description: 'Test description',
        basePrice: 100.0,
        duration: '2 hours',
        category: 'Test',
        rating: 4.5,
        reviewCount: 10,
        features: ['Feature 1', 'Feature 2'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Assert
      expect(service.id, equals('1'));
      expect(service.name, equals('Test Service'));
      expect(service.description, equals('Test description'));
      expect(service.basePrice, equals(100.0));
      expect(service.duration, equals('2 hours'));
      expect(service.category, equals('Test'));
      expect(service.rating, equals(4.5));
      expect(service.reviewCount, equals(10));
      expect(service.features, contains('Feature 1'));
      expect(service.features, contains('Feature 2'));
    });

    test('should create Service with all properties', () {
      // Arrange
      final service = models.Service(
        id: '2',
        name: 'Full Service',
        description: 'Complete service description',
        basePrice: 250.0,
        duration: '4 hours 30 minutes',
        category: 'Premium',
        imageUrl: 'https://example.com/image.jpg',
        rating: 4.8,
        reviewCount: 156,
        features: ['Feature 1', 'Feature 2', 'Feature 3', 'Feature 4'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Assert
      expect(service.id, equals('2'));
      expect(service.name, equals('Full Service'));
      expect(service.basePrice, equals(250.0));
      expect(service.duration, equals('4 hours 30 minutes'));
      expect(service.imageUrl, equals('https://example.com/image.jpg'));
      expect(service.rating, equals(4.8));
      expect(service.reviewCount, equals(156));
      expect(service.features.length, equals(4));
    });

    test('should handle empty features list', () {
      // Arrange
      final service = models.Service(
        id: '3',
        name: 'Basic Service',
        description: 'Basic description',
        basePrice: 50.0,
        duration: '1 hour',
        category: 'Basic',
        rating: 4.0,
        reviewCount: 5,
        features: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Assert
      expect(service.features, isEmpty);
    });

    test('should handle null image URL', () {
      // Arrange
      final service = models.Service(
        id: '4',
        name: 'No Image Service',
        description: 'Service without image',
        basePrice: 75.0,
        duration: '1 hour 30 minutes',
        category: 'Standard',
        rating: 4.2,
        reviewCount: 23,
        features: ['Basic feature'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Assert
      expect(service.imageUrl, isNull);
    });

    test('should handle rating boundaries', () {
      // Test minimum rating
      final minRatedService = models.Service(
        id: '5',
        name: 'Low Rated Service',
        description: 'Service with low rating',
        basePrice: 25.0,
        duration: '30 minutes',
        category: 'Budget',
        rating: 1.0,
        reviewCount: 1,
        features: ['Basic'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Test maximum rating
      final maxRatedService = models.Service(
        id: '6',
        name: 'High Rated Service',
        description: 'Service with high rating',
        basePrice: 500.0,
        duration: '8 hours',
        category: 'Luxury',
        rating: 5.0,
        reviewCount: 1000,
        features: ['Premium', 'Luxury', 'VIP'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Assert
      expect(minRatedService.rating, equals(1.0));
      expect(maxRatedService.rating, equals(5.0));
    });

    test('should handle zero review count', () {
      // Arrange
      final service = models.Service(
        id: '7',
        name: 'New Service',
        description: 'Brand new service',
        basePrice: 100.0,
        duration: '2 hours',
        category: 'New',
        rating: 0.0,
        reviewCount: 0,
        features: ['New feature'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Assert
      expect(service.reviewCount, equals(0));
      expect(service.rating, equals(0.0));
    });

    test('should handle different duration formats', () {
      // Test hours only
      final hoursOnlyService = models.Service(
        id: '8',
        name: 'Hours Only',
        description: 'Service with hours only',
        basePrice: 100.0,
        duration: '3 hours',
        category: 'Test',
        rating: 4.0,
        reviewCount: 10,
        features: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Test minutes only
      final minutesOnlyService = models.Service(
        id: '9',
        name: 'Minutes Only',
        description: 'Service with minutes only',
        basePrice: 50.0,
        duration: '45 minutes',
        category: 'Test',
        rating: 4.0,
        reviewCount: 10,
        features: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Test hours and minutes
      final hoursAndMinutesService = models.Service(
        id: '10',
        name: 'Hours and Minutes',
        description: 'Service with hours and minutes',
        basePrice: 150.0,
        duration: '2 hours 30 minutes',
        category: 'Test',
        rating: 4.0,
        reviewCount: 10,
        features: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Assert
      expect(hoursOnlyService.duration, equals('3 hours'));
      expect(minutesOnlyService.duration, equals('45 minutes'));
      expect(hoursAndMinutesService.duration, equals('2 hours 30 minutes'));
    });
  });
}
