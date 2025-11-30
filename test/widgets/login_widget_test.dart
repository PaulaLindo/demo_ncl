// test/widgets/login_widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:demo_ncl/screens/auth/login_chooser_screen.dart';
import 'package:demo_ncl/screens/auth/login_screen.dart';
import 'package:demo_ncl/providers/auth_provider.dart';
import 'package:demo_ncl/services/mock_data_service.dart';
import 'package:demo_ncl/models/auth_model.dart';

void main() {
  group('Login Chooser Screen Widget Tests', () {
    late GoRouter router;
    late AuthProvider authProvider;

    setUp(() {
      authProvider = AuthProvider();
      
      router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const LoginChooserScreen(),
          ),
          GoRoute(
            path: '/login/:role',
            builder: (context, state) {
              final role = state.pathParameters['role'] ?? 'customer';
              return LoginScreen(userRole: role);
            },
          ),
        ],
      );
    });

    testWidgets('should display login chooser screen', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

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

    testWidgets('should navigate to customer login when Customer Login is tapped', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      // Tap the Customer Login button
      await tester.tap(find.text('Customer Login'));
      await tester.pumpAndSettle();

      // Verify we're on the customer login screen
      expect(find.text('Customer Login'), findsWidgets); // Title and button
      expect(find.byType(TextField), findsNWidgets(2)); // Email and password fields
    });

    testWidgets('should navigate to staff login when Staff Access is tapped', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      // Tap the Staff Access button
      await tester.tap(find.text('Staff Access'));
      await tester.pumpAndSettle();

      // Verify we're on the staff login screen
      expect(find.text('Staff Login'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2)); // Email and password fields
    });

    testWidgets('should navigate to admin login when Admin Portal is tapped', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      // Tap the Admin Portal button
      await tester.tap(find.text('Admin Portal'));
      await tester.pumpAndSettle();

      // Verify we're on the admin login screen
      expect(find.text('Admin Login'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2)); // Email and password fields
    });
  });

  group('Login Screen Widget Tests', () {
    late MockDataService mockDataService;
    late AuthProvider authProvider;

    setUp(() {
      mockDataService = MockDataService();
      authProvider = AuthProvider(mockDataService);
    });

    tearDown(() {
      authProvider.dispose();
    });

    testWidgets('should display customer login form', (WidgetTester tester) async {
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
      expect(find.byType(TextField), findsNWidgets(2));
      
      // Find email and password fields by their hint text or type
      final emailField = find.byType(TextField).first;
      final passwordField = find.byType(TextField).at(1);
      
      expect(emailField, findsOneWidget);
      expect(passwordField, findsOneWidget);
      
      // Verify the Sign In button
      expect(find.text('Sign In'), findsOneWidget);
      
      // Verify registration link (only for customers)
      expect(find.text('New to NCL?'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('should display staff login form', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => authProvider,
          child: MaterialApp(
            home: LoginScreen(userRole: 'staff'),
          ),
        ),
      );

      // Verify the login form elements
      expect(find.text('Staff Login'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Sign In'), findsOneWidget);
      
      // Verify no registration link for staff
      expect(find.text('New to NCL?'), findsNothing);
      expect(find.text('Create Account'), findsNothing);
    });

    testWidgets('should display admin login form', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => authProvider,
          child: MaterialApp(
            home: LoginScreen(userRole: 'admin'),
          ),
        ),
      );

      // Verify the login form elements
      expect(find.text('Admin Login'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Sign In'), findsOneWidget);
      
      // Verify no registration link for admin
      expect(find.text('New to NCL?'), findsNothing);
      expect(find.text('Create Account'), findsNothing);
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

      // Enter valid credentials
      await tester.enterText(find.byType(TextField).first, 'customer@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'customer123');

      // Tap the Sign In button
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Verify successful login
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.currentUser?.email, equals('customer@example.com'));
      expect(authProvider.currentUser?.role, equals(UserRole.customer));
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

      // Enter valid credentials
      await tester.enterText(find.byType(TextField).first, 'staff@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'staff123');

      // Tap the Sign In button
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Verify successful login
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.currentUser?.email, equals('staff@example.com'));
      expect(authProvider.currentUser?.role, equals(UserRole.staff));
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

      // Enter valid credentials
      await tester.enterText(find.byType(TextField).first, 'admin@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'admin123');

      // Tap the Sign In button
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Verify successful login
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.currentUser?.email, equals('admin@example.com'));
      expect(authProvider.currentUser?.role, equals(UserRole.admin));
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

      // Enter invalid credentials
      await tester.enterText(find.byType(TextField).first, 'customer@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'wrongpassword');

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

      // Enter non-existent user credentials
      await tester.enterText(find.byType(TextField).first, 'nonexistent@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'password123');

      // Tap the Sign In button
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Verify login failed
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.errorMessage, equals('User not found'));
      
      // Verify error message is displayed
      expect(find.text('User not found'), findsOneWidget);
    });

    testWidgets('should disable Sign In button while loading', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => authProvider,
          child: MaterialApp(
            home: LoginScreen(userRole: 'customer'),
          ),
        ),
      );

      // Enter valid credentials
      await tester.enterText(find.byType(TextField).first, 'customer@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'customer123');

      // Tap the Sign In button
      await tester.tap(find.text('Sign In'));
      
      // Check that the button shows loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Wait for login to complete
      await tester.pumpAndSettle();
      
      // Verify successful login
      expect(authProvider.isAuthenticated, isTrue);
    });
  });
}
