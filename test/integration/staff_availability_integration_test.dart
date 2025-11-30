// test/integration/staff_availability_integration_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../integration_test_setup.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Staff Availability Integration Tests', () {
    testWidgets('Navigate to staff availability screen', (WidgetTester tester) async {
      // Launch the test app
      await tester.pumpWidget(TestSetup.createTestApp());
      await tester.pumpAndSettle();

      // Navigate to staff dashboard
      await tester.tap(find.byKey(const Key('staff_login_button')));
      await tester.pumpAndSettle();

      // Verify staff dashboard
      expect(find.text('Welcome Staff!'), findsOneWidget);
      expect(find.text('My Schedule'), findsOneWidget);
      expect(find.text('Timekeeping'), findsOneWidget);
      expect(find.text('Availability'), findsOneWidget);
    });

    testWidgets('Complete availability workflow simulation', (WidgetTester tester) async {
      // Launch the test app
      await tester.pumpWidget(TestSetup.createTestApp());
      await tester.pumpAndSettle();

      // Navigate to staff dashboard
      await tester.tap(find.byKey(const Key('staff_login_button')));
      await tester.pumpAndSettle();

      // Simulate availability management workflow
      expect(find.text('Availability'), findsOneWidget);
      
      // In a real app, this would navigate to the availability screen
      // For our test setup, we'll verify the workflow is accessible
      expect(find.text('Welcome Staff!'), findsOneWidget);
    });

    testWidgets('Staff dashboard navigation flow', (WidgetTester tester) async {
      // Launch the test app
      await tester.pumpWidget(TestSetup.createTestApp());
      await tester.pumpAndSettle();

      // Navigate through staff screens
      await tester.tap(find.byKey(const Key('staff_login_button')));
      await tester.pumpAndSettle();

      // Verify all staff options are available
      expect(find.text('My Schedule'), findsOneWidget);
      expect(find.text('Timekeeping'), findsOneWidget);
      expect(find.text('Availability'), findsOneWidget);

      // Navigate back to home
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Verify we're back on home screen
      expect(find.text('Welcome to NCL'), findsOneWidget);
    });

    testWidgets('Staff role verification', (WidgetTester tester) async {
      // Launch the test app
      await tester.pumpWidget(TestSetup.createTestApp());
      await tester.pumpAndSettle();

      // Navigate to staff dashboard
      await tester.tap(find.byKey(const Key('staff_login_button')));
      await tester.pumpAndSettle();

      // Verify staff-specific content
      expect(find.text('Welcome Staff!'), findsOneWidget);
      expect(find.text('My Schedule'), findsOneWidget);
      expect(find.text('Timekeeping'), findsOneWidget);
      expect(find.text('Availability'), findsOneWidget);

      // Verify customer/admin specific content is not present
      expect(find.text('Book Service'), findsNothing);
      expect(find.text('User Management'), findsNothing);
    });

    testWidgets('Staff availability access points', (WidgetTester tester) async {
      // Launch the test app
      await tester.pumpWidget(TestSetup.createTestApp());
      await tester.pumpAndSettle();

      // Navigate to staff dashboard
      await tester.tap(find.byKey(const Key('staff_login_button')));
      await tester.pumpAndSettle();

      // Verify availability feature is accessible
      expect(find.text('Availability'), findsOneWidget);
      
      // The availability feature should be prominently displayed
      expect(find.text('Welcome Staff!'), findsOneWidget);
    });

    testWidgets('Complete staff user journey', (WidgetTester tester) async {
      // Launch the test app
      await tester.pumpWidget(TestSetup.createTestApp());
      await tester.pumpAndSettle();

      // Complete staff user journey
      // 1. Start on home screen
      expect(find.text('Welcome to NCL'), findsOneWidget);

      // 2. Navigate to staff dashboard
      await tester.tap(find.byKey(const Key('staff_login_button')));
      await tester.pumpAndSettle();
      expect(find.text('Welcome Staff!'), findsOneWidget);

      // 3. Verify all staff features are available
      expect(find.text('My Schedule'), findsOneWidget);
      expect(find.text('Timekeeping'), findsOneWidget);
      expect(find.text('Availability'), findsOneWidget);

      // 4. Navigate back to home
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Welcome to NCL'), findsOneWidget);

      // 5. Verify can access other roles (for testing purposes)
      await tester.tap(find.byKey(const Key('customer_login_button')));
      await tester.pumpAndSettle();
      expect(find.text('Welcome Customer!'), findsOneWidget);

      // 6. Return to home
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Welcome to NCL'), findsOneWidget);
    });
  });
}
