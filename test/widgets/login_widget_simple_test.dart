// test/widgets/login_widget_simple_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:demo_ncl/screens/auth/login_chooser_screen.dart';
import 'package:demo_ncl/screens/auth/login_screen.dart';
import 'package:demo_ncl/providers/auth_provider.dart';
import 'package:demo_ncl/services/mock_data_service.dart';
import 'package:demo_ncl/models/auth_model.dart';

void main() {
  group('Login Chooser Screen Widget Tests', () {
    testWidgets('should display login chooser screen', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginChooserScreen(),
        ),
      );

      // Allow for layout to settle
      await tester.pumpAndSettle();

      // Verify the welcome message
      expect(find.text('Welcome to NCL'), findsOneWidget);
      expect(find.text('Professional home services\nat your fingertips'), findsOneWidget);

      // Verify login options
      expect(find.text('Customer Login'), findsOneWidget);
      expect(find.text('Staff Access'), findsOneWidget);
      expect(find.text('Admin Portal'), findsOneWidget);

      // Verify help button
      expect(find.text('Need help signing in?'), findsOneWidget);
    });
  });

  group('Login Screen Widget Tests', () {
    testWidgets('should display customer login form', (WidgetTester tester) async {
      final mockDataService = MockDataService();
      
      // Build our app and trigger a frame
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(mockDataService),
          child: MaterialApp(
            home: LoginScreen(userRole: 'customer'),
          ),
        ),
      );

      // Wait for the widget to be fully rendered
      await tester.pumpAndSettle();

      // Verify the login form elements
      expect(find.text('Customer Login'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Sign In'), findsOneWidget);
      
      // Verify registration link (only for customers)
      // Find the specific RichText that contains the registration text
      final richTextWidgets = find.byType(RichText);
      expect(richTextWidgets, findsWidgets);
      
      // Check if any RichText contains the expected registration text
      bool foundRegistrationText = false;
      for (final widget in tester.widgetList(richTextWidgets)) {
        if (widget is RichText) {
          final textSpan = widget.text as TextSpan;
          final plainText = textSpan.toPlainText();
          if (plainText.contains('New to NCL?') && plainText.contains('Create Account')) {
            foundRegistrationText = true;
            break;
          }
        }
      }
      expect(foundRegistrationText, isTrue, reason: 'Registration link RichText not found');
    });

    testWidgets('should display staff login form', (WidgetTester tester) async {
      final mockDataService = MockDataService();
      
      // Build our app and trigger a frame
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(mockDataService),
          child: MaterialApp(
            home: LoginScreen(userRole: 'staff'),
          ),
        ),
      );

      // Wait for the widget to be fully rendered
      await tester.pumpAndSettle();

      // Verify the login form elements
      expect(find.text('Staff Login'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Sign In'), findsOneWidget);
      
      // Verify no registration link for staff
      expect(find.text('New to NCL? '), findsNothing);
      expect(find.text('Create Account'), findsNothing);
    });

    testWidgets('should display admin login form', (WidgetTester tester) async {
      final mockDataService = MockDataService();
      
      // Build our app and trigger a frame
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(mockDataService),
          child: MaterialApp(
            home: LoginScreen(userRole: 'admin'),
          ),
        ),
      );

      // Wait for the widget to be fully rendered
      await tester.pumpAndSettle();

      // Verify the login form elements
      expect(find.text('Admin Login'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Sign In'), findsOneWidget);
      
      // Verify no registration link for admin
      expect(find.text('New to NCL? '), findsNothing);
      expect(find.text('Create Account'), findsNothing);
    });

    testWidgets('should successfully login with valid customer credentials', (WidgetTester tester) async {
      final mockDataService = MockDataService();
      
      // Build our app and trigger a frame
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(mockDataService),
          child: MaterialApp(
            home: LoginScreen(userRole: 'customer'),
          ),
        ),
      );

      // Find text fields by type
      final textFields = find.byType(TextFormField);
      expect(textFields, findsNWidgets(2));

      // Enter valid credentials
      await tester.enterText(textFields.first, 'customer@example.com');
      await tester.enterText(textFields.at(1), 'customer123');

      // Tap the Sign In button
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Verify successful login
      final authProvider = Provider.of<AuthProvider>(tester.element(find.byType(LoginScreen)), listen: false);
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.currentUser?.email, equals('customer@example.com'));
      expect(authProvider.currentUser?.role, equals(UserRole.customer));
    });

    testWidgets('should show error message with invalid credentials', (WidgetTester tester) async {
      final mockDataService = MockDataService();
      
      // Build our app and trigger a frame
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(mockDataService),
          child: MaterialApp(
            home: LoginScreen(userRole: 'customer'),
          ),
        ),
      );

      // Find text fields by type
      final textFields = find.byType(TextFormField);
      expect(textFields, findsNWidgets(2));

      // Enter invalid credentials
      await tester.enterText(textFields.first, 'customer@example.com');
      await tester.enterText(textFields.at(1), 'wrongpassword');

      // Tap the Sign In button
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Verify login failed
      final authProvider = Provider.of<AuthProvider>(tester.element(find.byType(LoginScreen)), listen: false);
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.errorMessage, equals('Invalid credentials'));
      
      // Verify error message is displayed
      expect(find.text('Invalid credentials'), findsOneWidget);
    });

    testWidgets('should show error message with non-existent user', (WidgetTester tester) async {
      final mockDataService = MockDataService();
      
      // Build our app and trigger a frame
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(mockDataService),
          child: MaterialApp(
            home: LoginScreen(userRole: 'customer'),
          ),
        ),
      );

      // Find text fields by type
      final textFields = find.byType(TextFormField);
      expect(textFields, findsNWidgets(2));

      // Enter non-existent user credentials
      await tester.enterText(textFields.first, 'nonexistent@example.com');
      await tester.enterText(textFields.at(1), 'password123');

      // Tap the Sign In button
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Verify login failed
      final authProvider = Provider.of<AuthProvider>(tester.element(find.byType(LoginScreen)), listen: false);
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.errorMessage, equals('User not found'));
      
      // Verify error message is displayed
      expect(find.text('User not found'), findsOneWidget);
    });
  });
}
