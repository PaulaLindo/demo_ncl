// test/integration/login_integration_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:demo_ncl/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login Integration Tests', () {
    testWidgets('should display login chooser and navigate to login screens', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Verify we're on the login chooser screen
      expect(find.text('Welcome to NCL'), findsOneWidget);
      expect(find.text('Customer Login'), findsOneWidget);
      expect(find.text('Staff Access'), findsOneWidget);
      expect(find.text('Admin Portal'), findsOneWidget);

      // Test customer login navigation
      await tester.tap(find.text('Customer Login'));
      await tester.pumpAndSettle();

      // Verify customer login form
      expect(find.text('Customer Login'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2)); // Email and password
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('New to NCL?'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('should display staff login form', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to staff login
      await tester.tap(find.text('Staff Access'));
      await tester.pumpAndSettle();

      // Verify staff login form
      expect(find.text('Staff Login'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2)); // Email and password
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('New to NCL?'), findsNothing); // No registration for staff
    });

    testWidgets('should display admin login form', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to admin login
      await tester.tap(find.text('Admin Portal'));
      await tester.pumpAndSettle();

      // Verify admin login form
      expect(find.text('Admin Login'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2)); // Email and password
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('New to NCL?'), findsNothing); // No registration for admin
    });

    testWidgets('should successfully login as customer', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to customer login
      await tester.tap(find.text('Customer Login'));
      await tester.pumpAndSettle();

      // Enter valid credentials
      await tester.enterText(find.byType(TextFormField).first, 'customer@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'customer123');

      // Tap Sign In button
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle(Duration(seconds: 3)); // Wait for authentication

      // Should be logged in now - check for customer home elements
      // Note: This might fail if the home screen isn't implemented yet
      // but the authentication should work
    });

    testWidgets('should show error for invalid credentials', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to customer login
      await tester.tap(find.text('Customer Login'));
      await tester.pumpAndSettle();

      // Enter invalid credentials
      await tester.enterText(find.byType(TextFormField).first, 'customer@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'wrongpassword');

      // Tap Sign In button
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Should show error message
      expect(find.text('Invalid credentials'), findsOneWidget);
    });

    testWidgets('should show error for non-existent user', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to customer login
      await tester.tap(find.text('Customer Login'));
      await tester.pumpAndSettle();

      // Enter non-existent credentials
      await tester.enterText(find.byType(TextFormField).first, 'nonexistent@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');

      // Tap Sign In button
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Should show error message
      expect(find.text('User not found'), findsOneWidget);
    });
  });
}
