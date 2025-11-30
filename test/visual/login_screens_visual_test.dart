// test/visual/login_screens_visual_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:demo_ncl/screens/auth/login_screen.dart';
import 'package:demo_ncl/theme/app_theme.dart';

void main() {
  group('Login Screens Visual Regression Tests', () {
    late GoRouter router;

    setUp(() {
      router = GoRouter(
        initialLocation: '/login/customer',
        routes: [
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

    group('Customer Login Screen', () {
      testWidgets('Customer Login - Light Theme Visual Test', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
            theme: AppTheme.lightTheme,
          ),
        );
        await tester.pumpAndSettle();

        // Capture golden image for customer login
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/customer_login_light_theme.png'),
        );
      });

      testWidgets('Customer Login - Dark Theme Visual Test', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
            theme: AppTheme.darkTheme,
          ),
        );
        await tester.pumpAndSettle();

        // Capture golden image for dark theme
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/customer_login_dark_theme.png'),
        );
      });

      testWidgets('Customer Login - Credentials Section Visual Test', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
            theme: AppTheme.lightTheme,
          ),
        );
        await tester.pumpAndSettle();

        // Find and capture credentials section
        final credentialsSection = find.byType(Container).first;
        await expectLater(
          credentialsSection,
          matchesGoldenFile('goldens/customer_login_credentials.png'),
        );
      });

      testWidgets('Customer Login - Form Fields Visual Test', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
            theme: AppTheme.lightTheme,
          ),
        );
        await tester.pumpAndSettle();

        // Capture form fields
        final formFields = find.byType(TextFormField);
        await expectLater(
          formFields.first,
          matchesGoldenFile('goldens/customer_login_email_field.png'),
        );

        await expectLater(
          formFields.at(1),
          matchesGoldenFile('goldens/customer_login_password_field.png'),
        );
      });
    });

    group('Staff Login Screen', () {
      testWidgets('Staff Login - Light Theme Visual Test', (WidgetTester tester) async {
        // Navigate to staff login
        router.go('/login/staff');
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
            theme: AppTheme.lightTheme,
          ),
        );
        await tester.pumpAndSettle();

        // Capture golden image for staff login
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/staff_login_light_theme.png'),
        );
      });

      testWidgets('Staff Login - Credentials Section Visual Test', (WidgetTester tester) async {
        router.go('/login/staff');
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
            theme: AppTheme.lightTheme,
          ),
        );
        await tester.pumpAndSettle();

        // Capture staff credentials section
        final credentialsSection = find.byType(Container).first;
        await expectLater(
          credentialsSection,
          matchesGoldenFile('goldens/staff_login_credentials.png'),
        );
      });
    });

    group('Admin Login Screen', () {
      testWidgets('Admin Login - Light Theme Visual Test', (WidgetTester tester) async {
        // Navigate to admin login
        router.go('/login/admin');
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
            theme: AppTheme.lightTheme,
          ),
        );
        await tester.pumpAndSettle();

        // Capture golden image for admin login
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/admin_login_light_theme.png'),
        );
      });

      testWidgets('Admin Login - Credentials Section Visual Test', (WidgetTester tester) async {
        router.go('/login/admin');
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
            theme: AppTheme.lightTheme,
          ),
        );
        await tester.pumpAndSettle();

        // Capture admin credentials section
        final credentialsSection = find.byType(Container).first;
        await expectLater(
          credentialsSection,
          matchesGoldenFile('goldens/admin_login_credentials.png'),
        );
      });
    });

    group('Login Screen Interactions', () {
      testWidgets('Login Screen - Form Focus States Visual Test', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
            theme: AppTheme.lightTheme,
          ),
        );
        await tester.pumpAndSettle();

        // Focus on email field
        await tester.tap(find.byType(TextFormField).first);
        await tester.pumpAndSettle();

        // Capture focus state
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/login_email_focus.png'),
        );

        // Focus on password field
        await tester.tap(find.byType(TextFormField).at(1));
        await tester.pumpAndSettle();

        // Capture password focus state
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/login_password_focus.png'),
        );
      });

      testWidgets('Login Screen - Error States Visual Test', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
            theme: AppTheme.lightTheme,
          ),
        );
        await tester.pumpAndSettle();

        // Submit empty form to trigger validation errors
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        // Capture error states
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/login_validation_errors.png'),
        );
      });

      testWidgets('Login Screen - Loading State Visual Test', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
            theme: AppTheme.lightTheme,
          ),
        );
        await tester.pumpAndSettle();

        // Fill form and submit to trigger loading
        await tester.enterText(find.byType(TextFormField).first, 'customer@example.com');
        await tester.enterText(find.byType(TextFormField).at(1), 'customer123');
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Capture loading state
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/login_loading_state.png'),
        );
      });

      testWidgets('Login Screen - Password Toggle Visual Test', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
            theme: AppTheme.lightTheme,
          ),
        );
        await tester.pumpAndSettle();

        // Fill password field
        await tester.enterText(find.byType(TextFormField).at(1), 'customer123');
        await tester.pumpAndSettle();

        // Capture password hidden state
        await expectLater(
          find.byType(TextFormField).at(1),
          matchesGoldenFile('goldens/login_password_hidden.png'),
        );

        // Toggle password visibility
        final passwordField = find.byType(TextFormField).at(1);
        await tester.tap(passwordField);
        await tester.pumpAndSettle();

        // Find and tap the toggle icon (if it exists)
        final toggleIcon = find.byIcon(Icons.visibility);
        if (toggleIcon.evaluate().isNotEmpty) {
          await tester.tap(toggleIcon);
          await tester.pumpAndSettle();

          // Capture password visible state
          await expectLater(
            passwordField,
            matchesGoldenFile('goldens/login_password_visible.png'),
          );
        }
      });
    });

    group('Responsive Design Tests', () {
      testWidgets('Login Screen - Mobile Responsive Visual Test', (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(375, 667)); // iPhone SE
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
            theme: AppTheme.lightTheme,
          ),
        );
        await tester.pumpAndSettle();

        // Capture mobile layout
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/login_mobile_layout.png'),
        );

        await tester.binding.setSurfaceSize(null);
      });

      testWidgets('Login Screen - Tablet Responsive Visual Test', (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(768, 1024)); // iPad
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
            theme: AppTheme.lightTheme,
          ),
        );
        await tester.pumpAndSettle();

        // Capture tablet layout
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/login_tablet_layout.png'),
        );

        await tester.binding.setSurfaceSize(null);
      });

      testWidgets('Login Screen - Desktop Responsive Visual Test', (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(1200, 800)); // Desktop
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
            theme: AppTheme.lightTheme,
          ),
        );
        await tester.pumpAndSettle();

        // Capture desktop layout
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/login_desktop_layout.png'),
        );

        await tester.binding.setSurfaceSize(null);
      });
    });
  });
}
