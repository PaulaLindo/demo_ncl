// test/integration/admin_flows_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

import 'package:demo_ncl/main.dart' as app;
import 'package:demo_ncl/providers/admin_provider.dart';
import 'package:demo_ncl/services/mock_data_service.dart';
import '../integration_test_setup.dart';

// Helper methods
Future<void> _loginAsAdmin(WidgetTester tester) async {
  // Use the proper test app setup that includes our login chooser
  await tester.pumpWidget(TestSetup.createTestAppWithLoginChooser());
  await tester.pumpAndSettle();
  
  // First, click Admin Portal button on login chooser
  await tester.tap(find.text('Admin Portal'));
  await tester.pumpAndSettle();
  
  // Now enter admin credentials on the login screen
  await tester.enterText(find.byKey(const Key('email_field')), 'admin@example.com');
  await tester.enterText(find.byKey(const Key('password_field')), 'admin123');
  await tester.tap(find.byKey(const Key('login_button')));
  await tester.pumpAndSettle(Duration(seconds: 3));
}

Future<void> _loginAsAdminWithQualityData(WidgetTester tester) async {
  await _loginAsAdmin(tester);
  // Mock setup for admin with quality data
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Admin End-to-End Flows', () {
    late MockFirebaseAuth auth;
    late FakeFirebaseFirestore firestore;
    late MockDataService mockDataService;

    setUp(() {
      auth = MockFirebaseAuth();
      firestore = FakeFirebaseFirestore();
      mockDataService = MockDataService();
    });

    testWidgets('Admin Step 1: Hotel Partner Onboarding', (WidgetTester tester) async {
      // Setup: Login as admin
      await _loginAsAdmin(tester);
      await tester.pumpAndSettle();

      // Navigate to partner management
      await tester.tap(find.text('Partner Management'));
      await tester.pumpAndSettle();

      // Add new hotel partner
      await tester.tap(find.text('Add New Partner'));
      await tester.pumpAndSettle();

      // Verify partner onboarding form
      expect(find.text('Hotel Partner Registration'), findsOneWidget);
      expect(find.byKey(const Key('hotel_name_field')), findsOneWidget);
      expect(find.byKey(const Key('hotel_address_field')), findsOneWidget);
      expect(find.byKey(const Key('admin_contact_field')), findsOneWidget);
      expect(find.byKey(const Key('admin_email_field')), findsOneWidget);
      expect(find.byKey(const Key('admin_phone_field')), findsOneWidget);

      // Fill partner details
      await tester.enterText(find.byKey(const Key('hotel_name_field')), 'Tsogo Sun Musgrave');
      await tester.enterText(find.byKey(const Key('hotel_address_field')), '315 Smith Street, Durban');
      await tester.enterText(find.byKey(const Key('admin_contact_field')), 'John Manager');
      await tester.enterText(find.byKey(const Key('admin_email_field')), 'manager@tsogosun.co.za');
      await tester.enterText(find.byKey(const Key('admin_phone_field')), '+27 31 123 4567');

      // Save partner
      await tester.tap(find.text('Save Partner'));
      await tester.pumpAndSettle(Duration(seconds: 2));

      // Verify partner saved
      expect(find.text('Partner added successfully'), findsOneWidget);
      expect(find.text('Tsogo Sun Musgrave'), findsOneWidget);

      // Bulk staff registration
      await tester.tap(find.text('Register Staff'));
      await tester.pumpAndSettle();

      // Verify bulk registration form
      expect(find.text('Bulk Staff Registration'), findsOneWidget);
      expect(find.byKey(const Key('staff_csv_upload')), findsOneWidget);

      // Upload staff CSV (mock)
      await tester.tap(find.text('Upload CSV'));
      await tester.pumpAndSettle(Duration(seconds: 2));

      // Verify staff list populated
      expect(find.text('Staff Members Found: 15'), findsOneWidget);
      expect(find.text('Jane Smith - Housekeeping'), findsOneWidget);
      expect(find.text('John Doe - Maintenance'), findsOneWidget);

      // Confirm staff registration
      await tester.tap(find.text('Register All Staff'));
      await tester.pumpAndSettle(Duration(seconds: 3));

      // Verify registration complete
      expect(find.text('15 staff members registered successfully'), findsOneWidget);
      expect(find.text('Send Login Credentials'), findsOneWidget);
    });

    testWidgets('Admin Step 2: Continuous Quality Assurance', (WidgetTester tester) async {
      // Setup: Login as admin with quality issues
      await _loginAsAdminWithQualityData(tester);
      await tester.pumpAndSettle();

      // Navigate to quality dashboard
      await tester.tap(find.text('Quality Assurance'));
      await tester.pumpAndSettle();

      // Verify quality metrics dashboard
      expect(find.text('Quality Dashboard'), findsOneWidget);
      expect(find.text('Average Rating: 4.2'), findsOneWidget);
      expect(find.text('Low-Rated Jobs: 3'), findsOneWidget);
      expect(find.text('Incomplete Checklists: 2'), findsOneWidget);
      expect(find.text('Late Arrivals: 1'), findsOneWidget);

      // Investigate low-rated job
      await tester.tap(find.text('Low-Rated Jobs'));
      await tester.pumpAndSettle();

      // Verify flagged jobs list
      expect(find.text('Flagged Services'), findsOneWidget);
      expect(find.text('Deep Clean - Musgrave (⭐ 2.0)'), findsOneWidget);
      expect(find.text('Standard Clean - Durban North (⭐ 2.5)'), findsOneWidget);

      // Review specific low-rated job
      await tester.tap(find.text('Deep Clean - Musgrave'));
      await tester.pumpAndSettle();

      // Verify job details with quality issues
      expect(find.text('Job Quality Review'), findsOneWidget);
      expect(find.text('Staff: Jane Smith'), findsOneWidget);
      expect(find.text('Customer Rating: 2.0/5.0'), findsOneWidget);
      expect(find.text('Issue: Incomplete bathroom cleaning'), findsOneWidget);
      expect(find.text('Customer Comment: "Missed spots in shower"'), findsOneWidget);

      // Check checklist completion
      await tester.tap(find.text('View Checklist'));
      await tester.pumpAndSettle();

      // Verify incomplete checklist
      expect(find.text('Digital Checklist Status'), findsOneWidget);
      expect(find.text('Living Room: ✅ Completed'), findsOneWidget);
      expect(find.text('Kitchen: ✅ Completed'), findsOneWidget);
      expect(find.text('Bathroom: ❌ Incomplete'), findsOneWidget);
      expect(find.text('Bedrooms: ✅ Completed'), findsOneWidget);

      // Take corrective action
      await tester.tap(find.text('Flag for Retraining'));
      await tester.pumpAndSettle(Duration(seconds: 2));

      // Verify action taken
      expect(find.text('Staff flagged for retraining'), findsOneWidget);
      expect(find.text('Retraining: Bathroom Cleaning Standards'), findsOneWidget);
    });

    testWidgets('Admin Step 3: Staff Empowerment & Retention', (WidgetTester tester) async {
      // Setup: Login as admin
      await _loginAsAdmin(tester);
      await tester.pumpAndSettle();

      // Navigate to staff performance
      await tester.tap(find.text('Staff Performance'));
      await tester.pumpAndSettle();

      // Verify staff performance dashboard
      expect(find.text('Staff Performance Metrics'), findsOneWidget);
      expect(find.text('Total Staff: 45'), findsOneWidget);
      expect(find.text('Average Rating: 4.5'), findsOneWidget);
      expect(find.text('Jobs Completed: 1,247'), findsOneWidget);

      // View individual staff performance
      await tester.tap(find.text('Jane Smith'));
      await tester.pumpAndSettle();

      // Verify staff profile with metrics
      expect(find.text('Jane Smith - Performance Review'), findsOneWidget);
      expect(find.text('Jobs Completed: 87'), findsOneWidget);
      expect(find.text('Average Rating: 4.8'), findsOneWidget);
      expect(find.text('On-Time Rate: 96%'), findsOneWidget);
      expect(find.text('Checklist Completion: 98%'), findsOneWidget);

      // Allocate advanced training
      await tester.tap(find.text('Training & Development'));
      await tester.pumpAndSettle();

      // Verify training options
      expect(find.text('Available Training Programs'), findsOneWidget);
      expect(find.text('Elderly Care Certification'), findsOneWidget);
      expect(find.text('Advanced Deep Cleaning'), findsOneWidget);
      expect(find.text('Supervisory Skills'), findsOneWidget);

      // Assign advanced training
      await tester.tap(find.text('Elderly Care Certification'));
      await tester.pumpAndSettle();

      // Verify training assignment
      expect(find.text('Assign Training'), findsOneWidget);
      expect(find.text('SETA Accredited: Yes'), findsOneWidget);
      expect(find.text('Duration: 2 weeks'), findsOneWidget);
      expect(find.text('Cost: R1,500'), findsOneWidget);

      await tester.tap(find.text('Assign Training'));
      await tester.pumpAndSettle(Duration(seconds: 2));

      // Verify training assigned
      expect(find.text('Training assigned successfully'), findsOneWidget);
      expect(find.text('Jane Smith - Elderly Care Certification'), findsOneWidget);
      expect(find.text('Status: In Progress'), findsOneWidget);

      // Consider for promotion
      await tester.tap(find.text('Career Path'));
      await tester.pumpAndSettle();

      // Verify promotion eligibility
      expect(find.text('Promotion Eligibility'), findsOneWidget);
      expect(find.text('Current Role: Housekeeping Staff'), findsOneWidget);
      expect(find.text('Eligible for: Team Leader'), findsOneWidget);
      expect(find.text('Requirements Met: ✅'), findsOneWidget);

      await tester.tap(find.text('Promote to Team Leader'));
      await tester.pumpAndSettle(Duration(seconds: 2));

      // Verify promotion
      expect(find.text('Promotion Successful'), findsOneWidget);
      expect(find.text('New Role: Team Leader'), findsOneWidget);
      expect(find.text('Salary Increase: +15%'), findsOneWidget);
    });

    testWidgets('Admin Step 4: B2B Lead Management', (WidgetTester tester) async {
      // Setup: Login as admin
      await _loginAsAdmin(tester);
      await tester.pumpAndSettle();

      // Navigate to B2B leads
      await tester.tap(find.text('B2B Sales'));
      await tester.pumpAndSettle();

      // Verify B2B CRM dashboard
      expect(find.text('B2B Lead Management'), findsOneWidget);
      expect(find.text('Active Leads: 12'), findsOneWidget);
      expect(find.text('Pipeline Value: R245,000'), findsOneWidget);
      expect(find.text('Conversion Rate: 35%'), findsOneWidget);

      // Add new B2B lead
      await tester.tap(find.text('Add New Lead'));
      await tester.pumpAndSettle();

      // Verify lead form
      expect(find.text('New B2B Lead'), findsOneWidget);
      expect(find.byKey(const Key('company_name_field')), findsOneWidget);
      expect(find.byKey(const Key('industry_field')), findsOneWidget);
      expect(find.byKey(const Key('contact_person_field')), findsOneWidget);
      expect(find.byKey(const Key('contact_email_field')), findsOneWidget);
      expect(find.byKey(const Key('estimated_value_field')), findsOneWidget);

      // Fill lead details
      await tester.enterText(find.byKey(const Key('company_name_field')), 'Netcare Hospital Group');
      await tester.enterText(find.byKey(const Key('industry_field')), 'Healthcare');
      await tester.enterText(find.byKey(const Key('contact_person_field')), 'Dr. Sarah Johnson');
      await tester.enterText(find.byKey(const Key('contact_email_field')), 'sarah.johnson@netcare.co.za');
      await tester.enterText(find.byKey(const Key('estimated_value_field')), '85000');

      // Save lead
      await tester.tap(find.text('Save Lead'));
      await tester.pumpAndSettle(Duration(seconds: 2));

      // Verify lead added
      expect(find.text('Lead added successfully'), findsOneWidget);
      expect(find.text('Netcare Hospital Group'), findsOneWidget);

      // Generate customized proposal
      await tester.tap(find.text('Generate Proposal'));
      await tester.pumpAndSettle();

      // Verify proposal generation
      expect(find.text('Generate Custom Proposal'), findsOneWidget);
      expect(find.text('Accredited & Hotel-Trained Staff'), findsOneWidget);
      expect(find.text('Ethical & Reliable Service'), findsOneWidget);
      expect(find.text('Healthcare-Specific Protocols'), findsOneWidget);

      // Customize proposal
      await tester.enterText(find.byKey(const Key('proposal_notes')), 
        'Specialized cleaning for healthcare environments with infection control protocols');
      await tester.pumpAndSettle();

      // Generate proposal
      await tester.tap(find.text('Generate & Send'));
      await tester.pumpAndSettle(Duration(seconds: 3));

      // Verify proposal sent
      expect(find.text('Proposal sent successfully'), findsOneWidget);
      expect(find.text('Proposal ID: PROP-2024-045'), findsOneWidget);
      expect(find.text('Follow-up required: 2024-02-15'), findsOneWidget);

      // Track lead status
      await tester.tap(find.text('Lead Pipeline'));
      await tester.pumpAndSettle();

      // Verify pipeline stages
      expect(find.text('Lead Pipeline'), findsOneWidget);
      expect(find.text('Initial Contact: 3'), findsOneWidget);
      expect(find.text('Proposal Sent: 5'), findsOneWidget);
      expect(find.text('Negotiation: 2'), findsOneWidget);
      expect(find.text('Closed Won: 2'), findsOneWidget);

      // Verify new lead in pipeline
      expect(find.text('Netcare Hospital Group - Proposal Sent'), findsOneWidget);
    });

    testWidgets('Admin Temp Card Management', (WidgetTester tester) async {
      // Setup: Admin receives proxy request call
      await _loginAsAdmin(tester);
      await tester.pumpAndSettle();

      // Navigate to temp card management
      await tester.tap(find.text('Temp Card Management'));
      await tester.pumpAndSettle();

      // Verify temp card dashboard
      expect(find.text('Temp Card Management'), findsOneWidget);
      expect(find.text('Active Proxy Requests: 0'), findsOneWidget);
      expect(find.text('Pending Approvals: 0'), findsOneWidget);

      // Simulate proxy request
      await tester.tap(find.text('New Proxy Request'));
      await tester.pumpAndSettle();

      // Verify proxy request form
      expect(find.text('Initiate Temp Clock-In'), findsOneWidget);
      expect(find.byKey(const Key('staff_name_field')), findsOneWidget);
      expect(find.byKey(const Key('staff_id_field')), findsOneWidget);
      expect(find.byKey(const Key('job_location_field')), findsOneWidget);
      expect(find.byKey(const Key('verification_question_field')), findsOneWidget);

      // Fill proxy request details
      await tester.enterText(find.byKey(const Key('staff_name_field')), 'John Smith');
      await tester.enterText(find.byKey(const Key('staff_id_field')), 'STAFF-045');
      await tester.enterText(find.byKey(const Key('job_location_field')), '456 Oak Ave, Durban North');
      await tester.enterText(find.byKey(const Key('verification_question_field')), 'What hotel department?');

      // Verify identity (mock successful verification)
      await tester.enterText(find.byKey(const Key('verification_answer_field')), 'Housekeeping');
      await tester.pumpAndSettle();

      // Generate temp card
      await tester.tap(find.text('Generate Temp Card'));
      await tester.pumpAndSettle(Duration(seconds: 2));

      // Verify temp card generated
      expect(find.text('Temp Card Generated'), findsOneWidget);
      expect(find.text('Temp Card Code: 478291'), findsOneWidget);
      expect(find.text('Communicate this code to staff member'), findsOneWidget);
      expect(find.text('Status: PENDING PROXY APPROVAL'), findsOneWidget);

      // Log clock-out (when staff calls back)
      await tester.tap(find.text('Log Clock-Out'));
      await tester.pumpAndSettle();

      // Verify clock-out logged
      expect(find.text('Clock-Out Logged'), findsOneWidget);
      expect(find.text('Temp Card Code: 478291'), findsOneWidget);
      expect(find.text('End Time: 1:00 PM'), findsOneWidget);
      expect(find.text('Total Hours: 4.0'), findsOneWidget);

      // View pending approvals
      await tester.tap(find.text('Pending Approvals'));
      await tester.pumpAndSettle();

      // Verify pending approval
      expect(find.text('Pending Staff Approvals'), findsOneWidget);
      expect(find.text('John Smith - 478291'), findsOneWidget);
      expect(find.text('Hours: 4.0'), findsOneWidget);
      expect(find.text('Status: Awaiting Confirmation'), findsOneWidget);
    });
  });
}
