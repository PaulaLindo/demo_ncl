// test/integration/staff_flows_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:demo_ncl/main.dart' as app;
import 'package:demo_ncl/providers/timekeeping_provider.dart';
import 'package:demo_ncl/providers/booking_provider.dart';
import 'package:demo_ncl/services/mock_data_service.dart';
import '../integration_test_setup.dart';

// Helper methods
Future<void> _loginAsStaff(WidgetTester tester) async {
  // Use the proper test app setup that includes our login chooser
  await tester.pumpWidget(TestSetup.createTestAppWithLoginChooser());
  await tester.pumpAndSettle();
  
  // First, click Staff Access button on login chooser
  await tester.tap(find.text('Staff Access'));
  await tester.pumpAndSettle();
  
  // Now enter staff credentials on the login screen
  await tester.enterText(find.byKey(const Key('email_field')), 'staff@example.com');
  await tester.enterText(find.byKey(const Key('password_field')), 'staff123');
  await tester.tap(find.byKey(const Key('login_button')));
  await tester.pumpAndSettle(Duration(seconds: 3));
}

Future<void> _loginAsStaffWithJob(WidgetTester tester) async {
  await _loginAsStaff(tester);
  // Mock setup for staff with accepted job
}

Future<void> _loginAsStaffWithActiveJob(WidgetTester tester) async {
  await _loginAsStaff(tester);
  // Mock setup for staff with active job
}

Future<void> _loginAsStaffWithCompletedJob(WidgetTester tester) async {
  await _loginAsStaff(tester);
  // Mock setup for staff with completed job
}

Future<void> _loginAsStaffAtLocation(WidgetTester tester) async {
  await _loginAsStaff(tester);
  // Mock GPS location within geofence
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Staff End-to-End Flows', () {
    late MockFirebaseAuth auth;
    late FakeFirebaseFirestore firestore;
    late MockDataService mockDataService;

    setUp(() {
      auth = MockFirebaseAuth();
      firestore = FakeFirebaseFirestore();
      mockDataService = MockDataService();
    });

    testWidgets('Staff Step 1: Set Availability', (WidgetTester tester) async {
      // Setup: Login as staff
      await _loginAsStaff(tester);
      await tester.pumpAndSettle();

      // Navigate to availability screen
      await tester.tap(find.text('Availability'));
      await tester.pumpAndSettle();

      // Verify availability calendar is displayed
      expect(find.text('Set Your Availability'), findsOneWidget);
      expect(find.byType(TableCalendar), findsOneWidget);

      // Set availability for next week
      await tester.tap(find.text('Next Week'));
      await tester.pumpAndSettle();

      // Mark Monday as available
      await tester.tap(find.text('Mon'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Available'));
      await tester.pumpAndSettle();

      // Mark Tuesday as unavailable (hotel duty)
      await tester.tap(find.text('Tue'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Unavailable - Hotel Duty'));
      await tester.pumpAndSettle();

      // Save availability
      await tester.tap(find.text('Save Availability'));
      await tester.pumpAndSettle(Duration(seconds: 2));

      // Verify confirmation
      expect(find.text('Availability saved successfully'), findsOneWidget);
    });

    testWidgets('Staff Step 2: Job Offer & Acceptance', (WidgetTester tester) async {
      // Setup: Login as staff with pending job offer
      await _loginAsStaff(tester);
      await tester.pumpAndSettle();

      // Navigate to jobs screen
      await tester.tap(find.text('Job Offers'));
      await tester.pumpAndSettle();

      // Verify job offer is displayed
      expect(find.text('Deep Clean in Musgrave'), findsOneWidget);
      expect(find.text('4 hours'), findsOneWidget);
      expect(find.text('Tomorrow at 9:00 AM'), findsOneWidget);
      expect(find.text('R350'), findsOneWidget);

      // Tap on job offer to view details
      await tester.tap(find.text('Deep Clean in Musgrave'));
      await tester.pumpAndSettle();

      // Verify job details screen
      expect(find.text('Job Details'), findsOneWidget);
      expect(find.text('Distance: 2.5 km'), findsOneWidget);
      expect(find.text('Fixed Price: R350'), findsOneWidget);
      expect(find.text('Checklist Preview'), findsOneWidget);

      // Accept the job
      await tester.tap(find.text('Accept Job'));
      await tester.pumpAndSettle(Duration(seconds: 2));

      // Verify job is now in "My Schedule"
      await tester.tap(find.text('My Schedule'));
      await tester.pumpAndSettle();
      expect(find.text('Deep Clean in Musgrave'), findsOneWidget);
      expect(find.text('Accepted'), findsOneWidget);
    });

    testWidgets('Staff Step 3: Pre-Shift Transport Request', (WidgetTester tester) async {
      // Setup: Staff has accepted job for tomorrow
      await _loginAsStaffWithJob(tester);
      await tester.pumpAndSettle();

      // Navigate to tomorrow's job
      await tester.tap(find.text('My Schedule'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Deep Clean in Musgrave'));
      await tester.pumpAndSettle();

      // Request Uber ride (60 mins before start time simulation)
      await tester.tap(find.text('Request Uber'));
      await tester.pumpAndSettle(Duration(seconds: 2));

      // Verify Uber request confirmation
      expect(find.text('Uber ride requested'), findsOneWidget);
      expect(find.text('Arriving in 5 minutes'), findsOneWidget);
      expect(find.text('Covered by NCL'), findsOneWidget);
    });

    testWidgets('Staff Step 4: On-Site Service Execution', (WidgetTester tester) async {
      // Setup: Staff has arrived at job location
      await _loginAsStaffWithActiveJob(tester);
      await tester.pumpAndSettle();

      // Navigate to active job
      await tester.tap(find.text('Active Job'));
      await tester.pumpAndSettle();

      // Start Job (geofenced)
      await tester.tap(find.text('Start Job'));
      await tester.pumpAndSettle(Duration(seconds: 2));

      // Verify job started and checklist appears
      expect(find.text('Job in Progress'), findsOneWidget);
      expect(find.text('Digital Checklist'), findsOneWidget);
      expect(find.text('Eco-Product Dosing Guide'), findsOneWidget);

      // Complete mandatory checklist items
      await tester.tap(find.text('Living Room Cleaned'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kitchen Cleaned'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bathrooms Cleaned'));
      await tester.pumpAndSettle();

      // Complete job
      await tester.tap(find.text('Job Complete'));
      await tester.pumpAndSettle(Duration(seconds: 2));

      // Verify job completion
      expect(find.text('Job Completed Successfully'), findsOneWidget);
      expect(find.text('Request Pick Up'), findsOneWidget);
    });

    testWidgets('Staff Step 5: Post-Shift Transport', (WidgetTester tester) async {
      // Setup: Staff just completed job
      await _loginAsStaffWithCompletedJob(tester);
      await tester.pumpAndSettle();

      // Request pick up
      await tester.tap(find.text('Request Pick Up'));
      await tester.pumpAndSettle(Duration(seconds: 2));

      // Verify pick up request
      expect(find.text('Uber pick up requested'), findsOneWidget);
      expect(find.text('Destination: Home or Next Job?'), findsOneWidget);

      // Choose destination
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle(Duration(seconds: 2));

      // Verify ride confirmation
      expect(find.text('Uber en route to home'), findsOneWidget);
    });

    testWidgets('Timekeeping Flow: Clock-In/Out with Geofencing', (WidgetTester tester) async {
      // Setup: Staff at job location
      await _loginAsStaffAtLocation(tester);
      await tester.pumpAndSettle();

      // Clock-in (should only work within geofence)
      await tester.tap(find.text('Start Job'));
      await tester.pumpAndSettle(Duration(seconds: 2));

      // Verify clock-in recorded with GPS
      expect(find.text('Clocked In: 9:00 AM'), findsOneWidget);
      expect(find.text('Location Verified'), findsOneWidget);

      // Simulate work completion
      await tester.pumpAndSettle(Duration(hours: 4));

      // Clock-out (requires checklist completion)
      await tester.tap(find.text('Complete Checklist'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Checkbox).first);
      await tester.tap(find.byType(Checkbox).at(1));
      await tester.tap(find.byType(Checkbox).at(2));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Clock Out'));
      await tester.pumpAndSettle(Duration(seconds: 2));

      // Verify clock-out and time tracking
      expect(find.text('Clocked Out: 1:00 PM'), findsOneWidget);
      expect(find.text('Total Hours: 4.0'), findsOneWidget);
      expect(find.text('Client Rating Prompt Sent'), findsOneWidget);
    });
  });
}
