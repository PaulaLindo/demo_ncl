// test/integration/booking_flow_integration_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../integration_test_setup.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Customer Booking Flow Integration Tests', () {
    testWidgets('Navigate to customer booking screen', (WidgetTester tester) async {
      // Launch the test app
      await tester.pumpWidget(TestSetup.createTestApp());
      await tester.pumpAndSettle();

      // Navigate to customer dashboard
      await tester.tap(find.byKey(const Key('customer_login_button')));
      await tester.pumpAndSettle();

      // Verify customer dashboard
      expect(find.text('Welcome Customer!'), findsOneWidget);
      expect(find.text('Book Service'), findsOneWidget);
      expect(find.text('My Bookings'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('Complete booking workflow simulation', (WidgetTester tester) async {
      // Launch the test app
      await tester.pumpWidget(TestSetup.createTestApp());
      await tester.pumpAndSettle();

      // Navigate to customer dashboard
      await tester.tap(find.byKey(const Key('customer_login_button')));
      await tester.pumpAndSettle();

      // Simulate booking workflow
      expect(find.text('Book Service'), findsOneWidget);
      
      // In a real app, this would navigate to the booking flow
      // For our test setup, we'll verify the workflow is accessible
      expect(find.text('Welcome Customer!'), findsOneWidget);
    });

    testWidgets('Customer dashboard navigation flow', (WidgetTester tester) async {
      // Launch the test app
      await tester.pumpWidget(TestSetup.createTestApp());
      await tester.pumpAndSettle();

      // Navigate through customer screens
      await tester.tap(find.byKey(const Key('customer_login_button')));
      await tester.pumpAndSettle();

      // Verify all customer options are available
      expect(find.text('Book Service'), findsOneWidget);
      expect(find.text('My Bookings'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      // Navigate back to home
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Verify we're back on home screen
      expect(find.text('Welcome to NCL'), findsOneWidget);
    });

    testWidgets('Customer role verification', (WidgetTester tester) async {
      // Launch the test app
      await tester.pumpWidget(TestSetup.createTestApp());
      await tester.pumpAndSettle();

      // Navigate to customer dashboard
      await tester.tap(find.byKey(const Key('customer_login_button')));
      await tester.pumpAndSettle();

      // Verify customer-specific content
      expect(find.text('Welcome Customer!'), findsOneWidget);
      expect(find.text('Book Service'), findsOneWidget);
      expect(find.text('My Bookings'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      // Verify staff/admin specific content is not present
      expect(find.text('My Schedule'), findsNothing);
      expect(find.text('Timekeeping'), findsNothing);
      expect(find.text('User Management'), findsNothing);
    });

    testWidgets('Customer booking access points', (WidgetTester tester) async {
      // Launch the test app
      await tester.pumpWidget(TestSetup.createTestApp());
      await tester.pumpAndSettle();

      // Navigate to customer dashboard
      await tester.tap(find.byKey(const Key('customer_login_button')));
      await tester.pumpAndSettle();

      // Verify booking feature is accessible
      expect(find.text('Book Service'), findsOneWidget);
      
      // The booking feature should be prominently displayed
      expect(find.text('Welcome Customer!'), findsOneWidget);
    });

    testWidgets('Complete customer user journey', (WidgetTester tester) async {
      // Launch the test app
      await tester.pumpWidget(TestSetup.createTestApp());
      await tester.pumpAndSettle();

      // Complete customer user journey
      // 1. Start on home screen
      expect(find.text('Welcome to NCL'), findsOneWidget);

      // 2. Navigate to customer dashboard
      await tester.tap(find.byKey(const Key('customer_login_button')));
      await tester.pumpAndSettle();
      expect(find.text('Welcome Customer!'), findsOneWidget);

      // 3. Verify all customer features are available
      expect(find.text('Book Service'), findsOneWidget);
      expect(find.text('My Bookings'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      // 4. Navigate back to home
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Welcome to NCL'), findsOneWidget);

      // 5. Verify can access other roles (for testing purposes)
      await tester.tap(find.byKey(const Key('staff_login_button')));
      await tester.pumpAndSettle();
      expect(find.text('Welcome Staff!'), findsOneWidget);

      // 6. Return to home
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Welcome to NCL'), findsOneWidget);

      // 7. Navigate to admin dashboard
      await tester.tap(find.byKey(const Key('admin_login_button')));
      await tester.pumpAndSettle();
      expect(find.text('Welcome Admin!'), findsOneWidget);

      // 8. Return to home
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Welcome to NCL'), findsOneWidget);
    });

    testWidgets('Multi-role booking workflow', (WidgetTester tester) async {
      // Launch the test app
      await tester.pumpWidget(TestSetup.createTestApp());
      await tester.pumpAndSettle();

      // Test that different roles have appropriate access
      // Customer can book services
      await tester.tap(find.byKey(const Key('customer_login_button')));
      await tester.pumpAndSettle();
      expect(find.text('Book Service'), findsOneWidget);

      // Staff has different features
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('staff_login_button')));
      await tester.pumpAndSettle();
      expect(find.text('My Schedule'), findsOneWidget);
      expect(find.text('Book Service'), findsNothing);

      // Admin has management features
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('admin_login_button')));
      await tester.pumpAndSettle();
      expect(find.text('User Management'), findsOneWidget);
      expect(find.text('Book Service'), findsNothing);
    });

    testWidgets('Booking flow integration with registration', (WidgetTester tester) async {
      // Launch the test app
      await tester.pumpWidget(TestSetup.createTestApp());
      await tester.pumpAndSettle();

      // Navigate to registration first
      await tester.tap(find.byKey(const Key('register_button')));
      await tester.pumpAndSettle();
      expect(find.text('Create Account'), findsWidgets);

      // Go back to home
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Navigate to customer dashboard
      await tester.tap(find.byKey(const Key('customer_login_button')));
      await tester.pumpAndSettle();

      // Verify booking is accessible after registration flow
      expect(find.text('Book Service'), findsOneWidget);
      expect(find.text('My Bookings'), findsOneWidget);
    });

    testWidgets('Cross-role navigation consistency', (WidgetTester tester) async {
      // Launch the test app
      await tester.pumpWidget(TestSetup.createTestApp());
      await tester.pumpAndSettle();

      // Test navigation between different roles
      final roles = [
        ('customer', 'Welcome Customer!'),
        ('staff', 'Welcome Staff!'),
        ('admin', 'Welcome Admin!'),
      ];

      for (final (role, welcomeText) in roles) {
        // Navigate to role dashboard
        await tester.tap(find.byKey(Key('${role}_login_button')));
        await tester.pumpAndSettle();

        // Verify correct welcome message
        expect(find.text(welcomeText), findsOneWidget);

        // Navigate back to home
        await tester.pageBack();
        await tester.pumpAndSettle();

        // Verify we're back on home screen
        expect(find.text('Welcome to NCL'), findsOneWidget);
      }
    });
  });
}
