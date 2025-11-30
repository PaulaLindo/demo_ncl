// test/integration/complete_login_system_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:demo_ncl/providers/auth_provider.dart';
import 'package:demo_ncl/services/mock_data_service.dart';
import 'package:demo_ncl/main_chooser.dart';
import 'package:demo_ncl/screens/customer_login_screen.dart';
import 'package:demo_ncl/screens/staff_login_screen.dart';
import 'package:demo_ncl/screens/admin_login_screen.dart';

void main() {
  group('Complete Login System Integration Tests', () {
    late AuthProvider authProvider;

    setUp(() {
      authProvider = AuthProvider();
    });

    testWidgets('should display login chooser screen with all options', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: const ChooserApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Check main welcome text
      expect(find.text('Welcome to NCL'), findsOneWidget);
      expect(find.text('Professional Cleaning & Home Services'), findsOneWidget);

      // Check login options
      expect(find.text('Customer Login'), findsOneWidget);
      expect(find.text('Staff Access'), findsOneWidget);
      expect(find.text('Admin Portal'), findsOneWidget);

      // Check descriptions
      expect(find.text('Book and manage your cleaning services'), findsOneWidget);
      expect(find.text('Manage your work schedule and assignments'), findsOneWidget);
      expect(find.text('System administration and management'), findsOneWidget);
    });

    testWidgets('should navigate to customer login screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: const ChooserApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on Customer Login
      await tester.tap(find.text('Customer Login'));
      await tester.pumpAndSettle();

      // Should be on customer login screen
      expect(find.text('Customer Login'), findsWidgets); // AppBar title
      expect(find.text('Access your cleaning services account'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('should navigate to staff login screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: const ChooserApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on Staff Access
      await tester.tap(find.text('Staff Access'));
      await tester.pumpAndSettle();

      // Should be on staff login screen
      expect(find.text('Staff Access'), findsWidgets); // AppBar title
      expect(find.text('Access your work schedule and assignments'), findsOneWidget);
      expect(find.text('Staff Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('should navigate to admin login screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: const ChooserApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on Admin Portal
      await tester.tap(find.text('Admin Portal'));
      await tester.pumpAndSettle();

      // Should be on admin login screen
      expect(find.text('Admin Portal'), findsWidgets); // AppBar title
      expect(find.text('System administration and management'), findsOneWidget);
      expect(find.text('Admin Email'), findsOneWidget);
      expect(find.text('Admin Password'), findsOneWidget);
      expect(find.text('Login to Admin Portal'), findsOneWidget);
    });

    testWidgets('should complete customer login flow successfully', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: const ChooserApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to customer login
      await tester.tap(find.text('Customer Login'));
      await tester.pumpAndSettle();

      // Fill in login form
      await tester.enterText(find.byType(TextFormField).first, 'customer@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'customer123');

      // Tap login button
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Should show success dialog
      expect(find.text('Login Successful!'), findsOneWidget);
      expect(find.text('Welcome back, customer@example.com!'), findsOneWidget);
    });

    testWidgets('should complete staff login flow successfully', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: const ChooserApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to staff login
      await tester.tap(find.text('Staff Access'));
      await tester.pumpAndSettle();

      // Fill in login form
      await tester.enterText(find.byType(TextFormField).first, 'staff@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'staff123');

      // Tap login button
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Should show success dialog
      expect(find.text('Login Successful!'), findsOneWidget);
      expect(find.text('Welcome back, staff@example.com!'), findsOneWidget);
    });

    testWidgets('should complete admin login flow successfully', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: const ChooserApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to admin login
      await tester.tap(find.text('Admin Portal'));
      await tester.pumpAndSettle();

      // Fill in login form
      await tester.enterText(find.byType(TextFormField).first, 'admin@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'admin123');

      // Tap login button
      await tester.tap(find.text('Login to Admin Portal'));
      await tester.pumpAndSettle();

      // Should show success dialog
      expect(find.text('Admin Access Granted'), findsOneWidget);
      expect(find.text('Welcome, Administrator admin@example.com!'), findsOneWidget);
    });

    testWidgets('should handle invalid login credentials', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: const ChooserApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to customer login
      await tester.tap(find.text('Customer Login'));
      await tester.pumpAndSettle();

      // Fill in invalid credentials
      await tester.enterText(find.byType(TextFormField).first, 'customer@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'wrongpassword');

      // Tap login button
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Should show error message
      expect(find.text('Invalid credentials'), findsOneWidget);
    });

    testWidgets('should validate form fields correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: const ChooserApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to customer login
      await tester.tap(find.text('Customer Login'));
      await tester.pumpAndSettle();

      // Try to login with empty form
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Should show validation errors
      expect(find.text('Please enter your email address'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);

      // Test invalid email
      await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email address'), findsOneWidget);

      // Test short password
      await tester.enterText(find.byType(TextFormField).first, 'customer@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), '123');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    testWidgets('should navigate back to chooser from login screens', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: const ChooserApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to customer login
      await tester.tap(find.text('Customer Login'));
      await tester.pumpAndSettle();

      // Go back
      await tester.tap(find.text('Back to Login Options'));
      await tester.pumpAndSettle();

      // Should be back on chooser screen
      expect(find.text('Welcome to NCL'), findsOneWidget);
      expect(find.text('Customer Login'), findsOneWidget);
    });
  });
}
