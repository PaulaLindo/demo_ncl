// test/integration/customer_registration_integration_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:demo_ncl/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Customer Registration Integration Tests', () {
    testWidgets('Complete customer registration flow', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to customer login
      await tester.tap(find.text('Customer Login'));
      await tester.pumpAndSettle();

      // Verify we're on customer login screen
      expect(find.text('Customer Login'), findsOneWidget);
      
      // Click on "Create Account" link
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      // Verify we're on registration screen
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Join NCL for premium home services'), findsOneWidget);

      // Fill in the registration form
      await tester.enterText(find.byKey(const Key('full_name_field')), 'John Doe');
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('email_field')), 'john.doe@example.com');
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('phone_field')), '1234567890');
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('confirm_password_field')), 'password123');
      await tester.pumpAndSettle();

      // Accept terms and conditions
      await tester.tap(find.byKey(const Key('terms_checkbox')));
      await tester.pumpAndSettle();

      // Submit registration
      await tester.tap(find.byKey(const Key('register_button')));
      await tester.pumpAndSettle(Duration(seconds: 2));

      // Verify successful registration (should navigate to customer dashboard)
      expect(find.text('Customer Dashboard'), findsOneWidget);
    });

    testWidgets('Registration form validation', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to registration
      await tester.tap(find.text('Customer Login'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      // Try to submit empty form
      await tester.tap(find.byKey(const Key('register_button')));
      await tester.pumpAndSettle();

      // Should show validation errors
      expect(find.text('Please enter your full name'), findsOneWidget);
    });

    testWidgets('Password mismatch validation', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to registration
      await tester.tap(find.text('Customer Login'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      // Fill form with mismatched passwords
      await tester.enterText(find.byKey(const Key('full_name_field')), 'Jane Smith');
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('email_field')), 'jane@example.com');
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('phone_field')), '9876543210');
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('confirm_password_field')), 'differentpassword');
      await tester.pumpAndSettle();

      // Accept terms
      await tester.tap(find.byKey(const Key('terms_checkbox')));
      await tester.pumpAndSettle();

      // Try to submit
      await tester.tap(find.byKey(const Key('register_button')));
      await tester.pumpAndSettle();

      // Should show password mismatch error
      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('Terms acceptance required', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to registration
      await tester.tap(find.text('Customer Login'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      // Fill form but don't accept terms
      await tester.enterText(find.byKey(const Key('full_name_field')), 'Test User');
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('phone_field')), '1234567890');
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('confirm_password_field')), 'password123');
      await tester.pumpAndSettle();

      // Try to submit without accepting terms
      await tester.tap(find.byKey(const Key('register_button')));
      await tester.pumpAndSettle();

      // Should show terms error message
      expect(find.text('Please agree to the Terms & Conditions'), findsOneWidget);
    });

    testWidgets('Navigate back to login', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to registration
      await tester.tap(find.text('Customer Login'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      // Click "Already have an account? Sign In"
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Should be back on login screen
      expect(find.text('Customer Login'), findsOneWidget);
      expect(find.text('New to NCL? Create Account'), findsOneWidget);
    });
  });
}
