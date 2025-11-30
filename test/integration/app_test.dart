// test/integration/app_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:demo_ncl/main.dart' as app;
import '../test_config.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('NCL App End-to-End Tests', () {
    testWidgets('App launches successfully', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Verify app launches and shows login chooser screen
      expect(find.text('Welcome to NCL'), findsOneWidget);
      expect(find.text('Customer Login'), findsOneWidget);
      expect(find.text('Staff Access'), findsOneWidget);
      expect(find.text('Admin Portal'), findsOneWidget);
    });

    testWidgets('Staff login flow', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Verify we're on login chooser screen
      expect(find.text('Welcome to NCL'), findsOneWidget);
      
      // Navigate to staff login
      await tester.tap(find.text('Staff Access'));
      await tester.pumpAndSettle();

      // Verify staff login screen
      expect(find.text('Staff Login'), findsOneWidget);
      expect(find.byKey(const Key('email_field')), findsOneWidget);
      expect(find.byKey(const Key('password_field')), findsOneWidget);
      
      // Enter staff credentials
      await TestConfig.enterTextSafely(tester, find.byKey(const Key('email_field')), TestConfig.staffEmail);
      await TestConfig.enterTextSafely(tester, find.byKey(const Key('password_field')), TestConfig.staffPassword);
      
      // Tap login button
      await TestConfig.tapButtonSafely(tester, find.text('Login'));
      await TestConfig.pumpAndSettle(tester);

      // Verify staff dashboard is loaded
      expect(find.text('Staff Dashboard'), findsOneWidget);
      expect(find.text('My Schedule'), findsOneWidget);
    });

    testWidgets('Customer login flow', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to customer login
      await tester.tap(find.text('Customer Login'));
      await tester.pumpAndSettle();

      // Verify customer login screen
      expect(find.text('Customer Login'), findsOneWidget);
      expect(find.byKey(const Key('email_field')), findsOneWidget);
      expect(find.byKey(const Key('password_field')), findsOneWidget);
      
      // Enter customer credentials
      await TestConfig.enterTextSafely(tester, find.byKey(const Key('email_field')), TestConfig.customerEmail);
      await TestConfig.enterTextSafely(tester, find.byKey(const Key('password_field')), TestConfig.customerPassword);
      
      // Tap login button
      await TestConfig.tapButtonSafely(tester, find.text('Login'));
      await TestConfig.pumpAndSettle(tester);

      // Verify customer dashboard is loaded
      expect(find.text('Customer Dashboard'), findsOneWidget);
      expect(find.text('Book Service'), findsOneWidget);
    });

    testWidgets('Admin login flow', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to admin login
      await tester.tap(find.text('Admin Portal'));
      await tester.pumpAndSettle();

      // Verify admin login screen
      expect(find.text('Admin Login'), findsOneWidget);
      expect(find.byKey(const Key('email_field')), findsOneWidget);
      expect(find.byKey(const Key('password_field')), findsOneWidget);
      
      // Enter admin credentials
      await TestConfig.enterTextSafely(tester, find.byKey(const Key('email_field')), TestConfig.adminEmail);
      await TestConfig.enterTextSafely(tester, find.byKey(const Key('password_field')), TestConfig.adminPassword);
      
      // Tap login button
      await TestConfig.tapButtonSafely(tester, find.text('Login'));
      await TestConfig.pumpAndSettle(tester);

      // Verify admin dashboard is loaded
      expect(find.text('Admin Dashboard'), findsOneWidget);
      expect(find.text('User Management'), findsOneWidget);
      expect(find.text('Booking Management'), findsOneWidget);
    });
  });
}
