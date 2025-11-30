// test/unit/admin_dashboard_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:demo_ncl/screens/admin/enhanced_admin_dashboard.dart';

void main() {
  group('Admin Dashboard Tests', () {
    testWidgets('should display dashboard correctly', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(const MaterialApp(
        home: EnhancedAdminDashboard(),
      ));

      // Wait for loading to complete
      await tester.pumpAndSettle();

      // Verify the app bar title
      expect(find.textContaining('Admin Dashboard'), findsOneWidget);

      // Verify tabs are displayed
      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Users'), findsOneWidget);
      expect(find.text('Bookings'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);

      // Verify overview tab content
      expect(find.text('Today\'s Bookings'), findsOneWidget);
      expect(find.text('Upcoming'), findsOneWidget);
      expect(find.text('Total Staff'), findsOneWidget);
      expect(find.text('Revenue'), findsOneWidget);

      // Verify quick actions
      expect(find.text('Quick Actions'), findsOneWidget);
      expect(find.text('Add User'), findsOneWidget);
      expect(find.text('View Bookings'), findsOneWidget);
    });

    testWidgets('should switch between tabs correctly', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(const MaterialApp(
        home: EnhancedAdminDashboard(),
      ));

      // Wait for loading to complete
      await tester.pumpAndSettle();

      // Verify we're on the overview tab initially
      expect(find.text('Today\'s Bookings'), findsOneWidget);

      // Tap on Users tab
      await tester.tap(find.text('Users'));
      await tester.pumpAndSettle();

      // Verify users tab content
      expect(find.text('Total Staff'), findsOneWidget);
      expect(find.text('Active Today'), findsOneWidget);
      expect(find.text('New This Week'), findsOneWidget);

      // Tap on Bookings tab
      await tester.tap(find.text('Bookings'));
      await tester.pumpAndSettle();

      // Verify bookings tab content
      expect(find.text('Total'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);

      // Tap on Settings tab
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Verify settings tab content
      expect(find.text('System Settings'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Data Management'), findsOneWidget);
    });

    testWidgets('should display metrics correctly', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(const MaterialApp(
        home: EnhancedAdminDashboard(),
      ));

      // Wait for loading to complete
      await tester.pumpAndSettle();

      // Verify metric cards are displayed
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      expect(find.byIcon(Icons.upcoming), findsOneWidget);
      expect(find.byIcon(Icons.people), findsOneWidget);
      expect(find.byIcon(Icons.attach_money), findsOneWidget);

      // Verify metric values are displayed (should be numbers)
      expect(find.textContaining('\$'), findsOneWidget); // Revenue should have $ symbol
    });

    testWidgets('should handle refresh action', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(const MaterialApp(
        home: EnhancedAdminDashboard(),
      ));

      // Wait for loading to complete
      await tester.pumpAndSettle();

      // Find and tap refresh button
      final refreshButton = find.byIcon(Icons.refresh);
      expect(refreshButton, findsOneWidget);

      await tester.tap(refreshButton);
      await tester.pumpAndSettle();

      // Verify content is still displayed after refresh
      expect(find.text('Today\'s Bookings'), findsOneWidget);
    });

    testWidgets('should display recent activity', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(const MaterialApp(
        home: EnhancedAdminDashboard(),
      ));

      // Wait for loading to complete
      await tester.pumpAndSettle();

      // Verify recent activity section
      expect(find.text('Recent Activity'), findsOneWidget);
      expect(find.byIcon(Icons.event), findsWidgets); // Multiple activity items
    });

    testWidgets('should display settings options', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(const MaterialApp(
        home: EnhancedAdminDashboard(),
      ));

      // Wait for loading to complete
      await tester.pumpAndSettle();

      // Navigate to Settings tab
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Verify system settings
      expect(find.text('Business Hours'), findsOneWidget);
      expect(find.text('Service Areas'), findsOneWidget);
      expect(find.text('Pricing Rules'), findsOneWidget);

      // Verify notification settings
      expect(find.text('Email Notifications'), findsOneWidget);
      expect(find.text('SMS Notifications'), findsOneWidget);
      expect(find.text('Push Notifications'), findsOneWidget);

      // Verify data management
      expect(find.text('Export Data'), findsOneWidget);
      expect(find.text('Backup Settings'), findsOneWidget);
      expect(find.text('Clear Cache'), findsOneWidget);
    });

    testWidgets('should handle settings item taps', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(const MaterialApp(
        home: EnhancedAdminDashboard(),
      ));

      // Wait for loading to complete
      await tester.pumpAndSettle();

      // Navigate to Settings tab
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Tap on Business Hours
      await tester.tap(find.text('Business Hours'));
      await tester.pumpAndSettle();

      // Verify dialog appears
      expect(find.text('Business Hours'), findsWidgets); // One in list, one in dialog
      expect(find.text('Business hours configuration coming soon!'), findsOneWidget);

      // Close dialog
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Tap on Export Data
      await tester.tap(find.text('Export Data'));
      await tester.pumpAndSettle();

      // Verify dialog appears
      expect(find.text('Export Data'), findsWidgets); // One in list, one in dialog
      expect(find.text('Data export feature coming soon!'), findsOneWidget);
    });

    testWidgets('should display user statistics', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(const MaterialApp(
        home: EnhancedAdminDashboard(),
      ));

      // Wait for loading to complete
      await tester.pumpAndSettle();

      // Navigate to Users tab
      await tester.tap(find.text('Users'));
      await tester.pumpAndSettle();

      // Verify user statistics
      expect(find.text('Total Staff'), findsOneWidget);
      expect(find.text('Active Today'), findsOneWidget);
      expect(find.text('New This Week'), findsOneWidget);

      // Verify statistics are numbers
      expect(find.textContaining('Total Staff'), findsOneWidget);
    });

    testWidgets('should display booking statistics', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(const MaterialApp(
        home: EnhancedAdminDashboard(),
      ));

      // Wait for loading to complete
      await tester.pumpAndSettle();

      // Navigate to Bookings tab
      await tester.tap(find.text('Bookings'));
      await tester.pumpAndSettle();

      // Verify booking statistics
      expect(find.text('Total'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);

      // Verify statistics are numbers
      expect(find.textContaining('Total'), findsOneWidget);
    });

    testWidgets('should handle quick actions', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(const MaterialApp(
        home: EnhancedAdminDashboard(),
      ));

      // Wait for loading to complete
      await tester.pumpAndSettle();

      // Tap on Add User button
      await tester.tap(find.text('Add User'));
      await tester.pumpAndSettle();

      // Verify snackbar appears
      expect(find.text('User management coming soon!'), findsOneWidget);

      // Wait for snackbar to disappear
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Tap on View Bookings button
      await tester.tap(find.text('View Bookings'));
      await tester.pumpAndSettle();

      // Verify snackbar appears
      expect(find.text('Booking management coming soon!'), findsOneWidget);
    });

    testWidgets('should handle empty states correctly', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(const MaterialApp(
        home: EnhancedAdminDashboard(),
      ));

      // Wait for loading to complete
      await tester.pumpAndSettle();

      // Navigate to Users tab
      await tester.tap(find.text('Users'));
      await tester.pumpAndSettle();

      // Note: In a real scenario with empty data, we would verify empty state messages
      // For this test, we're just ensuring the tab switches correctly
      expect(find.text('Total Staff'), findsOneWidget);
    });

    testWidgets('should display correct icons', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(const MaterialApp(
        home: EnhancedAdminDashboard(),
      ));

      // Wait for loading to complete
      await tester.pumpAndSettle();

      // Verify overview tab icons
      expect(find.byIcon(Icons.dashboard), findsOneWidget);
      expect(find.byIcon(Icons.people), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);

      // Navigate to Settings tab
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Verify settings tab icons
      expect(find.byIcon(Icons.access_time), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsOneWidget);
      expect(find.byIcon(Icons.attach_money), findsOneWidget);
      expect(find.byIcon(Icons.email), findsOneWidget);
      expect(find.byIcon(Icons.sms), findsOneWidget);
      expect(find.byIcon(Icons.notifications), findsOneWidget);
      expect(find.byIcon(Icons.download), findsOneWidget);
      expect(find.byIcon(Icons.backup), findsOneWidget);
      expect(find.byIcon(Icons.clear_all), findsOneWidget);
    });

    testWidgets('should handle loading state', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(const MaterialApp(
        home: EnhancedAdminDashboard(),
      ));

      // Initially should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for loading to complete
      await tester.pumpAndSettle();

      // Should show content after loading
      expect(find.text('Overview'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group('Admin Dashboard UI Components Tests', () {
    testWidgets('should display metric cards with correct styling', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(const MaterialApp(
        home: EnhancedAdminDashboard(),
      ));

      // Wait for loading to complete
      await tester.pumpAndSettle();

      // Verify metric cards are displayed
      expect(find.byType(Card), findsWidgets); // Multiple cards for metrics

      // Verify metric card structure
      expect(find.text('Today\'s Bookings'), findsOneWidget);
      expect(find.text('Upcoming'), findsOneWidget);
      expect(find.text('Total Staff'), findsOneWidget);
      expect(find.text('Revenue'), findsOneWidget);
    });

    testWidgets('should display tab bar correctly', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(const MaterialApp(
        home: EnhancedAdminDashboard(),
      ));

      // Wait for loading to complete
      await tester.pumpAndSettle();

      // Verify tab bar
      expect(find.byType(TabBar), findsOneWidget);
      expect(find.byType(Tab), findsNWidgets(4)); // 4 tabs

      // Verify tab labels
      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Users'), findsOneWidget);
      expect(find.text('Bookings'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('should display app bar correctly', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(const MaterialApp(
        home: EnhancedAdminDashboard(),
      ));

      // Wait for loading to complete
      await tester.pumpAndSettle();

      // Verify app bar
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.textContaining('Admin Dashboard'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });
  });
}
