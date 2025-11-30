// test/visual/login_chooser_visual_test.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:demo_ncl/screens/auth/login_chooser_screen.dart';
import 'package:demo_ncl/theme/app_theme.dart';

void main() {
  group('Login Chooser Visual Regression Tests', () {
    late GoRouter router;

    setUp(() {
      router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const LoginChooserScreen(),
          ),
        ],
      );
    });

    testWidgets('Login Chooser - Light Theme Visual Test', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          theme: AppTheme.lightTheme,
        ),
      );
      await tester.pumpAndSettle();

      // Capture golden image for light theme
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/login_chooser_light_theme.png'),
      );
    });

    testWidgets('Login Chooser - Dark Theme Visual Test', (WidgetTester tester) async {
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
        matchesGoldenFile('goldens/login_chooser_dark_theme.png'),
      );
    });

    testWidgets('Login Chooser - Mobile Size Visual Test', (WidgetTester tester) async {
      // Set mobile screen size
      await tester.binding.setSurfaceSize(const Size(375, 667)); // iPhone SE
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          theme: AppTheme.lightTheme,
        ),
      );
      await tester.pumpAndSettle();

      // Capture golden image for mobile size
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/login_chooser_mobile.png'),
      );

      // Reset to default size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('Login Chooser - Tablet Size Visual Test', (WidgetTester tester) async {
      // Set tablet screen size
      await tester.binding.setSurfaceSize(const Size(768, 1024)); // iPad
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          theme: AppTheme.lightTheme,
        ),
      );
      await tester.pumpAndSettle();

      // Capture golden image for tablet size
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/login_chooser_tablet.png'),
      );

      // Reset to default size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('Login Chooser - Desktop Size Visual Test', (WidgetTester tester) async {
      // Set desktop screen size
      await tester.binding.setSurfaceSize(const Size(1200, 800)); // Desktop
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          theme: AppTheme.lightTheme,
        ),
      );
      await tester.pumpAndSettle();

      // Capture golden image for desktop size
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/login_chooser_desktop.png'),
      );

      // Reset to default size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('Login Chooser - Button Hover States Visual Test', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          theme: AppTheme.lightTheme,
        ),
      );
      await tester.pumpAndSettle();

      // Hover over Customer Login button
      final customerButton = find.text('Customer Login');
      await tester.pump();
      
      // Simulate hover (this might require gesture testing)
      final TestGesture gesture = await tester.startGesture(tester.getCenter(customerButton));
      await tester.pumpAndSettle();

      // Capture golden image with hover state
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/login_chooser_hover_state.png'),
      );

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('Login Chooser - Help Dialog Visual Test', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          theme: AppTheme.lightTheme,
        ),
      );
      await tester.pumpAndSettle();

      // Tap help button to show dialog
      await tester.tap(find.text('Need help signing in?'));
      await tester.pumpAndSettle();

      // Capture golden image with dialog open
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/login_chooser_help_dialog.png'),
      );
    });

    testWidgets('Login Chooser - Accessibility Focus States Visual Test', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          theme: AppTheme.lightTheme,
        ),
      );
      await tester.pumpAndSettle();

      // Focus on Customer Login button
      await tester.tap(find.text('Customer Login'));
      await tester.pumpAndSettle();

      // Capture golden image with focus state
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/login_chooser_focus_state.png'),
      );
    });

    testWidgets('Login Chooser - Loading State Visual Test', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          theme: AppTheme.lightTheme,
        ),
      );
      
      // Capture initial loading state
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/login_chooser_loading.png'),
      );

      await tester.pumpAndSettle();
    });

    testWidgets('Login Chooser - Component Breakdown Visual Test', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          theme: AppTheme.lightTheme,
        ),
      );
      await tester.pumpAndSettle();

      // Test individual components
      await expectLater(
        find.byType(SingleChildScrollView),
        matchesGoldenFile('goldens/login_chooser_scroll_view.png'),
      );

      await expectLater(
        find.text('Welcome to NCL'),
        matchesGoldenFile('goldens/login_chooser_header.png'),
      );

      await expectLater(
        find.byType(ElevatedButton).first,
        matchesGoldenFile('goldens/login_chooser_customer_button.png'),
      );
    });
  });
}
