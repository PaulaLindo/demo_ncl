// test/integration/login_functionality_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:demo_ncl/screens/auth/login_screen.dart';
import 'package:demo_ncl/providers/auth_provider.dart';
import 'package:demo_ncl/services/mock_data_service.dart';
import 'package:demo_ncl/models/auth_model.dart';

void main() {
  group('Login Functionality Tests', () {
    late MockDataService mockDataService;
    late AuthProvider authProvider;

    setUp(() {
      mockDataService = MockDataService();
      authProvider = AuthProvider(mockDataService);
    });

    tearDown(() {
      authProvider.dispose();
    });

    testWidgets('should display customer login form with email and password fields', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => authProvider,
          child: MaterialApp(
            home: LoginScreen(userRole: 'customer'),
          ),
        ),
      );

      // Verify the login form elements
      expect(find.text('Customer Login'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2)); // Email and password
      expect(find.text('Sign In'), findsOneWidget);
      
      // Check if email field exists
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
      
      // Check if password field exists
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('should successfully login with valid customer credentials', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => authProvider,
          child: MaterialApp(
            home: LoginScreen(userRole: 'customer'),
          ),
        ),
      );

      // Find text fields by their icons
      final emailField = find.byIcon(Icons.email_outlined);
      final passwordField = find.byIcon(Icons.lock_outline);
      
      expect(emailField, findsOneWidget);
      expect(passwordField, findsOneWidget);

      // Enter valid credentials by tapping on the fields
      await tester.tap(emailField);
      await tester.enterText(emailField, 'customer@example.com');
      
      await tester.tap(passwordField);
      await tester.enterText(passwordField, 'customer123');

      // Tap the Sign In button
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Verify successful login
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.currentUser?.email, equals('customer@example.com'));
      expect(authProvider.currentUser?.role, equals(UserRole.customer));
      expect(authProvider.currentUser?.password, isNull); // Password should be removed
    });

    testWidgets('should show error message with invalid credentials', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => authProvider,
          child: MaterialApp(
            home: LoginScreen(userRole: 'customer'),
          ),
        ),
      );

      // Find text fields by their icons
      final emailField = find.byIcon(Icons.email_outlined);
      final passwordField = find.byIcon(Icons.lock_outline);

      // Enter invalid credentials
      await tester.tap(emailField);
      await tester.enterText(emailField, 'customer@example.com');
      
      await tester.tap(passwordField);
      await tester.enterText(passwordField, 'wrongpassword');

      // Tap the Sign In button
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Verify login failed
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.errorMessage, equals('Invalid credentials'));
      
      // Verify error message is displayed
      expect(find.text('Invalid credentials'), findsOneWidget);
    });

    testWidgets('should show error message with non-existent user', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => authProvider,
          child: MaterialApp(
            home: LoginScreen(userRole: 'customer'),
          ),
        ),
      );

      // Find text fields by their icons
      final emailField = find.byIcon(Icons.email_outlined);
      final passwordField = find.byIcon(Icons.lock_outline);

      // Enter non-existent user credentials
      await tester.tap(emailField);
      await tester.enterText(emailField, 'nonexistent@example.com');
      
      await tester.tap(passwordField);
      await tester.enterText(passwordField, 'password123');

      // Tap the Sign In button
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Verify login failed
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.errorMessage, equals('User not found'));
      
      // Verify error message is displayed
      expect(find.text('User not found'), findsOneWidget);
    });

    testWidgets('should successfully login with valid staff credentials', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => authProvider,
          child: MaterialApp(
            home: LoginScreen(userRole: 'staff'),
          ),
        ),
      );

      // Find text fields by their icons
      final emailField = find.byIcon(Icons.email_outlined);
      final passwordField = find.byIcon(Icons.lock_outline);

      // Enter valid credentials
      await tester.tap(emailField);
      await tester.enterText(emailField, 'staff@example.com');
      
      await tester.tap(passwordField);
      await tester.enterText(passwordField, 'staff123');

      // Tap the Sign In button
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Verify successful login
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.currentUser?.email, equals('staff@example.com'));
      expect(authProvider.currentUser?.role, equals(UserRole.staff));
      expect(authProvider.currentUser?.password, isNull); // Password should be removed
    });

    testWidgets('should successfully login with valid admin credentials', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => authProvider,
          child: MaterialApp(
            home: LoginScreen(userRole: 'admin'),
          ),
        ),
      );

      // Find text fields by their icons
      final emailField = find.byIcon(Icons.email_outlined);
      final passwordField = find.byIcon(Icons.lock_outline);

      // Enter valid credentials
      await tester.tap(emailField);
      await tester.enterText(emailField, 'admin@example.com');
      
      await tester.tap(passwordField);
      await tester.enterText(passwordField, 'admin123');

      // Tap the Sign In button
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Verify successful login
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.currentUser?.email, equals('admin@example.com'));
      expect(authProvider.currentUser?.role, equals(UserRole.admin));
      expect(authProvider.currentUser?.password, isNull); // Password should be removed
    });
  });
}
