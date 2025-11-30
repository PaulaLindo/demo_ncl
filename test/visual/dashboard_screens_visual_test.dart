// test/visual/dashboard_screens_visual_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:demo_ncl/providers/auth_provider.dart';
import 'package:demo_ncl/services/mock_data_service.dart';
import 'package:demo_ncl/screens/customer/customer_dashboard_screen.dart';
import 'package:demo_ncl/screens/staff/staff_dashboard_screen.dart';
import 'package:demo_ncl/screens/admin/admin_dashboard_screen.dart';
import 'package:demo_ncl/theme/app_theme.dart';

void main() {
  group('Dashboard Screens Visual Regression Tests', () {
    late AuthProvider authProvider;
    late MockDataService mockDataService;

    setUp(() {
      mockDataService = MockDataService();
      authProvider = AuthProvider(mockDataService);
    });

    group('Customer Dashboard', () {
      testWidgets('Customer Dashboard - Light Theme Visual Test', (WidgetTester tester) async {
        // Set up authenticated customer
        await authProvider.login('customer@example.com', 'customer123');
        
        await tester.pumpWidget(
          ChangeNotifierProvider<AuthProvider>(
            create: (_) => authProvider,
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const CustomerDashboardScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Capture golden image for customer dashboard
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/customer_dashboard_light_theme.png'),
        );
      });

      testWidgets('Customer Dashboard - Dark Theme Visual Test', (WidgetTester tester) async {
        // Set up authenticated customer
        await authProvider.login('customer@example.com', 'customer123');
        
        await tester.pumpWidget(
          ChangeNotifierProvider<AuthProvider>(
            create: (_) => authProvider,
            child: MaterialApp(
              theme: AppTheme.darkTheme,
              home: const CustomerDashboardScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Capture golden image for dark theme
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/customer_dashboard_dark_theme.png'),
        );
      });

      testWidgets('Customer Dashboard - Navigation Bar Visual Test', (WidgetTester tester) async {
        await authProvider.login('customer@example.com', 'customer123');
        
        await tester.pumpWidget(
          ChangeNotifierProvider<AuthProvider>(
            create: (_) => authProvider,
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const CustomerDashboardScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find navigation bar
        final navBar = find.byType(BottomNavigationBar);
        if (navBar.evaluate().isNotEmpty) {
          await expectLater(
            navBar,
            matchesGoldenFile('goldens/customer_dashboard_navbar.png'),
          );
        }
      });

      testWidgets('Customer Dashboard - Quick Actions Visual Test', (WidgetTester tester) async {
        await authProvider.login('customer@example.com', 'customer123');
        
        await tester.pumpWidget(
          ChangeNotifierProvider<AuthProvider>(
            create: (_) => authProvider,
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const CustomerDashboardScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find quick action buttons
        final quickActions = find.byType(ElevatedButton);
        if (quickActions.evaluate().isNotEmpty) {
          await expectLater(
            quickActions.first,
            matchesGoldenFile('goldens/customer_dashboard_quick_action.png'),
          );
        }
      });
    });

    group('Staff Dashboard', () {
      testWidgets('Staff Dashboard - Light Theme Visual Test', (WidgetTester tester) async {
        // Set up authenticated staff
        await authProvider.login('staff@example.com', 'staff123');
        
        await tester.pumpWidget(
          ChangeNotifierProvider<AuthProvider>(
            create: (_) => authProvider,
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const StaffDashboardScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Capture golden image for staff dashboard
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/staff_dashboard_light_theme.png'),
        );
      });

      testWidgets('Staff Dashboard - Dark Theme Visual Test', (WidgetTester tester) async {
        // Set up authenticated staff
        await authProvider.login('staff@example.com', 'staff123');
        
        await tester.pumpWidget(
          ChangeNotifierProvider<AuthProvider>(
            create: (_) => authProvider,
            child: MaterialApp(
              theme: AppTheme.darkTheme,
              home: const StaffDashboardScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Capture golden image for dark theme
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/staff_dashboard_dark_theme.png'),
        );
      });

      testWidgets('Staff Dashboard - Timekeeping Section Visual Test', (WidgetTester tester) async {
        await authProvider.login('staff@example.com', 'staff123');
        
        await tester.pumpWidget(
          ChangeNotifierProvider<AuthProvider>(
            create: (_) => authProvider,
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const StaffDashboardScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find timekeeping section
        final timekeepingSection = find.text('Timekeeping');
        if (timekeepingSection.evaluate().isNotEmpty) {
          await expectLater(
            find.ancestor(of: timekeepingSection, matching: find.byType(Container)),
            matchesGoldenFile('goldens/staff_dashboard_timekeeping.png'),
          );
        }
      });

      testWidgets('Staff Dashboard - Schedule View Visual Test', (WidgetTester tester) async {
        await authProvider.login('staff@example.com', 'staff123');
        
        await tester.pumpWidget(
          ChangeNotifierProvider<AuthProvider>(
            create: (_) => authProvider,
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const StaffDashboardScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find schedule section
        final scheduleSection = find.text('My Schedule');
        if (scheduleSection.evaluate().isNotEmpty) {
          await expectLater(
            find.ancestor(of: scheduleSection, matching: find.byType(Container)),
            matchesGoldenFile('goldens/staff_dashboard_schedule.png'),
          );
        }
      });
    });

    group('Admin Dashboard', () {
      testWidgets('Admin Dashboard - Light Theme Visual Test', (WidgetTester tester) async {
        // Set up authenticated admin
        await authProvider.login('admin@example.com', 'admin123');
        
        await tester.pumpWidget(
          ChangeNotifierProvider<AuthProvider>(
            create: (_) => authProvider,
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const AdminDashboardScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Capture golden image for admin dashboard
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/admin_dashboard_light_theme.png'),
        );
      });

      testWidgets('Admin Dashboard - Dark Theme Visual Test', (WidgetTester tester) async {
        // Set up authenticated admin
        await authProvider.login('admin@example.com', 'admin123');
        
        await tester.pumpWidget(
          ChangeNotifierProvider<AuthProvider>(
            create: (_) => authProvider,
            child: MaterialApp(
              theme: AppTheme.darkTheme,
              home: const AdminDashboardScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Capture golden image for dark theme
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/admin_dashboard_dark_theme.png'),
        );
      });

      testWidgets('Admin Dashboard - Management Cards Visual Test', (WidgetTester tester) async {
        await authProvider.login('admin@example.com', 'admin123');
        
        await tester.pumpWidget(
          ChangeNotifierProvider<AuthProvider>(
            create: (_) => authProvider,
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const AdminDashboardScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find management cards
        final managementCards = find.byType(Card);
        if (managementCards.evaluate().isNotEmpty) {
          await expectLater(
            managementCards.first,
            matchesGoldenFile('goldens/admin_dashboard_management_card.png'),
          );
        }
      });

      testWidgets('Admin Dashboard - Stats Overview Visual Test', (WidgetTester tester) async {
        await authProvider.login('admin@example.com', 'admin123');
        
        await tester.pumpWidget(
          ChangeNotifierProvider<AuthProvider>(
            create: (_) => authProvider,
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const AdminDashboardScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find stats section
        final statsSection = find.text('Overview');
        if (statsSection.evaluate().isNotEmpty) {
          await expectLater(
            find.ancestor(of: statsSection, matching: find.byType(Container)),
            matchesGoldenFile('goldens/admin_dashboard_stats.png'),
          );
        }
      });
    });

    group('Dashboard Responsive Tests', () {
      testWidgets('Dashboard - Mobile Responsive Visual Test', (WidgetTester tester) async {
        await authProvider.login('customer@example.com', 'customer123');
        await tester.binding.setSurfaceSize(const Size(375, 667)); // iPhone SE
        
        await tester.pumpWidget(
          ChangeNotifierProvider<AuthProvider>(
            create: (_) => authProvider,
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const CustomerDashboardScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Capture mobile layout
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/dashboard_mobile_layout.png'),
        );

        await tester.binding.setSurfaceSize(null);
      });

      testWidgets('Dashboard - Tablet Responsive Visual Test', (WidgetTester tester) async {
        await authProvider.login('customer@example.com', 'customer123');
        await tester.binding.setSurfaceSize(const Size(768, 1024)); // iPad
        
        await tester.pumpWidget(
          ChangeNotifierProvider<AuthProvider>(
            create: (_) => authProvider,
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const CustomerDashboardScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Capture tablet layout
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/dashboard_tablet_layout.png'),
        );

        await tester.binding.setSurfaceSize(null);
      });

      testWidgets('Dashboard - Desktop Responsive Visual Test', (WidgetTester tester) async {
        await authProvider.login('customer@example.com', 'customer123');
        await tester.binding.setSurfaceSize(const Size(1200, 800)); // Desktop
        
        await tester.pumpWidget(
          ChangeNotifierProvider<AuthProvider>(
            create: (_) => authProvider,
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const CustomerDashboardScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Capture desktop layout
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/dashboard_desktop_layout.png'),
        );

        await tester.binding.setSurfaceSize(null);
      });
    });

    group('Dashboard State Tests', () {
      testWidgets('Dashboard - Loading State Visual Test', (WidgetTester tester) async {
        // Don't authenticate to trigger loading state
        await tester.pumpWidget(
          ChangeNotifierProvider<AuthProvider>(
            create: (_) => authProvider,
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const CustomerDashboardScreen(),
            ),
          ),
        );
        
        // Capture loading state
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/dashboard_loading_state.png'),
        );

        await tester.pumpAndSettle();
      });

      testWidgets('Dashboard - Error State Visual Test', (WidgetTester tester) async {
        // Simulate error state
        authProvider.setError('Authentication failed');
        
        await tester.pumpWidget(
          ChangeNotifierProvider<AuthProvider>(
            create: (_) => authProvider,
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const CustomerDashboardScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Capture error state
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/dashboard_error_state.png'),
        );
      });
    });
  });
}
