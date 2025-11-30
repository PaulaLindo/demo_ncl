// test/unit/main_providers_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:demo_ncl/providers/auth_provider.dart';
import 'package:demo_ncl/services/mock_data_service.dart';
import 'package:demo_ncl/providers/checklist_provider.dart';
import 'package:demo_ncl/providers/staff_provider.dart';
import 'package:demo_ncl/repositories/job_repository.dart';
import 'package:demo_ncl/repositories/staff_schedule_repository.dart';
import 'package:demo_ncl/providers/timekeeping_provider.dart';
import 'package:demo_ncl/providers/booking_provider.dart';
import 'package:demo_ncl/providers/jobs_provider.dart';

void main() {
  group('Main Providers Integration Test', () {
    testWidgets('should initialize all providers without errors', (WidgetTester tester) async {
      // Create services
      final mockDataService = MockDataService();
      final jobRepository = JobRepository();
      final staffScheduleRepository = StaffScheduleRepository();
      final authProvider = AuthProvider(mockDataService);

      // Build widget with all providers
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ChangeNotifierProvider(create: (_) => ChecklistProvider()),
            ChangeNotifierProvider<StaffProvider>(
              create: (context) => StaffProvider(
                jobRepository: jobRepository,
                scheduleRepository: staffScheduleRepository,
                authProvider: authProvider,
              ),
            ),
            ChangeNotifierProvider<TimekeepingProvider>(
              create: (_) => TimekeepingProvider(),
              lazy: true,
            ),
            ChangeNotifierProvider<BookingProvider>(
              create: (_) => BookingProvider(),
              lazy: true,
            ),
            ChangeNotifierProvider<JobsProvider>(
              create: (_) => JobsProvider(),
              lazy: true,
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Center(child: Text('Test')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the app loads without errors
      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('should test providers one by one', (WidgetTester tester) async {
      // Test AuthProvider alone
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
          child: MaterialApp(
            home: Scaffold(body: Center(child: Text('Auth Test'))),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Auth Test'), findsOneWidget);

      // Test ChecklistProvider alone
      await tester.pumpWidget(
        ChangeNotifierProvider<ChecklistProvider>(
          create: (_) => ChecklistProvider(),
          child: MaterialApp(
            home: Scaffold(body: Center(child: Text('Checklist Test'))),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Checklist Test'), findsOneWidget);

      // Test TimekeepingProvider alone (with lazy: false)
      await tester.pumpWidget(
        ChangeNotifierProvider<TimekeepingProvider>(
          create: (_) => TimekeepingProvider(),
          lazy: false,
          child: MaterialApp(
            home: Scaffold(body: Center(child: Text('Timekeeping Test'))),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Timekeeping Test'), findsOneWidget);

      // Test BookingProvider alone (with lazy: false)
      await tester.pumpWidget(
        ChangeNotifierProvider<BookingProvider>(
          create: (_) => BookingProvider(),
          lazy: false,
          child: MaterialApp(
            home: Scaffold(body: Center(child: Text('Booking Test'))),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Booking Test'), findsOneWidget);

      // Test JobsProvider alone (with lazy: false)
      await tester.pumpWidget(
        ChangeNotifierProvider<JobsProvider>(
          create: (_) => JobsProvider(),
          lazy: false,
          child: MaterialApp(
            home: Scaffold(body: Center(child: Text('Jobs Test'))),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Jobs Test'), findsOneWidget);
    });
  });
}
