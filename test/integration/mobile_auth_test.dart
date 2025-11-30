// test/integration/mobile_auth_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:demo_ncl/providers/auth_provider.dart';
import 'package:demo_ncl/services/mock_data_service.dart';
import 'package:demo_ncl/screens/auth/login_chooser_screen.dart';
import 'package:demo_ncl/screens/auth/login_screen.dart';

void main() {
  group('Mobile Authentication Tests', () {
    late AuthProvider authProvider;

    setUp(() {
      authProvider = AuthProvider();
    });

    testWidgets('should display login chooser on mobile screen size', (WidgetTester tester) async {
      // Set mobile screen size
      tester.binding.window.physicalSizeTestValue = const Size(375, 812); // iPhone X size
      tester.binding.window.devicePixelRatioTestValue = 2.0;
      
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: MaterialApp(
            home: const LoginChooserScreen(),
            routes: {
              '/login/customer': (context) => const LoginScreen(userRole: 'customer'),
              '/login/staff': (context) => const LoginScreen(userRole: 'staff'),
              '/login/admin': (context) => const LoginScreen(userRole: 'admin'),
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check mobile layout elements
      expect(find.text('Welcome to NCL'), findsOneWidget);
      expect(find.text('Professional home services\nat your fingertips'), findsOneWidget);
      expect(find.text('Customer Login'), findsOneWidget);
      expect(find.text('Staff Access'), findsOneWidget);
      expect(find.text('Admin Portal'), findsOneWidget);
      
      // Check that role buttons are properly sized for mobile
      final roleButtons = find.byType(Material);
      expect(roleButtons, findsWidgets);
    });

    testWidgets('should navigate to customer login on mobile', (WidgetTester tester) async {
      // Set mobile screen size
      tester.binding.window.physicalSizeTestValue = const Size(375, 812);
      tester.binding.window.devicePixelRatioTestValue = 2.0;
      
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: MaterialApp(
            home: const LoginChooserScreen(),
            routes: {
              '/login/customer': (context) => const LoginScreen(userRole: 'customer'),
              '/login/staff': (context) => const LoginScreen(userRole: 'staff'),
              '/login/admin': (context) => const LoginScreen(userRole: 'admin'),
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on Customer Login
      await tester.tap(find.text('Customer Login'));
      await tester.pumpAndSettle();

      // Should be on customer login screen
      expect(find.text('Customer Login'), findsWidgets); // AppBar title
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign in to manage your bookings'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      
      // Check demo credentials are visible
      expect(find.text('Demo Credentials'), findsOneWidget);
      expect(find.text('Email: customer@example.com'), findsOneWidget);
    });

    testWidgets('should complete mobile customer login flow', (WidgetTester tester) async {
      // Set mobile screen size
      tester.binding.window.physicalSizeTestValue = const Size(375, 812);
      tester.binding.window.devicePixelRatioTestValue = 2.0;
      
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: MaterialApp(
            home: const LoginChooserScreen(),
            routes: {
              '/login/customer': (context) => const LoginScreen(userRole: 'customer'),
              '/login/staff': (context) => const LoginScreen(userRole: 'staff'),
              '/login/admin': (context) => const LoginScreen(userRole: 'admin'),
            },
          ),
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
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Should successfully login (no error message)
      expect(find.text('Invalid credentials'), findsNothing);
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.currentUser?.email, equals('customer@example.com'));
    });

    testWidgets('should complete mobile staff login flow', (WidgetTester tester) async {
      // Set mobile screen size
      tester.binding.window.physicalSizeTestValue = const Size(375, 812);
      tester.binding.window.devicePixelRatioTestValue = 2.0;
      
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: MaterialApp(
            home: const LoginChooserScreen(),
            routes: {
              '/login/customer': (context) => const LoginScreen(userRole: 'customer'),
              '/login/staff': (context) => const LoginScreen(userRole: 'staff'),
              '/login/admin': (context) => const LoginScreen(userRole: 'admin'),
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to staff login
      await tester.tap(find.text('Staff Access'));
      await tester.pumpAndSettle();

      // Should see staff-specific content
      expect(find.text('Staff Portal'), findsOneWidget);
      expect(find.text('Access your schedule and jobs'), findsOneWidget);
      expect(find.text('Email: staff@example.com'), findsOneWidget);

      // Fill in login form
      await tester.enterText(find.byType(TextFormField).first, 'staff@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'staff123');

      // Tap login button
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Should successfully login
      expect(find.text('Invalid credentials'), findsNothing);
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.currentUser?.email, equals('staff@example.com'));
    });

    testWidgets('should complete mobile admin login flow', (WidgetTester tester) async {
      // Set mobile screen size
      tester.binding.window.physicalSizeTestValue = const Size(375, 812);
      tester.binding.window.devicePixelRatioTestValue = 2.0;
      
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: MaterialApp(
            home: const LoginChooserScreen(),
            routes: {
              '/login/customer': (context) => const LoginScreen(userRole: 'customer'),
              '/login/staff': (context) => const LoginScreen(userRole: 'staff'),
              '/login/admin': (context) => const LoginScreen(userRole: 'admin'),
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to admin login
      await tester.tap(find.text('Admin Portal'));
      await tester.pumpAndSettle();

      // Should see admin-specific content
      expect(find.text('Admin System'), findsOneWidget);
      expect(find.text('Manage platform and users'), findsOneWidget);
      expect(find.text('Email: admin@example.com'), findsOneWidget);

      // Fill in login form
      await tester.enterText(find.byType(TextFormField).first, 'admin@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'admin123');

      // Tap login button
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Should successfully login
      expect(find.text('Invalid credentials'), findsNothing);
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.currentUser?.email, equals('admin@example.com'));
    });

    testWidgets('should handle invalid login on mobile', (WidgetTester tester) async {
      // Set mobile screen size
      tester.binding.window.physicalSizeTestValue = const Size(375, 812);
      tester.binding.window.devicePixelRatioTestValue = 2.0;
      
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: MaterialApp(
            home: const LoginChooserScreen(),
            routes: {
              '/login/customer': (context) => const LoginScreen(userRole: 'customer'),
              '/login/staff': (context) => const LoginScreen(userRole: 'staff'),
              '/login/admin': (context) => const LoginScreen(userRole: 'admin'),
            },
          ),
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
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Should show error message
      expect(find.text('Invalid credentials'), findsOneWidget);
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.errorMessage, isNotNull);
    });

    testWidgets('should handle form validation on mobile', (WidgetTester tester) async {
      // Set mobile screen size
      tester.binding.window.physicalSizeTestValue = const Size(375, 812);
      tester.binding.window.devicePixelRatioTestValue = 2.0;
      
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: MaterialApp(
            home: const LoginChooserScreen(),
            routes: {
              '/login/customer': (context) => const LoginScreen(userRole: 'customer'),
              '/login/staff': (context) => const LoginScreen(userRole: 'staff'),
              '/login/admin': (context) => const LoginScreen(userRole: 'admin'),
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to customer login
      await tester.tap(find.text('Customer Login'));
      await tester.pumpAndSettle();

      // Try to login with empty form
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Should show validation errors
      expect(find.text('Required'), findsWidgets); // Both email and password fields

      // Test invalid email
      await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Invalid email'), findsOneWidget);

      // Test short password
      await tester.enterText(find.byType(TextFormField).first, 'customer@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), '123');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });
  });
}
