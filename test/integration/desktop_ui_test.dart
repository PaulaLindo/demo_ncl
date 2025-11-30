// test/integration/desktop_ui_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_ncl/main.dart';
import 'package:demo_ncl/services/mock_data_service.dart';
import 'package:demo_ncl/providers/auth_provider.dart';
import 'package:provider/provider.dart';

void main() {
  group('Desktop UI Tests', () {
    testWidgets('Login chooser screen renders correctly on desktop', (WidgetTester tester) async {
      // Build our app and trigger a frame with proper provider setup
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<MockDataService>.value(value: MockDataService()),
            ChangeNotifierProvider<AuthProvider>(
              create: (_) => AuthProvider(MockDataService()),
            ),
          ],
          child: const NCLApp(),
        ),
      );

      // Wait for the app to load
      await tester.pumpAndSettle();

      // Verify that the login chooser screen appears
      expect(find.text('Welcome to NCL'), findsOneWidget);
      expect(find.text('Customer Login'), findsOneWidget);
      expect(find.text('Staff Access'), findsOneWidget);
      expect(find.text('Admin Portal'), findsOneWidget);
    });

    testWidgets('Customer login navigation works', (WidgetTester tester) async {
      // Build our app
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<MockDataService>.value(value: MockDataService()),
            ChangeNotifierProvider<AuthProvider>(
              create: (_) => AuthProvider(MockDataService()),
            ),
          ],
          child: const NCLApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on Customer Login
      await tester.tap(find.text('Customer Login'));
      await tester.pumpAndSettle();

      // Verify we're on the login screen
      expect(find.text('Customer Login'), findsOneWidget);
      expect(find.byType(TextFormField), findsWidgets);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('Staff login navigation works', (WidgetTester tester) async {
      // Build our app
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<MockDataService>.value(value: MockDataService()),
            ChangeNotifierProvider<AuthProvider>(
              create: (_) => AuthProvider(MockDataService()),
            ),
          ],
          child: const NCLApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on Staff Access
      await tester.tap(find.text('Staff Access'));
      await tester.pumpAndSettle();

      // Verify we're on the staff login screen
      expect(find.text('Staff Login'), findsOneWidget);
      expect(find.byType(TextFormField), findsWidgets);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('Admin login navigation works', (WidgetTester tester) async {
      // Build our app
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<MockDataService>.value(value: MockDataService()),
            ChangeNotifierProvider<AuthProvider>(
              create: (_) => AuthProvider(MockDataService()),
            ),
          ],
          child: const NCLApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on Admin Portal
      await tester.tap(find.text('Admin Portal'));
      await tester.pumpAndSettle();

      // Verify we're on the admin login screen
      expect(find.text('Admin Login'), findsOneWidget);
      expect(find.byType(TextFormField), findsWidgets);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('Form fields are interactive', (WidgetTester tester) async {
      // Build our app
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<MockDataService>.value(value: MockDataService()),
            ChangeNotifierProvider<AuthProvider>(
              create: (_) => AuthProvider(MockDataService()),
            ),
          ],
          child: const NCLApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to customer login
      await tester.tap(find.text('Customer Login'));
      await tester.pumpAndSettle();

      // Find and fill email field
      await tester.tap(find.byType(TextFormField).first);
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      
      // Find and fill password field
      await tester.tap(find.byType(TextFormField).at(1));
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');

      // Verify text was entered
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('password123'), findsOneWidget);
    });
  });
}
