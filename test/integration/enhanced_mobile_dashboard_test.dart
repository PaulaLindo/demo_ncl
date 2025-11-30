// test/integration/enhanced_mobile_dashboard_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:demo_ncl/providers/auth_provider.dart';
import 'package:demo_ncl/providers/booking_provider.dart';
import 'package:demo_ncl/providers/staff_provider.dart';
import 'package:demo_ncl/screens/customer/enhanced_mobile_customer_dashboard.dart';
import 'package:demo_ncl/screens/staff/enhanced_mobile_staff_dashboard.dart';
import 'package:demo_ncl/screens/admin/enhanced_mobile_admin_dashboard.dart';

void main() {
  group('Enhanced Mobile Dashboard Tests', () {
    late AuthProvider authProvider;
    late BookingProvider bookingProvider;
    late StaffProvider staffProvider;

    setUp(() {
      authProvider = AuthProvider();
      bookingProvider = BookingProvider();
      staffProvider = StaffProvider(authProvider: authProvider);
    });

    group('Customer Dashboard', () {
      testWidgets('should display enhanced customer dashboard with all sections', (WidgetTester tester) async {
        // Login as customer
        await authProvider.login(email: 'customer@example.com', password: 'customer123');
        
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
              ChangeNotifierProvider<BookingProvider>.value(value: bookingProvider),
            ],
            child: MaterialApp(
              home: const EnhancedMobileCustomerDashboard(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Check main sections
        expect(find.text('Hi, Customer!'), findsOneWidget);
        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Bookings'), findsOneWidget);
        expect(find.text('Services'), findsOneWidget);
        expect(find.text('Account'), findsOneWidget);
        
        // Check quick actions
        expect(find.text('Quick Actions'), findsOneWidget);
        expect(find.text('Schedule'), findsOneWidget);
        expect(find.text('Services'), findsOneWidget);
        expect(find.text('Support'), findsOneWidget);
        expect(find.text('Payment'), findsOneWidget);
        
        // Check stats section
        expect(find.text('Your Stats'), findsOneWidget);
        
        // Check floating action button
        expect(find.text('Book Now'), findsOneWidget);
      });

      testWidgets('should navigate between tabs in customer dashboard', (WidgetTester tester) async {
        await authProvider.login(email: 'customer@example.com', password: 'customer123');
        
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
              ChangeNotifierProvider<BookingProvider>.value(value: bookingProvider),
            ],
            child: MaterialApp(
              home: const EnhancedMobileCustomerDashboard(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Tap on Bookings tab
        await tester.tap(find.text('Bookings'));
        await tester.pumpAndSettle();
        
        // Should show bookings content
        expect(find.text('Bookings Management - Coming Soon'), findsOneWidget);

        // Tap on Services tab
        await tester.tap(find.text('Services'));
        await tester.pumpAndSettle();
        
        // Should show services content
        expect(find.text('Services Tab - Coming Soon'), findsOneWidget);

        // Tap on Account tab
        await tester.tap(find.text('Account'));
        await tester.pumpAndSettle();
        
        // Should show account content
        expect(find.text('Account Tab - Coming Soon'), findsOneWidget);
      });

      testWidgets('should show quick booking dialog when FAB is tapped', (WidgetTester tester) async {
        await authProvider.login(email: 'customer@example.com', password: 'customer123');
        
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
              ChangeNotifierProvider<BookingProvider>.value(value: bookingProvider),
            ],
            child: MaterialApp(
              home: const EnhancedMobileCustomerDashboard(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Tap the floating action button
        await tester.tap(find.text('Book Now'));
        await tester.pumpAndSettle();

        // Should show dialog
        expect(find.text('Quick Booking'), findsOneWidget);
        expect(find.text('Select a service to book quickly'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('Browse Services'), findsOneWidget);
      });
    });

    group('Staff Dashboard', () {
      testWidgets('should display enhanced staff dashboard with all sections', (WidgetTester tester) async {
        // Login as staff
        await authProvider.login(email: 'staff@example.com', password: 'staff123');
        
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
              ChangeNotifierProvider<StaffProvider>.value(value: staffProvider),
            ],
            child: MaterialApp(
              home: const EnhancedMobileStaffDashboard(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Check main sections
        expect(find.text('Hi, Staff!'), findsOneWidget);
        expect(find.text('Dashboard'), findsOneWidget);
        expect(find.text('Schedule'), findsOneWidget);
        expect(find.text('Timekeeping'), findsOneWidget);
        expect(find.text('Profile'), findsOneWidget);
        
        // Check today's overview
        expect(find.text('Today\'s Overview'), findsOneWidget);
        expect(find.text('Jobs Today'), findsOneWidget);
        
        // Check quick stats
        expect(find.text('Quick Stats'), findsOneWidget);
        
        // Check floating action button
        expect(find.text('Quick Actions'), findsOneWidget);
      });

      testWidgets('should navigate between tabs in staff dashboard', (WidgetTester tester) async {
        await authProvider.login(email: 'staff@example.com', password: 'staff123');
        
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
              ChangeNotifierProvider<StaffProvider>.value(value: staffProvider),
            ],
            child: MaterialApp(
              home: const EnhancedMobileStaffDashboard(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Tap on Schedule tab
        await tester.tap(find.text('Schedule'));
        await tester.pumpAndSettle();
        
        // Should show schedule content
        expect(find.text('Schedule Tab - Coming Soon'), findsOneWidget);

        // Tap on Timekeeping tab
        await tester.tap(find.text('Timekeeping'));
        await tester.pumpAndSettle();
        
        // Should show timekeeping content
        expect(find.text('Timekeeping Tab - Coming Soon'), findsOneWidget);

        // Tap on Profile tab
        await tester.tap(find.text('Profile'));
        await tester.pumpAndSettle();
        
        // Should show profile content
        expect(find.text('Profile Tab - Coming Soon'), findsOneWidget);
      });

      testWidgets('should show quick actions modal when FAB is tapped', (WidgetTester tester) async {
        await authProvider.login(email: 'staff@example.com', password: 'staff123');
        
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
              ChangeNotifierProvider<StaffProvider>.value(value: staffProvider),
            ],
            child: MaterialApp(
              home: const EnhancedMobileStaffDashboard(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Tap the floating action button
        await tester.tap(find.text('Quick Actions'));
        await tester.pumpAndSettle();

        // Should show modal bottom sheet
        expect(find.text('Quick Actions'), findsOneWidget);
        expect(find.text('View Schedule'), findsOneWidget);
        expect(find.text('Clock In/Out'), findsOneWidget);
        expect(find.text('Contact Support'), findsOneWidget);
        expect(find.text('Job History'), findsOneWidget);
      });
    });

    group('Admin Dashboard', () {
      testWidgets('should display enhanced admin dashboard with all sections', (WidgetTester tester) async {
        // Login as admin
        await authProvider.login(email: 'admin@example.com', password: 'admin123');
        
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
              ChangeNotifierProvider<BookingProvider>.value(value: bookingProvider),
            ],
            child: MaterialApp(
              home: const EnhancedMobileAdminDashboard(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Check main sections
        expect(find.text('Admin Panel'), findsOneWidget);
        expect(find.text('Overview'), findsOneWidget);
        expect(find.text('Bookings'), findsOneWidget);
        expect(find.text('Users'), findsOneWidget);
        expect(find.text('Staff'), findsOneWidget);
        expect(find.text('Reports'), findsOneWidget);
        
        // Check system health
        expect(find.text('System Health'), findsOneWidget);
        expect(find.text('System Status'), findsOneWidget);
        expect(find.text('Database'), findsOneWidget);
        expect(find.text('API Response'), findsOneWidget);
        expect(find.text('Error Rate'), findsOneWidget);
        
        // Check key metrics
        expect(find.text('Key Metrics'), findsOneWidget);
        
        // Check floating action button
        expect(find.text('Admin Actions'), findsOneWidget);
      });

      testWidgets('should navigate between tabs in admin dashboard', (WidgetTester tester) async {
        await authProvider.login(email: 'admin@example.com', password: 'admin123');
        
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
              ChangeNotifierProvider<BookingProvider>.value(value: bookingProvider),
            ],
            child: MaterialApp(
              home: const EnhancedMobileAdminDashboard(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Tap on Bookings tab
        await tester.tap(find.text('Bookings'));
        await tester.pumpAndSettle();
        
        // Should show bookings content
        expect(find.text('Bookings Management - Coming Soon'), findsOneWidget);

        // Tap on Users tab
        await tester.tap(find.text('Users'));
        await tester.pumpAndSettle();
        
        // Should show users content
        expect(find.text('User Management - Coming Soon'), findsOneWidget);

        // Tap on Staff tab
        await tester.tap(find.text('Staff'));
        await tester.pumpAndSettle();
        
        // Should show staff content
        expect(find.text('Staff Management - Coming Soon'), findsOneWidget);

        // Tap on Reports tab
        await tester.tap(find.text('Reports'));
        await tester.pumpAndSettle();
        
        // Should show reports content
        expect(find.text('Reports & Analytics - Coming Soon'), findsOneWidget);
      });

      testWidgets('should show admin actions modal when FAB is tapped', (WidgetTester tester) async {
        await authProvider.login(email: 'admin@example.com', password: 'admin123');
        
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
              ChangeNotifierProvider<BookingProvider>.value(value: bookingProvider),
            ],
            child: MaterialApp(
              home: const EnhancedMobileAdminDashboard(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Tap the floating action button
        await tester.tap(find.text('Admin Actions'));
        await tester.pumpAndSettle();

        // Should show modal bottom sheet
        expect(find.text('Admin Actions'), findsOneWidget);
        expect(find.text('Refresh Data'), findsOneWidget);
        expect(find.text('Export Reports'), findsOneWidget);
        expect(find.text('Send Notifications'), findsOneWidget);
        expect(find.text('Security Settings'), findsOneWidget);
      });
    });

    group('Dashboard Comparison Tests', () {
      testWidgets('should show different content for different user roles', (WidgetTester tester) async {
        // Test Customer Dashboard
        await authProvider.login(email: 'customer@example.com', password: 'customer123');
        
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
              ChangeNotifierProvider<BookingProvider>.value(value: bookingProvider),
            ],
            child: MaterialApp(
              home: const EnhancedMobileCustomerDashboard(),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('Hi, Customer!'), findsOneWidget);
        expect(find.text('Book Now'), findsOneWidget); // Customer-specific FAB

        // Logout and login as Staff
        await authProvider.logout();
        await authProvider.login(email: 'staff@example.com', password: 'staff123');

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
              ChangeNotifierProvider<StaffProvider>.value(value: staffProvider),
            ],
            child: MaterialApp(
              home: const EnhancedMobileStaffDashboard(),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('Hi, Staff!'), findsOneWidget);
        expect(find.text('Quick Actions'), findsOneWidget); // Staff-specific FAB

        // Logout and login as Admin
        await authProvider.logout();
        await authProvider.login(email: 'admin@example.com', password: 'admin123');

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
              ChangeNotifierProvider<BookingProvider>.value(value: bookingProvider),
            ],
            child: MaterialApp(
              home: const EnhancedMobileAdminDashboard(),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('Admin Panel'), findsOneWidget);
        expect(find.text('Admin Actions'), findsOneWidget); // Admin-specific FAB
      });
    });
  });
}
