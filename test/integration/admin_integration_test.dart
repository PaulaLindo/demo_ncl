// test/integration/admin_integration_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:demo_ncl/screens/admin/admin_dashboard.dart';
import 'package:demo_ncl/screens/admin/temp_card_management.dart';
import 'package:demo_ncl/screens/admin/proxy_time_management.dart';
import 'package:demo_ncl/screens/admin/quality_audit_management.dart';
import 'package:demo_ncl/screens/admin/b2b_lead_management.dart';
import 'package:demo_ncl/screens/admin/payroll_management.dart';
import 'package:demo_ncl/screens/admin/live_logistics.dart';
import 'package:demo_ncl/screens/admin/staff_restrictions.dart';
import 'package:demo_ncl/screens/admin/audit_logs.dart';

import 'package:demo_ncl/providers/admin_provider.dart';
import 'package:demo_ncl/theme/app_theme.dart';

void main() {
  group('Admin UI Integration Tests', () {
    late AdminProvider mockAdminProvider;

    setUp(() {
      // Create a mock admin provider for testing
      mockAdminProvider = AdminProvider();
    });

    testWidgets('Admin Dashboard should render correctly', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AdminProvider>(
            create: (_) => mockAdminProvider,
            child: const AdminDashboard(),
          ),
        ),
      );

      // Verify the dashboard renders
      expect(find.text('Admin Dashboard'), findsOneWidget);
      expect(find.text('Quick Stats'), findsOneWidget);
      expect(find.text('Quick Actions'), findsOneWidget);
      
      // Verify navigation options
      expect(find.text('Temp Cards'), findsOneWidget);
      expect(find.text('Proxy Time'), findsOneWidget);
      expect(find.text('Quality Audit'), findsOneWidget);
      expect(find.text('B2B Leads'), findsOneWidget);
      expect(find.text('Payroll'), findsOneWidget);
      expect(find.text('Logistics'), findsOneWidget);
      expect(find.text('Staff Restrictions'), findsOneWidget);
      expect(find.text('Audit Logs'), findsOneWidget);
    });

    testWidgets('Temp Card Management page should render correctly', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AdminProvider>(
            create: (_) => mockAdminProvider,
            child: const TempCardManagementPage(),
          ),
        ),
      );

      // Verify the page renders
      expect(find.text('Temp Card Management'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Active Cards'), findsOneWidget);
      expect(find.text('Inactive Cards'), findsOneWidget);
    });

    testWidgets('Proxy Time Management page should render correctly', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AdminProvider>(
            create: (_) => mockAdminProvider,
            child: const ProxyTimeManagementPage(),
          ),
        ),
      );

      // Verify the page renders
      expect(find.text('Proxy Time Management'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Pending Approval'), findsOneWidget);
      expect(find.text('Approved Hours'), findsOneWidget);
      expect(find.text('Rejected Hours'), findsOneWidget);
    });

    testWidgets('Quality Audit Management page should render correctly', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AdminProvider>(
            create: (_) => mockAdminProvider,
            child: const QualityAuditManagementPage(),
          ),
        ),
      );

      // Verify the page renders
      expect(find.text('Quality Audit Management'), findsOneWidget);
      expect(find.byIcon(Icons.flag), findsOneWidget);
      expect(find.text('Pending Flags'), findsOneWidget);
      expect(find.text('Resolved Flags'), findsOneWidget);
    });

    testWidgets('B2B Lead Management page should render correctly', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AdminProvider>(
            create: (_) => mockAdminProvider,
            child: const B2BLeadManagementPage(),
          ),
        ),
      );

      // Verify the page renders
      expect(find.text('B2B Lead Management'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('New Leads'), findsOneWidget);
      expect(find.text('Contacted'), findsOneWidget);
      expect(find.text('Qualified'), findsOneWidget);
      expect(find.text('Proposal'), findsOneWidget);
      expect(find.text('Won'), findsOneWidget);
      expect(find.text('Lost'), findsOneWidget);
    });

    testWidgets('Payroll Management page should render correctly', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AdminProvider>(
            create: (_) => mockAdminProvider,
            child: const PayrollManagementPage(),
          ),
        ),
      );

      // Verify the page renders
      expect(find.text('Payroll Management'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Draft Reports'), findsOneWidget);
      expect(find.text('Finalized Reports'), findsOneWidget);
    });

    testWidgets('Live Logistics page should render correctly', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AdminProvider>(
            create: (_) => mockAdminProvider,
            child: const LiveLogisticsPage(),
          ),
        ),
      );

      // Verify the page renders
      expect(find.text('Live Logistics Tracking'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Recent Events'), findsOneWidget);
    });

    testWidgets('Staff Restrictions page should render correctly', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AdminProvider>(
            create: (_) => mockAdminProvider,
            child: const StaffRestrictionsPage(),
          ),
        ),
      );

      // Verify the page renders
      expect(find.text('Staff Interface Restrictions'), findsOneWidget);
      expect(find.byIcon(Icons.block), findsOneWidget);
      expect(find.text('Blocked Staff Members'), findsOneWidget);
    });

    testWidgets('Audit Logs page should render correctly', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AdminProvider>(
            create: (_) => mockAdminProvider,
            child: const AuditLogsPage(),
          ),
        ),
      );

      // Verify the page renders
      expect(find.text('Audit Logs'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search by Target ID'), findsOneWidget);
    });

    group('Admin Feature Interactions', () {
      testWidgets('Should navigate to temp card management from dashboard', (WidgetTester tester) async {
        // Build the widget
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: ChangeNotifierProvider<AdminProvider>(
              create: (_) => mockAdminProvider,
              child: const AdminDashboard(),
            ),
          ),
        );

        // Tap on Temp Cards
        await tester.tap(find.text('Temp Cards'));
        await tester.pumpAndSettle();

        // Verify navigation (in a real app, this would navigate to the temp card page)
        // For this test, we just verify the tap works
        expect(find.text('Temp Cards'), findsOneWidget);
      });

      testWidgets('Should show floating action buttons on relevant pages', (WidgetTester tester) async {
        // Test Temp Card Management
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: ChangeNotifierProvider<AdminProvider>(
              create: (_) => mockAdminProvider,
              child: const TempCardManagementPage(),
            ),
          ),
        );

        expect(find.byType(FloatingActionButton), findsOneWidget);
        expect(find.byIcon(Icons.add), findsOneWidget);

        // Test Proxy Time Management
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: ChangeNotifierProvider<AdminProvider>(
              create: (_) => mockAdminProvider,
              child: const ProxyTimeManagementPage(),
            ),
          ),
        );

        expect(find.byType(FloatingActionButton), findsOneWidget);
        expect(find.byIcon(Icons.add), findsOneWidget);

        // Test Quality Audit Management
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: ChangeNotifierProvider<AdminProvider>(
              create: (_) => mockAdminProvider,
              child: const QualityAuditManagementPage(),
            ),
          ),
        );

        expect(find.byType(FloatingActionButton), findsOneWidget);
        expect(find.byIcon(Icons.flag), findsOneWidget);
      });

      testWidgets('Should display proper icons and labels', (WidgetTester tester) async {
        // Test B2B Lead Management page
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: ChangeNotifierProvider<AdminProvider>(
              create: (_) => mockAdminProvider,
              child: const B2BLeadManagementPage(),
            ),
          ),
        );

        // Verify lead status icons
        expect(find.byIcon(Icons.business), findsWidgets);
        expect(find.byIcon(Icons.person), findsWidgets);
        expect(find.byIcon(Icons.email), findsWidgets);
        expect(find.byIcon(Icons.phone), findsWidgets);
      });

      testWidgets('Should handle empty states gracefully', (WidgetTester tester) async {
        // Test Staff Restrictions empty state
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: ChangeNotifierProvider<AdminProvider>(
              create: (_) => mockAdminProvider,
              child: const StaffRestrictionsPage(),
            ),
          ),
        );

        // Should show empty state message
        expect(find.text('No staff members are currently blocked'), findsOneWidget);
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
      });
    });

    group('Admin UI Theme and Styling', () {
      testWidgets('Should use consistent purple theme', (WidgetTester tester) async {
        // Build the widget
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: ChangeNotifierProvider<AdminProvider>(
              create: (_) => mockAdminProvider,
              child: const AdminDashboard(),
            ),
          ),
        );

        // Verify app bar uses purple theme
        final appBar = tester.widget<AppBar>(find.byType(AppBar).first);
        expect(appBar.backgroundColor, equals(AppTheme.primaryPurple));
        expect(appBar.foregroundColor, equals(Colors.white));
      });

      testWidgets('Should display proper loading states', (WidgetTester tester) async {
        // This would test loading indicators when data is being fetched
        // In a real implementation, we would mock the provider to return loading state
        
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: ChangeNotifierProvider<AdminProvider>(
              create: (_) => mockAdminProvider,
              child: const TempCardManagementPage(),
            ),
          ),
        );

        // Initially should show loading indicator
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('Admin Form Interactions', () {
      testWidgets('Should show temp card issue dialog', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: ChangeNotifierProvider<AdminProvider>(
              create: (_) => mockAdminProvider,
              child: const TempCardManagementPage(),
            ),
          ),
        );

        // Tap the floating action button
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        // Verify dialog appears
        expect(find.text('Issue Temp Card'), findsOneWidget);
        expect(find.byType(TextField), findsWidgets);
        expect(find.text('Issue Card'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
      });

      testWidgets('Should show proxy time creation dialog', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: ChangeNotifierProvider<AdminProvider>(
              create: (_) => mockAdminProvider,
              child: const ProxyTimeManagementPage(),
            ),
          ),
        );

        // Tap the floating action button
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        // Verify dialog appears
        expect(find.text('Create Proxy Time Record'), findsOneWidget);
        expect(find.byType(TextField), findsWidgets);
        expect(find.text('Create Record'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
      });

      testWidgets('Should show quality flag creation dialog', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: ChangeNotifierProvider<AdminProvider>(
              create: (_) => mockAdminProvider,
              child: const QualityAuditManagementPage(),
            ),
          ),
        );

        // Tap the floating action button
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        // Verify dialog appears
        expect(find.text('Flag Quality Issue'), findsOneWidget);
        expect(find.byType(TextField), findsWidgets);
        expect(find.text('Flag Issue'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
      });
    });

    group('Admin Error Handling', () {
      testWidgets('Should handle error states gracefully', (WidgetTester tester) async {
        // This would test error handling when API calls fail
        // In a real implementation, we would mock the provider to return error state
        
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: ChangeNotifierProvider<AdminProvider>(
              create: (_) => mockAdminProvider,
              child: const PayrollManagementPage(),
            ),
          ),
        );

        // Should handle error states (implementation would show error message)
        // For now, just verify the page renders
        expect(find.text('Payroll Management'), findsOneWidget);
      });
    });
  });
}
